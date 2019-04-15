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
import enum ViteWallet.Result

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
                                       completion: @escaping (Result<AccountBlock>) -> (),
                                       confirmSuccess: @escaping () -> Void) {
        func showConfirm(isForceUsePassword: Bool = false) {
            let vc = ConfirmViewController(viewModel: viewModel, isForceUsePassword: isForceUsePassword) { (r) in
                switch r {
                case .biometryAuthFailed:
                    Alert.show(title: R.string.localizable.sendPageConfirmBiometryAuthFailedTitle(), message: nil,
                               titles: [.default(title: R.string.localizable.sendPageConfirmBiometryAuthFailedBack())])
                    completion(Result(error: ViteError.authFailed))
                case .passwordAuthFailed:
                    Alert.show(title: R.string.localizable.confirmTransactionPageToastPasswordError(), message: nil,
                               titles: [.default(title: R.string.localizable.sendPageConfirmPasswordAuthFailedRetry())],
                               handler: { _, _ in showConfirm(isForceUsePassword: true) })
                case .cancelled:
                    plog(level: .info, log: "Confirm cancelled", tag: .transaction)
                    completion(Result(error: ViteError.cancel))
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
                    switch type {
                    case .other, .vote:
                        return AlertSheet.show(title: R.string.localizable.quotaAlertTitle(),
                                               message: R.string.localizable.quotaAlertPowAndQuotaMessage(),
                                               titles: [.default(title: R.string.localizable.quotaAlertPowButtonTitle()),
                                                        .default(title: R.string.localizable.quotaAlertQuotaButtonTitle()),
                                                        .cancel], config: { $0.preferredAction = $0.actions[0] })
                            .then({ (_, index) -> Promise<AccountBlock> in
                                if index == 0 {
                                    return sendRawTxWithPowWorkflow(getPowPromise: getPowPromise)
                                } else if index == 1 {
                                    let vc = QuotaManageViewController()
                                    UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
                                    return Promise(error: ViteError.cancel)
                                } else {
                                    return Promise(error: ViteError.cancel)
                                }
                            })
                    case .pledge:
                        return sendRawTxWithPowWorkflow(getPowPromise: getPowPromise)
                    }
                } else {
                    return Promise(error: e)
                }
            }
            .done {
                AlertControl.showCompletion(successToast)
                completion(Result(value: $0))
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
                completion(Result(error: error))
        }
    }

    private static func sendRawTxWithPowWorkflow(getPowPromise: @escaping () -> Promise<SendBlockContext>) -> Promise<AccountBlock> {
        var cancelPow = false
        let getPowFloatView = GetPowFloatView(superview: UIApplication.shared.keyWindow!) {
            cancelPow = true
        }
        getPowFloatView.show()
        return getPowPromise()
            .recover { (e) -> Promise<SendBlockContext> in
                getPowFloatView.hide()
                return Promise(error: e)
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
                                           toAddress: Address,
                                           tokenInfo: TokenInfo,
                                           amount: Balance,
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
                              successToast: R.string.localizable.sendPageToastSendTransferSuccess(),
                              type: .other,
                              completion: completion)
        }

        let amountString = "\(amount.amountFull(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
        let viewModel = ConfirmViteTransactionViewModel(tokenInfo: tokenInfo, addressString: toAddress.description, amountString: amountString)
        confirmWorkflow(viewModel: viewModel, completion: completion, confirmSuccess: sendBlock)
    }

    static func pledgeWithConfirm(account: Wallet.Account,
                                  beneficialAddress: Address,
                                  amount: Balance,
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
                              successToast: R.string.localizable.submitSuccess(),
                              type: .pledge,
                              completion: completion)
        }


        let tokenInfo = TokenInfo.viteCoin
        let amountString = "\(amount.amountFull(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
        let viewModel = ConfirmVitePledgeViewModel(tokenInfo: tokenInfo, beneficialAddressString: beneficialAddress.description, amountString: amountString)
        confirmWorkflow(viewModel: viewModel, completion: completion, confirmSuccess: sendBlock)
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
                              successToast: R.string.localizable.voteListSendSuccess(),
                              type: .vote,
                              completion: completion)
        }

        let tokenInfo = TokenInfo.viteCoin
        let viewModel = ConfirmViteVoteViewModel(tokenInfo: tokenInfo, name: name)
        confirmWorkflow(viewModel: viewModel, completion: completion, confirmSuccess: sendBlock)
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
                              successToast: R.string.localizable.votePageVoteInfoCancelVoteToastTitle(),
                              type: .other,
                              completion: completion)
        }

        let tokenInfo = TokenInfo.viteCoin
        let viewModel = ConfirmViteCancelVoteViewModel(tokenInfo: tokenInfo, name: name)
        confirmWorkflow(viewModel: viewModel, completion: completion, confirmSuccess: sendBlock)
    }

    static func callContractWithConfirm(account: Wallet.Account,
                                        toAddress: Address,
                                        tokenInfo: TokenInfo,
                                        amount: Balance,
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
                              successToast: R.string.localizable.sendPageToastSendSuccess(),
                              type: .other,
                              completion: completion)
        }

        let amountString = "\(amount.amountFull(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
        let viewModel = ConfirmViteCallContractViewModel(tokenInfo: tokenInfo, addressString: toAddress.description, amountString: amountString)
        confirmWorkflow(viewModel: viewModel, completion: completion, confirmSuccess: sendBlock)
    }

    static func sendRawTx(by uri: ViteURI, accountAddress: Address, tokenInfo: TokenInfo, completion: @escaping (Result<AccountBlock>) -> ()) {
        guard let account = HDWalletManager.instance.account else {
            completion(Result(error: WorkflowError.notLogin))
            return
        }
        guard account.address.description == accountAddress.description else {
            completion(Result(error: WorkflowError.accountAddressInconformity))
            return
        }

        guard let amount = uri.amountForSmallestUnit(decimals: tokenInfo.decimals) else {
            completion(Result(error: WorkflowError.amountInvalid))
            return
        }

        switch uri.type {
        case .transfer:
            var note: String?
            if let data = uri.data,
                let ret = String(bytes: data, encoding: .utf8) {
                note = ret
            }
            sendTransactionWithConfirm(account: account, toAddress: uri.address, tokenInfo: tokenInfo, amount: Balance(value: amount), note: note, completion: completion)
        case .contract:
            callContractWithConfirm(account: account, toAddress: uri.address, tokenInfo: tokenInfo, amount: Balance(value: amount), data: uri.data, completion: completion)
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
                    completion(Result(error: error))
                } else if completed {
                    completion(Result(value: ()))
                } else {
                    completion(Result(error: ViteError.cancel))
                }
            }
        }

        guard let current = UIViewController.current else { return }
        activityViewController.popoverPresentationController?.sourceView = current.view
        activityViewController.popoverPresentationController?.sourceRect = current.view.bounds
        current.present(activityViewController, animated: true)
    }
}

