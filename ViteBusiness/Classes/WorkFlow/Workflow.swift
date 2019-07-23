//
//  Workflow.swift
//  Vite
//
//  Created by Stone on 2018/12/20.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import UIKit
import ViteWallet
import Vite_HDWalletKit
import PromiseKit
import BigInt
import enum Alamofire.Result

extension ViteError {
    public static var authFailed: ViteError { return ViteError(code: ViteErrorCode(type: .custom, id: 10000), rawMessage: "Auth Failed", rawError: nil) }
    public static var cancel: ViteError { return ViteError(code: ViteErrorCode(type: .custom, id: 10001), rawMessage: "Cancel Operation", rawError: nil) }
}

//MARK: Private
public struct Workflow {

    enum workflowType {
        case other
        case pledge
        case vote
    }

    public static func confirmWorkflow(viewModel: ConfirmViewModelType,
                                       confirmSuccess: @escaping () -> (),
                                       confirmFailure: @escaping (Error) -> () = { _ in }) {
        func showConfirm(isForceUsePassword: Bool = false) {
            let vc = ConfirmViewController(viewModel: viewModel, isForceUsePassword: isForceUsePassword) { (r) in
                switch r {
                case .biometryAuthFailed:
                    Alert.show(title: R.string.localizable.workflowConfirmPageBiometryAuthFailedTitle(), message: nil,
                               titles: [.default(title: R.string.localizable.workflowConfirmPageBiometryAuthFailedBack())])
                    confirmFailure(ViteError.authFailed)
                case .passwordAuthFailed:
                    Alert.show(title: R.string.localizable.workflowConfirmPageToastPasswordError(), message: nil,
                               titles: [.default(title: R.string.localizable.workflowConfirmPagePasswordAuthFailedRetry())],
                               handler: { _, _ in showConfirm(isForceUsePassword: true) })
                case .cancelled:
                    plog(level: .info, log: "Confirm cancelled", tag: .transaction)
                    confirmFailure(ViteError.cancel)
                case .success:
                    confirmSuccess()
                }
            }
            UIViewController.current?.present(vc, animated: false, completion: nil)
        }
        showConfirm()
    }

    static func getPowWorkflow(context: SendBlockContext) -> Promise<SendBlockContext> {
        var cancelPow = false
        let getPowFloatView = GetPowFloatView(superview: UIApplication.shared.keyWindow!) {
            cancelPow = true
        }
        getPowFloatView.show()
        let waitAtLeast = after(seconds: 3)
        return ViteNode.rawTx.send.getPow(context: context)
            .recover { (e) -> Promise<SendBlockContext> in
                getPowFloatView.hide()
                return Promise(error: e)
            }
            .then { context -> Promise<SendBlockContext> in
                return waitAtLeast.then({ () -> Promise<SendBlockContext> in
                    return .value(context)
                })
            }
            .then { context -> Promise<SendBlockContext> in
                if cancelPow {
                    return Promise(error: ViteError.cancel)
                } else {
                    return Promise<SendBlockContext> { seal in
                        getPowFloatView.finish { seal.fulfill(context) }
                    }
                }
            }
    }

    static func send(account: Wallet.Account,
                     toAddress: ViteAddress,
                     tokenId: ViteTokenId,
                     amount: Amount,
                     fee: Amount?,
                     data: Data?,
                     successToast: String,
                     type: workflowType,
                     completion: @escaping (Result<AccountBlock>) -> ()) {
        HUD.show()
        ViteNode.rawTx.send.prepare(account: account,
                                    toAddress: toAddress,
                                    tokenId: tokenId,
                                    amount: amount,
                                    fee: fee,
                                    data: data)
            .always {
                HUD.hide()
            }.then { (context) -> Promise<(context: SendBlockContext, calculatedPoW: Bool, getPoWTimestamp: Date)> in
                let start = Date()
                if context.isNeedToCalcPoW {
                    return getPowWorkflow(context: context).map { ($0, context.isNeedToCalcPoW, start) }
                } else {
                    return Promise.value((context, context.isNeedToCalcPoW, start))
                }
            }.always {
                HUD.show()
            }.then { (context, calculatedPoW, start) -> Promise<(accountBlock: AccountBlock, calculatedPoW: Bool, duration: String)> in
                let duration = String(Int((Date().timeIntervalSince1970 - start.timeIntervalSince1970)))
                return ViteNode.rawTx.send.context(context).map { ($0, calculatedPoW, duration) }
            }.always {
                HUD.hide()
            }.done { (accountBlock, calculatedPoW, duration) in
                if calculatedPoW {
                    Alert.show(title: "abc", message: duration, actions: [
                        (.default(title: R.string.localizable.confirm()), nil),
                        ])
                } else {
                    AlertControl.showCompletion(successToast)
                }
                completion(Result.success(accountBlock))
            }.catch { (e) in
                let error = ViteError.conversion(from: e)
                if error.code == ViteErrorCode.rpcNotEnoughBalance {
                    AlertSheet.show(title: R.string.localizable.sendPageNotEnoughBalanceAlertTitle(), message: nil,
                                    titles: [.default(title: R.string.localizable.sendPageNotEnoughBalanceAlertButton())])
                } else if error.code == ViteErrorCode.rpcNotEnoughQuota {
                    Toast.show(error.viteErrorMessage)
                } else if error != ViteError.cancel {
                    if case .vote = type, error.code == ViteErrorCode.rpcNoTransactionBefore {
                        Toast.show(R.string.localizable.voteListSearchNoTransactionBefore())
                    } else {
                        Toast.show(error.viteErrorMessage)
                    }
                }
                completion(Result.failure(error))
        }
    }

