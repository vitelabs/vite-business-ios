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
        case pledge(beneficialAddress: ViteAddress)
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
        let getPowFloatView = GetPowFloatView(superview: UIApplication.shared.keyWindow!, utString: context.quota.utRequired.utToString()) {
            cancelPow = true
        }
        getPowFloatView.show()
        let waitAtLeast = after(seconds: TimeInterval(AppConfigService.instance.pDelay))
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
            }.then { (context) -> Promise<(context: SendBlockContext, getPoWTimestamp: Date)> in
                if context.quota.isCongestion {
                    if context.isNeedToCalcPoW {
                        return Promise { seal in
                            Alert.show(title: R.string.localizable.workflowCongestionWithPowAlertTitle(), message: R.string.localizable.workflowCongestionWithPowAlertMessage(), actions: [
                                (.default(title: R.string.localizable.workflowCongestionWithPowAlertCancel()), { alertController in
                                    seal.reject(ViteError.cancel)
                                })])
                        }
                    } else {
                        return Promise { seal in
                            Alert.show(title: R.string.localizable.workflowCongestionWithoutPowAlertTitle(), message: R.string.localizable.workflowCongestionWithoutPowAlertMessage(), actions: [
                                (.default(title: R.string.localizable.workflowCongestionWithoutPowAlertOk()), { alertController in
                                    seal.fulfill((context, Date()))
                                }),
                                (.default(title: R.string.localizable.workflowCongestionWithoutPowAlertCancel()), { alertController in
                                    seal.reject(ViteError.cancel)
                                })])
                        }
                    }
                } else {
                    let start = Date()
                    if context.isNeedToCalcPoW {
                        return getPowWorkflow(context: context).map { ($0, start) }
                    } else {
                        return Promise.value((context, start))
                    }
                }
            }.always {
                HUD.show()
            }.then { (context, start) -> Promise<(context: SendBlockContext, accountBlock: AccountBlock, duration: String)> in
                let duration = String(Int((Date().timeIntervalSince1970 - start.timeIntervalSince1970)))
                return ViteNode.rawTx.send.context(context).map { (context, $0, duration) }
            }.always {
                HUD.hide()
            }.done { (context, accountBlock, duration) in
                if case .pledge(let beneficialAddress) = type, beneficialAddress == account.address {
                    AlertControl.showCompletion(successToast)
                } else if context.isNeedToCalcPoW {
                    GetPowFinishedFloatView(superview: UIApplication.shared.keyWindow!, timeString: duration, utString: context.quota.utRequired.utToString(), pledgeClick: {
                        let vc = QuotaManageViewController()
                        UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
                    }, cancelClick: {}).show()
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

    static func sendSilently(account: Wallet.Account,
                             toAddress: ViteAddress,
                             tokenId: ViteTokenId,
                             amount: Amount,
                             fee: Amount?,
                             data: Data?,
                             completion: @escaping (Result<AccountBlock>) -> ()) {
        ViteNode.rawTx.send.prepare(account: account,
                                    toAddress: toAddress,
                                    tokenId: tokenId,
                                    amount: amount,
                                    fee: fee,
                                    data: data)
            .then { (context) -> Promise<SendBlockContext> in
                if context.quota.isCongestion {
                    if context.isNeedToCalcPoW {
                        return Promise(error: ViteError.cancel)
                    } else {
                        return Promise(error: ViteError.cancel)
                    }
                } else {
                    if context.isNeedToCalcPoW {
                        let waitAtLeast = after(seconds: TimeInterval(AppConfigService.instance.pDelay))
                        return ViteNode.rawTx.send.getPow(context: context)
                            .then { context -> Promise<SendBlockContext> in
                                return waitAtLeast.then({ () -> Promise<SendBlockContext> in
                                    return .value(context)
                                })
                        }
                    } else {
                        return Promise.value(context)
                    }
                }
            }.then { context -> Promise<(context: SendBlockContext, accountBlock: AccountBlock)> in
                return ViteNode.rawTx.send.context(context).map { (context, $0) }
            }.done { (context, accountBlock) in
                completion(Result.success(accountBlock))
            }.catch { (e) in
                let error = ViteError.conversion(from: e)
                completion(Result.failure(error))
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
                                           utString: String?,
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
        let viewModel = ConfirmViteTransactionViewModel(tokenInfo: tokenInfo, addressString: toAddress, amountString: amountString, utString: utString)
        confirmWorkflow(viewModel: viewModel, confirmSuccess: sendBlock, confirmFailure: { completion(Result.failure($0)) })
    }

    static func sendTransactionWithConfirm(account: Wallet.Account,
                                           toAddress: ViteAddress,
                                           tokenInfo: TokenInfo,
                                           amount: Amount,
                                           note: String?,
                                           utString: String?,
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
        let viewModel = ConfirmViteTransactionViewModel(tokenInfo: tokenInfo, addressString: toAddress, amountString: amountString, utString: utString)
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
                 data: ABI.BuildIn.getStakeForQuota(beneficialAddress: beneficialAddress),
                 successToast: R.string.localizable.workflowToastSubmitSuccess(),
                 type: .pledge(beneficialAddress: beneficialAddress),
                 completion: completion)
        }

        let tokenInfo = TokenInfo.BuildIn.vite.value
        let amountString = "\(amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
        let viewModel = ConfirmVitePledgeViewModel(tokenInfo: tokenInfo, beneficialAddressString: beneficialAddress, amountString: amountString, utString: ABI.BuildIn.stakeForQuota.ut.utToString())
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

        let tokenInfo = TokenInfo.BuildIn.vite.value
        let amountString = "\(amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
        let viewModel = ConfirmViteCancelPledgeViewModel(tokenInfo: tokenInfo, beneficialAddressString: beneficialAddress, amountString: amountString, utString: ABI.BuildIn.old_cancelStake.ut.utToString())
        confirmWorkflow(viewModel: viewModel, confirmSuccess: sendBlock, confirmFailure: { completion(Result.failure($0)) })
    }

    static func CancelQuotaStakingWithConfirm(account: Wallet.Account,
                                        id: String,
                                        beneficialAddress: ViteAddress,
                                        amount: Amount,
                                        completion: @escaping (Result<AccountBlock>) -> ()) {
        let sendBlock = {
            send(account: account,
                 toAddress: ViteWalletConst.ContractAddress.pledge.address,
                 tokenId: ViteWalletConst.viteToken.id,
                 amount: Amount(0),
                 fee: Amount(0),
                 data: ABI.BuildIn.getCancelQuotaStakingData(id: id),
                 successToast: R.string.localizable.workflowToastCancelPledgeSuccess(),
                 type: .other,
                 completion: completion)
        }

        let tokenInfo = TokenInfo.BuildIn.vite.value
        let amountString = "\(amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
        let viewModel = ConfirmViteCancelPledgeViewModel(tokenInfo: tokenInfo, beneficialAddressString: beneficialAddress, amountString: amountString, utString: ABI.BuildIn.cancelQuotaStaking.ut.utToString())
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
                 data: ABI.BuildIn.getVoteForSBPData(name: name),
                 successToast: R.string.localizable.workflowToastVoteSuccess(),
                 type: .vote,
                 completion: completion)
        }

        let tokenInfo = TokenInfo.BuildIn.vite.value
        let viewModel = ConfirmViteVoteViewModel(tokenInfo: tokenInfo, name: name, utString: ABI.BuildIn.voteForSBP.ut.utToString())
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
                 data: ABI.BuildIn.getCancelSBPVotingData(),
                 successToast: R.string.localizable.workflowToastCancelVoteSuccess(),
                 type: .vote,
                 completion: completion)
        }

        let tokenInfo = TokenInfo.BuildIn.vite.value
        let viewModel = ConfirmViteCancelVoteViewModel(tokenInfo: tokenInfo, name: name, utString: ABI.BuildIn.cancelSBPVoting.ut.utToString())
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
        let viewModel = ConfirmViteCallContractViewModel(tokenInfo: tokenInfo, addressString: toAddress, amountString: amountString, utString: nil)
        confirmWorkflow(viewModel: viewModel, confirmSuccess: sendBlock, confirmFailure: { completion(Result.failure($0)) })
    }

    static func dexDepositWithConfirm(account: Wallet.Account,
                                      tokenInfo: TokenInfo,
                                      amount: Amount,
                                      completion: @escaping (Result<AccountBlock>) -> ()) {
        let sendBlock = {
            send(account: account,
                 toAddress: ViteWalletConst.ContractAddress.dexFund.address,
                 tokenId: tokenInfo.viteTokenId,
                 amount: amount,
                 fee: nil,
                 data: ABI.BuildIn.getDexDepositData(),
                 successToast: R.string.localizable.workflowToastContractSuccess(),
                 type: .other,
                 completion: completion)
        }

        let amountString = "\(amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
        let viewModel = ConfirmViteDexDepositViewModel(tokenInfo: tokenInfo, addressString: ViteWalletConst.ContractAddress.dexFund.address, amountString: amountString, utString: ABI.BuildIn.dexDeposit.ut.utToString())
        confirmWorkflow(viewModel: viewModel, confirmSuccess: sendBlock, confirmFailure: { completion(Result.failure($0)) })
    }

    static func dexWithdrawWithConfirm(account: Wallet.Account,
                                       tokenInfo: TokenInfo,
                                       amount: Amount,
                                       completion: @escaping (Result<AccountBlock>) -> ()) {
        let sendBlock = {
            send(account: account,
                 toAddress: ViteWalletConst.ContractAddress.dexFund.address,
                 tokenId: ViteWalletConst.viteToken.id,
                 amount: 0,
                 fee: nil,
                 data: ABI.BuildIn.getDexWithdrawData(tokenId: tokenInfo.viteTokenId, amount: amount),
                 successToast: R.string.localizable.workflowToastContractSuccess(),
                 type: .other,
                 completion: completion)
        }

        let amountString = "\(amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
        let viewModel = ConfirmViteDexWithdrawViewModel(tokenInfo: tokenInfo, addressString: ViteWalletConst.ContractAddress.dexFund.address, amountString: amountString, utString: ABI.BuildIn.dexWithdraw.ut.utToString())
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
            sendTransactionWithConfirm(account: account, toAddress: uri.address, tokenInfo: tokenInfo, amount: amount, data: uri.data, utString: nil, completion: completion)
        case .contract:
            callContractWithConfirm(account: account, toAddress: uri.address, tokenInfo: tokenInfo, amount: amount, fee: fee, data: uri.data, completion: completion)
        }
    }

    static func dexBuyWithConfirm(account: Wallet.Account,
                                  tradeTokenInfo: TokenInfo,
                                  quoteTokenInfo: TokenInfo,
                                  price: String,
                                  quantity: Amount,
                                  completion: @escaping (Result<AccountBlock>) -> ()) {
        let sendBlock = {
            send(account: account,
                 toAddress: ViteWalletConst.ContractAddress.dexFund.address,
                 tokenId: quoteTokenInfo.viteTokenId,
                 amount: Amount(0),
                 fee: nil,
                 data: ABI.BuildIn.getDexPlaceOrderData(tradeToken: quoteTokenInfo.viteTokenId, quoteToken: quoteTokenInfo.viteTokenId, isBuy: true, price: price, quantity: quantity),
                 successToast: R.string.localizable.workflowToastContractSuccess(),
                 type: .other,
                 completion: completion)
        }

        let quantityString = quantity.amountFullWithGroupSeparator(decimals: tradeTokenInfo.decimals)
        let viewModel = ConfirmViteDexBuyViewModel(tokenInfo: tradeTokenInfo, addressString: ViteWalletConst.ContractAddress.dexFund.address, priceString: price, quantityString: quantityString, utString: ABI.BuildIn.dexPlaceOrder.ut.utToString())
        confirmWorkflow(viewModel: viewModel, confirmSuccess: sendBlock, confirmFailure: { completion(Result.failure($0)) })
    }

    static func dexSellWithConfirm(account: Wallet.Account,
                                   tradeTokenInfo: TokenInfo,
                                   quoteTokenInfo: TokenInfo,
                                   price: String,
                                   quantity: Amount,
                                   completion: @escaping (Result<AccountBlock>) -> ()) {
        let sendBlock = {
            send(account: account,
                 toAddress: ViteWalletConst.ContractAddress.dexFund.address,
                 tokenId: quoteTokenInfo.viteTokenId,
                 amount: Amount(0),
                 fee: nil,
                 data: ABI.BuildIn.getDexPlaceOrderData(tradeToken: quoteTokenInfo.viteTokenId, quoteToken: quoteTokenInfo.viteTokenId, isBuy: false, price: price, quantity: quantity),
                 successToast: R.string.localizable.workflowToastContractSuccess(),
                 type: .other,
                 completion: completion)
        }

        let quantityString = quantity.amountFullWithGroupSeparator(decimals: tradeTokenInfo.decimals)
        let viewModel = ConfirmViteDexSellViewModel(tokenInfo: tradeTokenInfo, addressString: ViteWalletConst.ContractAddress.dexFund.address, priceString: price, quantityString: quantityString, utString: ABI.BuildIn.dexPlaceOrder.ut.utToString())
        confirmWorkflow(viewModel: viewModel, confirmSuccess: sendBlock, confirmFailure: { completion(Result.failure($0)) })
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
