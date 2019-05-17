//
//  Workflow+Eth.swift
//  Action
//
//  Created by Water on 2019/2/25.
//

import ViteEthereum
import Web3swift
import ViteWallet
import BigInt
import PromiseKit
import enum Alamofire.Result

public extension Workflow {

    static func ethViteExchangeWithConfirm(viteAddress: String,
                                           amount: Amount,
                                           gasPrice: Float,
                                           completion: @escaping (Result<String>) -> ()) {
        let tokenInfo = TokenInfo.viteERC20
        let amountString = "\(amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
        let gasLimit = EtherWallet.defaultGasLimitForTokenTransfer
        let feeString = gasPrice.ethGasFeeDisplay(Float(gasLimit))

        let viewModel = ConfirmEthViteExchangeViewModel(tokenInfo: tokenInfo, addressString: viteAddress, amountString: amountString, feeString: feeString)
        confirmWorkflow(viewModel: viewModel, confirmSuccess: {

            let blackHoleAddress = "0x1111111111111111111111111111111111111111"
            firstly(execute: { () -> Promise<WriteTransaction> in
                HUD.show()
                return EtherWallet.transaction.getSendTokenTransaction(to: blackHoleAddress, amount: amount, gasPrice: nil,
                                                                       contractAddress: TokenInfo.viteERC20ContractAddress)
            }).then({ (wt) -> Promise<(WriteTransaction, String)> in
                EtherWallet.transaction.getTransactionHash(wt).map { (wt, $0) }
            }).then({ (wt, hash) -> Promise<(WriteTransaction)> in
                guard let key = EtherWallet.account.privateKey,
                    let ethAddress = EtherWallet.account.address,
                    let viteAddress = HDWalletManager.instance.account?.address,
                    let context = GatewayBindContext(ethPrivateKey: key,
                                                     ethTxHash: hash,
                                                     ethAddress: ethAddress,
                                                     viteAddress: viteAddress,
                                                     value: amount) else {
                                                        throw WalletError.unexpectedResult
                }
                return GatewayProvider.instance.bind(context).map { _ in wt }
            }).then({ (wt) -> Promise<TransactionSendingResult> in
                EtherWallet.transaction.sendTransaction(wt)
            }).done({ (ret) in
                completion(Result.success(ret.hash))
            }).catch({ (error) in
                plog(level: .warning, log: error.viteErrorMessage, tag: .exchange)
                completion(Result.failure(error))
            }).finally {
                HUD.hide()
            }
        }, confirmFailure: {
            completion(Result.failure($0))
        })
    }


    static func sendEthTransactionWithConfirm(toAddress: String,
                                              tokenInfo: TokenInfo,
                                              amount: Amount,
                                              gasPrice: Float,
                                              completion: @escaping (Result<String>) -> ()) {
        let sendBlock = {
            HUD.show()
            let g = BigInt(Web3.Utils.parseToBigUInt(String(gasPrice), units: .Gwei)!)
            let promise: Promise<String>
            if tokenInfo.isEtherCoin {
                promise = EtherWallet.transaction.sendEther(to: toAddress, amount: amount, gasPrice: g)
            } else {
                promise = EtherWallet.transaction.sendToken(to: toAddress, amount: amount, gasPrice: g, contractAddress: tokenInfo.ethContractAddress)
            }

            promise
                .always {
                    HUD.hide()
                }
                .done({ txHash in
                    completion(Result.success(txHash))
                    AlertControl.showCompletion(R.string.localizable.workflowToastTransferSuccess())
                })
                .catch({ error in
                    completion(Result.failure(error))
                })
        }

        let amountString = "\(amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
        let gasLimit = tokenInfo.isEtherCoin ? EtherWallet.defaultGasLimitForEthTransfer: EtherWallet.defaultGasLimitForTokenTransfer
        let feeString = gasPrice.ethGasFeeDisplay(Float(gasLimit))

        let viewModel = ConfirmEthTransactionViewModel(tokenInfo: tokenInfo, addressString: toAddress, amountString: amountString, feeString: feeString)
        confirmWorkflow(viewModel: viewModel, confirmSuccess: sendBlock, confirmFailure: { completion(Result.failure($0)) })
    }
}