    private static func sendRawTxWorkflow(withoutPowPromise: @escaping () -> Promise<AccountBlock>,
                                          getPowPromise: @escaping () -> Promise<SendBlockContext>,
                                          successToast: String,
                                          type: workflowType,
                                          completion: @escaping (Result<AccountBlock>) -> ()) {
        HUD.show()
        withoutPowPromise()
            .always {
                HUD.hide()
            }
            .recover { (e) -> Promise<AccountBlock> in
                if ViteError.conversion(from: e).code == ViteErrorCode.rpcNotEnoughQuota {
                    return sendRawTxWithPowWorkflow(getPowPromise: getPowPromise)
                } else {
                    return Promise(error: e)
                }
            }
            .done {
                AlertControl.showCompletion(successToast)
                completion(Result.success($0))
            }
            .catch { e in
                let error = ViteError.conversion(from: e)
                if error.code == ViteErrorCode.rpcNotEnoughBalance {
                    AlertSheet.show(title: R.string.localizable.sendPageNotEnoughBalanceAlertTitle(), message: nil,
                                    titles: [.default(title: R.string.localizable.sendPageNotEnoughBalanceAlertButton())])
                } else if error.code == ViteErrorCode.rpcNotEnoughQuota {
                    switch type {
                    case .other, .vote:
                        AlertSheet.show(title: R.string.localizable.quotaAlertTitle(), message: R.string.localizable.quotaAlertNeedQuotaMessage(),
                                        titles: [.default(title: R.string.localizable.quotaAlertQuotaButtonTitle()),
                                                 .cancel],
                                        handler: { (_, index) in
                                            if index == 0 {
                                                let vc = QuotaManageViewController()
                                                UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
                                            }
                        }, config: { alert in
                            alert.preferredAction = alert.actions[0]
                        })
                    case .pledge:
                        Toast.show(error.viteErrorMessage)
                    }
                } else if error != ViteError.cancel {
                    if case .vote = type, error.code == ViteErrorCode.rpcNoTransactionBefore {
                        Toast.show(R.string.localizable.voteListSearchNoTransactionBefore())
                    } else {
                        Toast.show(error.viteErrorMessage)
                    }
                }
                completion(Result.failure(error))
        }
    }

    static func sendRawTxWithPowWorkflow(getPowPromise: @escaping () -> Promise<SendBlockContext>) -> Promise<AccountBlock> {
        var cancelPow = false
        let getPowFloatView = GetPowFloatView(superview: UIApplication.shared.keyWindow!) {
            cancelPow = true
        }
        getPowFloatView.show()
        let waitAtLeast = after(seconds: 1.5)
        return getPowPromise()
            .recover { (e) -> Promise<SendBlockContext> in
                getPowFloatView.hide()
                return Promise(error: e)
            }
            .then { context -> Promise<SendBlockContext> in
                return waitAtLeast.then({ () -> Promise<SendBlockContext> in
                    return .value(context)
                })
            }
            .then { context -> Promise<SendBlockContext> in
                if cancelPow {
                    return Promise(error: ViteError.cancel)
                } else {
                    return Promise<SendBlockContext> { seal in
                        getPowFloatView.finish { seal.fulfill(context) }
                    }
                }
            }
            .always {
                HUD.show()
            }
            .then { context -> Promise<AccountBlock> in
                return ViteNode.rawTx.send.context(context)
            }.always {
                HUD.hide()
        }
    }
}

