//
//  Workflow+DeFi.swift
//  ViteBusiness
//
//  Created by Stone on 2019/12/5.
//

import Foundation
import ViteWallet
import BigInt
import PromiseKit
import enum Alamofire.Result

public extension Workflow {

    static func defiDepositWithConfirm(account: Wallet.Account,
                                       tokenInfo: TokenInfo,
                                       amount: Amount,
                                       completion: @escaping (Result<AccountBlock>) -> ()) {
        let sendBlock = {
            send(account: account,
                 toAddress: ViteWalletConst.ContractAddress.defi.address,
                 tokenId: tokenInfo.viteTokenId,
                 amount: amount,
                 fee: nil,
                 data: ABI.BuildIn.getDeFiDepositData(),
                 successToast: R.string.localizable.workflowToastContractSuccess(),
                 type: .other,
                 completion: completion)
        }

        let amountString = "\(amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
        let viewModel = ConfirmViteCallContractViewModel(tokenInfo: tokenInfo, addressString: ViteWalletConst.ContractAddress.defi.address, amountString: amountString, utString: nil)
        confirmWorkflow(viewModel: viewModel, confirmSuccess: sendBlock, confirmFailure: { completion(Result.failure($0)) })
    }

    static func defiWithdrawWithConfirm(account: Wallet.Account,
                                        tokenInfo: TokenInfo,
                                        amount: Amount,
                                        completion: @escaping (Result<AccountBlock>) -> ()) {
        let sendBlock = {
            send(account: account,
                 toAddress: ViteWalletConst.ContractAddress.defi.address,
                 tokenId: ViteWalletConst.viteToken.id,
                 amount: 0,
                 fee: nil,
                 data: ABI.BuildIn.getDeFiWithdrawData(tokenId: tokenInfo.viteTokenId, amount: amount),
                 successToast: R.string.localizable.workflowToastContractSuccess(),
                 type: .other,
                 completion: completion)
        }

        let amountString = "0 \(ViteWalletConst.viteToken.symbol)"
        let viewModel = ConfirmViteCallContractViewModel(tokenInfo: tokenInfo, addressString: ViteWalletConst.ContractAddress.defi.address, amountString: amountString, utString: nil)
        confirmWorkflow(viewModel: viewModel, confirmSuccess: sendBlock, confirmFailure: { completion(Result.failure($0)) })
    }

    static func defiNewLoanWithConfirm(account: Wallet.Account,
                                       tokenInfo: TokenInfo,
                                       dayRate: Decimal,
                                       shareAmount: Amount,
                                       shares: UInt64,
                                       subscribeDays: UInt64,
                                       expireDays: UInt64,
                                       completion: @escaping (Result<AccountBlock>) -> ()) {
        let sendBlock = {
            send(account: account,
                 toAddress: ViteWalletConst.ContractAddress.defi.address,
                 tokenId: ViteWalletConst.viteToken.id,
                 amount: 0,
                 fee: nil,
                 data: ABI.BuildIn.getDeFiNewLoanData(tokenId: tokenInfo.viteTokenId, dayRate: dayRate, shareAmount: shareAmount, shares: shares, subscribeDays: subscribeDays, expireDays: expireDays),
                 successToast: R.string.localizable.workflowToastContractSuccess(),
                 type: .other,
                 completion: completion)
        }

        let amountString = "0 \(ViteWalletConst.viteToken.symbol)"
        let viewModel = ConfirmViteCallContractViewModel(tokenInfo: tokenInfo, addressString: ViteWalletConst.ContractAddress.defi.address, amountString: amountString, utString: nil)
        confirmWorkflow(viewModel: viewModel, confirmSuccess: sendBlock, confirmFailure: { completion(Result.failure($0)) })
    }

    static func defiCancelLoanWithConfirm(account: Wallet.Account,
                                          tokenInfo: TokenInfo,
                                          loanId: UInt64,
                                          completion: @escaping (Result<AccountBlock>) -> ()) {
        let sendBlock = {
            send(account: account,
                 toAddress: ViteWalletConst.ContractAddress.defi.address,
                 tokenId: ViteWalletConst.viteToken.id,
                 amount: 0,
                 fee: nil,
                 data: ABI.BuildIn.getDeFiCancelLoanData(loanId: loanId),
                 successToast: R.string.localizable.workflowToastContractSuccess(),
                 type: .other,
                 completion: completion)
        }

        let amountString = "0 \(ViteWalletConst.viteToken.symbol)"
        let viewModel = ConfirmViteCallContractViewModel(tokenInfo: tokenInfo, addressString: ViteWalletConst.ContractAddress.defi.address, amountString: amountString, utString: nil)
        confirmWorkflow(viewModel: viewModel, confirmSuccess: sendBlock, confirmFailure: { completion(Result.failure($0)) })
    }

    static func defiSubscribeWithConfirm(account: Wallet.Account,
                                         tokenInfo: TokenInfo,
                                         loanId: UInt64,
                                         shares: UInt64,
                                         completion: @escaping (Result<AccountBlock>) -> ()) {
        let sendBlock = {
            send(account: account,
                 toAddress: ViteWalletConst.ContractAddress.defi.address,
                 tokenId: ViteWalletConst.viteToken.id,
                 amount: 0,
                 fee: nil,
                 data: ABI.BuildIn.getDeFiSubscribeData(loanId: loanId, shares: shares),
                 successToast: R.string.localizable.workflowToastContractSuccess(),
                 type: .other,
                 completion: completion)
        }

        let amountString = "0 \(ViteWalletConst.viteToken.symbol)"
        let viewModel = ConfirmViteCallContractViewModel(tokenInfo: tokenInfo, addressString: ViteWalletConst.ContractAddress.defi.address, amountString: amountString, utString: nil)
        confirmWorkflow(viewModel: viewModel, confirmSuccess: sendBlock, confirmFailure: { completion(Result.failure($0)) })
    }

