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
            let withoutPowPromise = {
                return ViteNode.rawTx.send.withoutPow(account: account,
                                                      toAddress: toAddress,
                                                      tokenId: tokenInfo.viteTokenId,
                                                      amount: amount,
                                                      data: data)
            }

            let getPowPromise = {
                return ViteNode.rawTx.send.getPow(account: account,
                                                  toAddress: toAddress,
                                                  tokenId: tokenInfo.viteTokenId,
                                                  amount: amount,
                                                  data: data)
            }


            sendRawTxWorkflow(withoutPowPromise: withoutPowPromise,
                              getPowPromise: getPowPromise,
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
            let withoutPowPromise = {
                return ViteNode.transaction.withoutPow(account: account,
                                                       toAddress: toAddress,
                                                       tokenId: tokenInfo.viteTokenId,
                                                       amount: amount,
                                                       note: note)
            }

            let getPowPromise = {
                return ViteNode.transaction.getPow(account: account,
                                                   toAddress: toAddress,
                                                   tokenId: tokenInfo.viteTokenId,
                                                   amount: amount,
                                                   note: note)
            }


            sendRawTxWorkflow(withoutPowPromise: withoutPowPromise,
                              getPowPromise: getPowPromise,
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
            let withoutPowPromise = {
                return ViteNode.pledge.perform.withoutPow(account: account,
                                                          beneficialAddress: beneficialAddress,
                                                          amount: amount)
            }
            let getPowPromise = {
                return ViteNode.pledge.perform.getPow(account: account,
                                                      beneficialAddress: beneficialAddress,
                                                      amount: amount)
            }

            sendRawTxWorkflow(withoutPowPromise: withoutPowPromise,
                              getPowPromise: getPowPromise,
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
            let withoutPowPromise = {
                return ViteNode.pledge.cancel.withoutPow(account: account,
                                                          beneficialAddress: beneficialAddress,
                                                          amount: amount)
            }
            let getPowPromise = {
                return ViteNode.pledge.cancel.getPow(account: account,
                                                     beneficialAddress: beneficialAddress,
                                                     amount: amount)
            }

            sendRawTxWorkflow(withoutPowPromise: withoutPowPromise,
                              getPowPromise: getPowPromise,
                              successToast: R.string.localizable.workflowToastCancelPledgeSuccess(),
                              type: .pledge,
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
            let provider = Provider.default
            let withoutPowPromise =  {
                return ViteNode.vote.perform.withoutPow(account: account,
                                                        gid: ViteWalletConst.ConsensusGroup.snapshot.id,
                                                        name: name)
            }
            let getPowPromise =  {
                    return ViteNode.vote.perform.getPow(account: account,
                                                        gid: ViteWalletConst.ConsensusGroup.snapshot.id,
                                                        name: name)
            }

            sendRawTxWorkflow(withoutPowPromise: withoutPowPromise,
                              getPowPromise: getPowPromise,
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
            let provider = Provider.default
            let withoutPowPromise =  {
                return ViteNode.vote.cancel.withoutPow(account: account,
                                                       gid: ViteWalletConst.ConsensusGroup.snapshot.id)
            }
            let getPowPromise =  {
                return ViteNode.vote.cancel.getPow(account: account,
                                                   gid: ViteWalletConst.ConsensusGroup.snapshot.id)
            }

            sendRawTxWorkflow(withoutPowPromise: withoutPowPromise,
                              getPowPromise: getPowPromise,
                              successToast: R.string.localizable.workflowToastCancelVoteSuccess(),
                              type: .other,
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
                                        data: Data?,
                                        completion: @escaping (Result<AccountBlock>) -> ()) {
        let sendBlock = {
            let provider = Provider.default
            let withoutPowPromise =  {
                return ViteNode.rawTx.send.withoutPow(account: account,
                                                      toAddress: toAddress,
                                                      tokenId: tokenInfo.viteTokenId,
                                                      amount: amount,
                                                      data: data)
            }
            let getPowPromise =  {
                return ViteNode.rawTx.send.getPow(account: account,
                                                  toAddress: toAddress,
                                                  tokenId: tokenInfo.viteTokenId,
                                                  amount: amount,
                                                  data: data)
            }

            sendRawTxWorkflow(withoutPowPromise: withoutPowPromise,
                              getPowPromise: getPowPromise,
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

        switch uri.type {
        case .transfer:
            sendTransactionWithConfirm(account: account, toAddress: uri.address, tokenInfo: tokenInfo, amount: amount, data: uri.data, completion: completion)
        case .contract:
            callContractWithConfirm(account: account, toAddress: uri.address, tokenInfo: tokenInfo, amount: amount, data: uri.data, completion: completion)
        }
    }

    enum WorkflowError: Error {
        case notLogin
        case accountAddressInconformity
        case amountInvalid
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