//MARK: Public
public extension Workflow {
    static func sendTransactionWithConfirm(account: Wallet.Account,
                                           toAddress: ViteAddress,
                                           tokenInfo: TokenInfo,
                                           amount: Amount,
                                           data: Data?,
                                           completion: @escaping (Result<AccountBlock>) -> ()) {
        let sendBlock = {
            send(account: account,
                 toAddress: toAddress,
                 tokenId: tokenInfo.viteTokenId,
                 amount: amount,
                 fee: Amount(0),
                 data: data,
                 successToast: R.string.localizable.workflowToastTransferSuccess(),
                 type: .other,
                 completion: completion)
        }

        let amountString = "\(amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
        let viewModel = ConfirmViteTransactionViewModel(tokenInfo: tokenInfo, addressString: toAddress, amountString: amountString)
        confirmWorkflow(viewModel: viewModel, confirmSuccess: sendBlock, confirmFailure: { completion(Result.failure($0)) })
    }

    static func sendTransactionWithConfirm(account: Wallet.Account,
                                           toAddress: ViteAddress,
                                           tokenInfo: TokenInfo,
                                           amount: Amount,
                                           note: String?,
                                           completion: @escaping (Result<AccountBlock>) -> ()) {
        let sendBlock = {
            send(account: account,
                 toAddress: toAddress,
                 tokenId: tokenInfo.viteTokenId,
                 amount: amount,
                 fee: Amount(0),
                 data: note?.utf8StringToAccountBlockData(),
                 successToast: R.string.localizable.workflowToastTransferSuccess(),
                 type: .other,
                 completion: completion)
        }

        let amountString = "\(amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
        let viewModel = ConfirmViteTransactionViewModel(tokenInfo: tokenInfo, addressString: toAddress, amountString: amountString)
        confirmWorkflow(viewModel: viewModel, confirmSuccess: sendBlock, confirmFailure: { completion(Result.failure($0)) })
    }

    static func pledgeWithConfirm(account: Wallet.Account,
                                  beneficialAddress: ViteAddress,
                                  amount: Amount,
                                  completion: @escaping (Result<AccountBlock>) -> ()) {
        let sendBlock = {
            send(account: account,
                 toAddress: ViteWalletConst.ContractAddress.pledge.address,
                 tokenId: ViteWalletConst.viteToken.id,
                 amount: amount,
                 fee: Amount(0),
                 data: ABI.BuildIn.getPledgeData(beneficialAddress: beneficialAddress),
                 successToast: R.string.localizable.workflowToastSubmitSuccess(),
                 type: .pledge,
                 completion: completion)
        }

        let tokenInfo = TokenInfo.viteCoin
        let amountString = "\(amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
        let viewModel = ConfirmVitePledgeViewModel(tokenInfo: tokenInfo, beneficialAddressString: beneficialAddress, amountString: amountString)
        confirmWorkflow(viewModel: viewModel, confirmSuccess: sendBlock, confirmFailure: { completion(Result.failure($0)) })
    }

    static func cancelPledgeWithConfirm(account: Wallet.Account,
                                        beneficialAddress: ViteAddress,
                                        amount: Amount,
                                        completion: @escaping (Result<AccountBlock>) -> ()) {
        let sendBlock = {
            send(account: account,
                 toAddress: ViteWalletConst.ContractAddress.pledge.address,
                 tokenId: ViteWalletConst.viteToken.id,
                 amount: Amount(0),
                 fee: Amount(0),
                 data: ABI.BuildIn.getCancelPledgeData(beneficialAddress: beneficialAddress, amount: amount),
                 successToast: R.string.localizable.workflowToastCancelPledgeSuccess(),
                 type: .other,
                 completion: completion)
        }

        let tokenInfo = TokenInfo.viteCoin
        let amountString = "\(amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
        let viewModel = ConfirmViteCancelPledgeViewModel(tokenInfo: tokenInfo, beneficialAddressString: beneficialAddress, amountString: amountString)
        confirmWorkflow(viewModel: viewModel, confirmSuccess: sendBlock, confirmFailure: { completion(Result.failure($0)) })
    }