    static func defiRegisterSBPWithConfirm(account: Wallet.Account,
                                           tokenInfo: TokenInfo,
                                           loanId: UInt64,
                                           amount: Amount,
                                           sbpName: String,
                                           blockProducingAddress: ViteAddress,
                                           rewardWithdrawAddress: ViteAddress,
        completion: @escaping (Result<AccountBlock>) -> ()) {
        let sendBlock = {
            send(account: account,
                 toAddress: ViteWalletConst.ContractAddress.defi.address,
                 tokenId: ViteWalletConst.viteToken.id,
                 amount: 0,
                 fee: nil,
                 data: ABI.BuildIn.getDeFiRegisterSBPData(loanId: loanId, amount: amount, sbpName: sbpName, blockProducingAddress: blockProducingAddress, rewardWithdrawAddress: rewardWithdrawAddress),
                 successToast: R.string.localizable.workflowToastContractSuccess(),
                 type: .other,
                 completion: completion)
        }

        let amountString = "0 \(ViteWalletConst.viteToken.symbol)"
        let viewModel = ConfirmViteCallContractViewModel(tokenInfo: tokenInfo, addressString: ViteWalletConst.ContractAddress.defi.address, amountString: amountString, utString: nil)
        confirmWorkflow(viewModel: viewModel, confirmSuccess: sendBlock, confirmFailure: { completion(Result.failure($0)) })
    }

    static func defiUpdateSBPRegistrationWithConfirm(account: Wallet.Account,
                                                     tokenInfo: TokenInfo,
                                                     investId: UInt64,
                                                     operationCode: UInt8,
                                                     sbpName: String,
                                                     blockProducingAddress: ViteAddress,
                                                     rewardWithdrawAddress: ViteAddress,
                                                     completion: @escaping (Result<AccountBlock>) -> ()) {
        let sendBlock = {
            send(account: account,
                 toAddress: ViteWalletConst.ContractAddress.defi.address,
                 tokenId: ViteWalletConst.viteToken.id,
                 amount: 0,
                 fee: nil,
                 data: ABI.BuildIn.getDeFiUpdateSBPRegistrationData(investId: investId, operationCode: operationCode, sbpName: sbpName, blockProducingAddress: blockProducingAddress, rewardWithdrawAddress: rewardWithdrawAddress),
                 successToast: R.string.localizable.workflowToastContractSuccess(),
                 type: .other,
                 completion: completion)
        }

        let amountString = "0 \(ViteWalletConst.viteToken.symbol)"
        let viewModel = ConfirmViteCallContractViewModel(tokenInfo: tokenInfo, addressString: ViteWalletConst.ContractAddress.defi.address, amountString: amountString, utString: nil)
        confirmWorkflow(viewModel: viewModel, confirmSuccess: sendBlock, confirmFailure: { completion(Result.failure($0)) })
    }

    static func defiInvestWithConfirm(account: Wallet.Account,
                                      tokenInfo: TokenInfo,
                                      loanId: UInt64,
                                      bizType: UInt8,
                                      amount: Amount,
                                      beneficiaryAddress: ViteAddress,
                                      completion: @escaping (Result<AccountBlock>) -> ()) {
        let sendBlock = {
            send(account: account,
                 toAddress: ViteWalletConst.ContractAddress.defi.address,
                 tokenId: ViteWalletConst.viteToken.id,
                 amount: 0,
                 fee: nil,
                 data: ABI.BuildIn.getDeFiInvestData(loanId: loanId, bizType: bizType, amount: amount, beneficiaryAddress: beneficiaryAddress),
                 successToast: R.string.localizable.workflowToastContractSuccess(),
                 type: .other,
                 completion: completion)
        }

        let amountString = "0 \(ViteWalletConst.viteToken.symbol)"
        let viewModel = ConfirmViteCallContractViewModel(tokenInfo: tokenInfo, addressString: ViteWalletConst.ContractAddress.defi.address, amountString: amountString, utString: nil)
        confirmWorkflow(viewModel: viewModel, confirmSuccess: sendBlock, confirmFailure: { completion(Result.failure($0)) })
    }

    static func defiCancelInvestWithConfirm(account: Wallet.Account,
                                            tokenInfo: TokenInfo,
                                            investId: UInt64,
                                            completion: @escaping (Result<AccountBlock>) -> ()) {
        let sendBlock = {
            send(account: account,
                 toAddress: ViteWalletConst.ContractAddress.defi.address,
                 tokenId: ViteWalletConst.viteToken.id,
                 amount: 0,
                 fee: nil,
                 data: ABI.BuildIn.getDeFiCancelInvestData(investId: investId),
                 successToast: R.string.localizable.workflowToastContractSuccess(),
                 type: .other,
                 completion: completion)
        }

        let amountString = "0 \(ViteWalletConst.viteToken.symbol)"
        let viewModel = ConfirmViteCallContractViewModel(tokenInfo: tokenInfo, addressString: ViteWalletConst.ContractAddress.defi.address, amountString: amountString, utString: nil)
        confirmWorkflow(viewModel: viewModel, confirmSuccess: sendBlock, confirmFailure: { completion(Result.failure($0)) })
    }
}
