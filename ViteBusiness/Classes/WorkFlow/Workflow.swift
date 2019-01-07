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
import PromiseKit
import ViteUtils
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

    private static func confirmWorkflow(title: String,
                                        infoTitle: String,
                                        info: String,
                                        token: String?,
                                        amount: String?,
                                        confirmTitle: String,
                                        completion: @escaping (Result<Void>) -> (),
                                        confirmSuccess: @escaping () -> Void) {
        func showConfirm() {
            let biometryAuthConfig = HDWalletManager.instance.isTransferByBiometry
            let confirmType: ConfirmTransactionViewController.ConfirmTransactionType =  biometryAuthConfig ? .biometry : .password
            let vc = ConfirmViewController(confirmType: confirmType, title: title, infoTitle: infoTitle, info: info,
                                           token: token, amount: amount, confirmTitle: confirmTitle) { r in
                                            switch r {
                                            case .biometryAuthFailed:
                                                Alert.show(title: R.string.localizable.sendPageConfirmBiometryAuthFailedTitle(), message: nil,
                                                           titles: [.default(title: R.string.localizable.sendPageConfirmBiometryAuthFailedBack())])
                                                completion(Result(error: ViteError.authFailed))
                                            case .passwordAuthFailed:
                                                Alert.show(title: R.string.localizable.confirmTransactionPageToastPasswordError(), message: nil,
                                                           titles: [.default(title: R.string.localizable.sendPageConfirmPasswordAuthFailedRetry())],
                                                           handler: { _, _ in showConfirm() })
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

    private static func sendRawTxWorkflow(withoutPowPromise: Promise<Void>,
                                          getPowPromise: Promise<Provider.SendBlockContext>,
                                          successToast: String,
                                          type: workflowType,
                                          completion: @escaping (Result<Void>) -> ()) {
        HUD.show()
        withoutPowPromise
            .always {
                HUD.hide()
            }
            .recover { (e) -> Promise<Void> in
                if ViteError.conversion(from: e).code == ViteErrorCode.rpcNotEnoughQuota {
                    switch type {
                    case .other, .vote:
                        return AlertSheet.show(title: R.string.localizable.quotaAlertTitle(),
                                               message: R.string.localizable.quotaAlertPowAndQuotaMessage(),
                                               titles: [.default(title: R.string.localizable.quotaAlertPowButtonTitle()),
                                                        .default(title: R.string.localizable.quotaAlertQuotaButtonTitle()),
                                                        .cancel], config: { $0.preferredAction = $0.actions[0] })
                            .then({ (_, index) -> Promise<Void> in
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
            .done { _ in
                AlertControl.showCompletion(successToast)
                completion(Result(value: ()))
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

    private static func sendRawTxWithPowWorkflow(getPowPromise: Promise<Provider.SendBlockContext>) -> Promise<Void> {
        var cancelPow = false
        let getPowFloatView = GetPowFloatView(superview: UIApplication.shared.keyWindow!) {
            cancelPow = true
        }
        getPowFloatView.show()
        return getPowPromise
            .recover { (e) -> Promise<Provider.SendBlockContext> in
                getPowFloatView.hide()
                return Promise(error: e)
            }
            .then { context -> Promise<Provider.SendBlockContext> in
                return Promise<Provider.SendBlockContext> { seal in
                    getPowFloatView.finish { seal.fulfill(context) }
                }
            }
            .always {
                HUD.show()
            }
            .then { context -> Promise<Void> in
                return Provider.default.sendRawTxWithContext(context)
            }.always {
                HUD.hide()
        }
    }
}

//MARK: Public
public extension Workflow {
    static func sendTransactionWithConfirm(account: Wallet.Account,
                                           toAddress: Address,
                                           token: Token,
                                           amount: Balance,
                                           note: String?,
                                           completion: @escaping (Result<Void>) -> ()) {
        let sendBlock = {
            let provider = Provider.default
            let withoutPowPromise = provider.sendTransactionWithoutPow(account: account, toAddress: toAddress,
                                                                                          tokenId: token.id, amount: amount, note: note)
            let getPowPromise = provider.getPowForSendTransaction(account: account, toAddress: toAddress, tokenId: token.id,
                                                                                     amount: amount, note: note, difficulty: ViteWalletConst.DefaultDifficulty.send.value)

            sendRawTxWorkflow(withoutPowPromise: withoutPowPromise,
                              getPowPromise: getPowPromise,
                              successToast: R.string.localizable.sendPageToastSendSuccess(),
                              type: .other,
                              completion: completion)
        }

        confirmWorkflow(title: R.string.localizable.confirmTransactionPageTitle(),
                        infoTitle: R.string.localizable.confirmTransactionAddressTitle(),
                        info: toAddress.description,
                        token: token.symbol,
                        amount: amount.amountFull(decimals: token.decimals),
                        confirmTitle: R.string.localizable.confirmTransactionPageConfirmButton(),
                        completion: completion,
                        confirmSuccess: sendBlock)
    }

    static func pledgeWithConfirm(account: Wallet.Account,
                                  beneficialAddress: Address,
                                  amount: Balance,
                                  completion: @escaping (Result<Void>) -> ()) {

        let sendBlock = {
            let provider = Provider.default
            let withoutPowPromise = provider.pledgeWithoutPow(account: account, beneficialAddress: beneficialAddress, amount: amount)
            let getPowPromise = provider.getPowForPledge(account: account, beneficialAddress: beneficialAddress, amount: amount, difficulty: ViteWalletConst.DefaultDifficulty.pledge.value)

            sendRawTxWorkflow(withoutPowPromise: withoutPowPromise,
                              getPowPromise: getPowPromise,
                              successToast: R.string.localizable.submitSuccess(),
                              type: .pledge,
                              completion: completion)
        }

        confirmWorkflow(title: R.string.localizable.confirmTransactionPageTitle(),
                        infoTitle: R.string.localizable.quotaManagePageInputAddressTitle(),
                        info: beneficialAddress.description,
                        token: TokenCacheService.instance.viteToken.symbol,
                        amount: amount.amountFull(decimals: TokenCacheService.instance.viteToken.decimals),
                        confirmTitle: R.string.localizable.confirmTransactionPageConfirmButton(),
                        completion: completion,
                        confirmSuccess: sendBlock)
    }

    static func voteWithConfirm(account: Wallet.Account,
                                name: String,
                                completion: @escaping (Result<Void>) -> ()) {

        let sendBlock = {
            let provider = Provider.default
            let withoutPowPromise = provider.voteWithoutPow(account: account, gid: ViteWalletConst.ConsensusGroup.snapshot.id, name: name)
            let getPowPromise = provider.getPowForVote(account: account, gid: ViteWalletConst.ConsensusGroup.snapshot.id, name: name, difficulty: ViteWalletConst.DefaultDifficulty.vote.value)

            sendRawTxWorkflow(withoutPowPromise: withoutPowPromise,
                              getPowPromise: getPowPromise,
                              successToast: R.string.localizable.voteListSendSuccess(),
                              type: .vote,
                              completion: completion)
        }

        confirmWorkflow(title: R.string.localizable.vote(),
                        infoTitle: R.string.localizable.confirmTransactionPageNodeName(),
                        info: name,
                        token: nil,
                        amount: nil,
                        confirmTitle: R.string.localizable.voteListConfirmButtonTitle(),
                        completion: completion,
                        confirmSuccess: sendBlock)
    }

    static func cancelVoteWithConfirm(account: Wallet.Account,
                                      name: String,
                                      completion: @escaping (Result<Void>) -> ()) {

        let sendBlock = {
            let provider = Provider.default
            let withoutPowPromise = provider.cancelVoteWithoutPow(account: account, gid: ViteWalletConst.ConsensusGroup.snapshot.id)
            let getPowPromise = provider.getPowForCancelVote(account: account, gid: ViteWalletConst.ConsensusGroup.snapshot.id, difficulty: ViteWalletConst.DefaultDifficulty.cancelVote.value)

            sendRawTxWorkflow(withoutPowPromise: withoutPowPromise,
                              getPowPromise: getPowPromise,
                              successToast: R.string.localizable.votePageVoteInfoCancelVoteToastTitle(),
                              type: .other,
                              completion: completion)
        }

        confirmWorkflow(title: R.string.localizable.votePageVoteInfoCancelVoteTitle(),
                        infoTitle: R.string.localizable.confirmTransactionPageNodeName(),
                        info: name,
                        token: nil,
                        amount: nil,
                        confirmTitle: R.string.localizable.voteListConfirmButtonTitle(),
                        completion: completion,
                        confirmSuccess: sendBlock)
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
        UIViewController.current?.present(activityViewController, animated: true)
    }
}