    static func voteWithConfirm(account: Wallet.Account,
                                name: String,
                                completion: @escaping (Result<AccountBlock>) -> ()) {

        let sendBlock = {
            send(account: account,
                 toAddress: ViteWalletConst.ContractAddress.consensus.address,
                 tokenId: ViteWalletConst.viteToken.id,
                 amount: Amount(0),
                 fee: Amount(0),
                 data: ABI.BuildIn.getVoteData(gid: ViteWalletConst.ConsensusGroup.snapshot.id, name: name),
                 successToast: R.string.localizable.workflowToastVoteSuccess(),
                 type: .vote,
                 completion: completion)
        }

        let tokenInfo = TokenInfo.viteCoin
        let viewModel = ConfirmViteVoteViewModel(tokenInfo: tokenInfo, name: name)
        confirmWorkflow(viewModel: viewModel, confirmSuccess: sendBlock, confirmFailure: { completion(Result.failure($0)) })
    }

    static func cancelVoteWithConfirm(account: Wallet.Account,
                                      name: String,
                                      completion: @escaping (Result<AccountBlock>) -> ()) {
        let sendBlock = {
            send(account: account,
                 toAddress: ViteWalletConst.ContractAddress.consensus.address,
                 tokenId: ViteWalletConst.viteToken.id,
                 amount: Amount(0),
                 fee: Amount(0),
                 data: ABI.BuildIn.getCancelVoteData(gid: ViteWalletConst.ConsensusGroup.snapshot.id),
                 successToast: R.string.localizable.workflowToastCancelVoteSuccess(),
                 type: .vote,
                 completion: completion)
        }

        let tokenInfo = TokenInfo.viteCoin
        let viewModel = ConfirmViteCancelVoteViewModel(tokenInfo: tokenInfo, name: name)
        confirmWorkflow(viewModel: viewModel, confirmSuccess: sendBlock, confirmFailure: { completion(Result.failure($0)) })
    }

    static func callContractWithConfirm(account: Wallet.Account,
                                        toAddress: ViteAddress,
                                        tokenInfo: TokenInfo,
                                        amount: Amount,
                                        fee: Amount,
                                        data: Data?,
                                        completion: @escaping (Result<AccountBlock>) -> ()) {
        let sendBlock = {
            send(account: account,
                 toAddress: toAddress,
                 tokenId: tokenInfo.viteTokenId,
                 amount: amount,
                 fee: fee,
                 data: data,
                 successToast: R.string.localizable.workflowToastContractSuccess(),
                 type: .other,
                 completion: completion)
        }

        let amountString = "\(amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
        let viewModel = ConfirmViteCallContractViewModel(tokenInfo: tokenInfo, addressString: toAddress, amountString: amountString)
        confirmWorkflow(viewModel: viewModel, confirmSuccess: sendBlock, confirmFailure: { completion(Result.failure($0)) })
    }

    static func sendRawTx(by uri: ViteURI, accountAddress: ViteAddress, tokenInfo: TokenInfo, completion: @escaping (Result<AccountBlock>) -> ()) {
        guard let account = HDWalletManager.instance.account else {
            completion(Result.failure(WorkflowError.notLogin))
            return
        }
        guard account.address == accountAddress else {
            completion(Result.failure(WorkflowError.accountAddressInconformity))
            return
        }

        guard let amount = uri.amountForSmallestUnit(decimals: tokenInfo.decimals) else {
            completion(Result.failure(WorkflowError.amountInvalid))
            return
        }

        guard let fee = uri.feeForSmallestUnit(decimals: ViteWalletConst.viteToken.decimals) else {
            completion(Result.failure(WorkflowError.feeInvalid))
            return
        }

        switch uri.type {
        case .transfer:
            sendTransactionWithConfirm(account: account, toAddress: uri.address, tokenInfo: tokenInfo, amount: amount, data: uri.data, completion: completion)
        case .contract:
            callContractWithConfirm(account: account, toAddress: uri.address, tokenInfo: tokenInfo, amount: amount, fee: fee, data: uri.data, completion: completion)
        }
    }

    enum WorkflowError: Error {
        case notLogin
        case accountAddressInconformity
        case amountInvalid
        case feeInvalid
    }
}

//MARK: Share
public extension Workflow {

    static func share(activityItems: [Any], applicationActivities: [UIActivity]? = nil, completion: ((Result<Void>) -> ())? = nil) {
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        if let completion = completion {
            activityViewController.completionWithItemsHandler = { (_, completed, _, error) in
                if let error = error {
                    completion(Result.failure(error))
                } else if completed {
                    completion(Result.success(()))
                } else {
                    completion(Result.failure(ViteError.cancel))
                }
            }
        }

        guard let current = UIViewController.current else { return }
        activityViewController.popoverPresentationController?.sourceView = current.view
        activityViewController.popoverPresentationController?.sourceRect = current.view.bounds
        current.present(activityViewController, animated: true)
    }
}

