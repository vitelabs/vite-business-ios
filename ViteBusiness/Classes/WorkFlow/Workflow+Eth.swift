//
//  Workflow+Eth.swift
//  Action
//
//  Created by Water on 2019/2/25.
//

import web3swift
import ViteWallet
import BigInt
import PromiseKit
import enum Alamofire.Result

public extension Workflow {

    static func ethViteExchangeWithConfirm(viteAddress: String,
                                           amount: Amount,
                                           gasPrice: Float,
                                           completion: @escaping (Result<String>) -> ()) {
        guard let account = ETHWalletManager.instance.account else {
            completion(.failure(WalletError.accountDoesNotExist))
            return
        }

        let tokenInfo = TokenInfo.BuildIn.eth_vite.value
        let amountString = "\(amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
        let gasLimit = ETHWalletManager.defaultGasLimitForTokenTransfer
        let feeString = gasPrice.ethGasFeeDisplay(Float(gasLimit))

        let viewModel = ConfirmEthViteExchangeViewModel(tokenInfo: tokenInfo, addressString: viteAddress, amountString: amountString, feeString: feeString)
        confirmWorkflow(viewModel: viewModel, confirmSuccess: {

            let blackHoleAddress = "0x1111111111111111111111111111111111111111"
            firstly(execute: { () -> Promise<WriteTransaction> in
                HUD.show()
                return account.getSendTokenTransaction(to: blackHoleAddress, amount: amount, gasPrice: nil,
                                                                       contractAddress: TokenInfo.viteERC20ContractAddress)
            }).then({ (wt) -> Promise<(WriteTransaction, String)> in
                account.getTransactionHash(wt).map { (wt, $0) }
            }).then({ (wt, hash) -> Promise<(WriteTransaction)> in
                guard let context = GatewayBindContext(ethPrivateKey: account.privateKey,
                                                     ethTxHash: hash,
                                                     ethAddress: account.address,
                                                     viteAddress: viteAddress,
                                                     value: amount) else {
                                                        throw WalletError.unexpectedResult
                }
                return GatewayProvider.instance.bind(context)
                    .recover({ (error) -> Promise<(Void)> in
                        if let e = error as? GatewayProvider.GatewayError,
                            e == GatewayProvider.GatewayError.repeatBinding {
                            return Promise.value(Void())
                        } else {
                            return Promise(error: error)
                        }
                }).map { _ in wt }
            }).then({ (wt) -> Promise<TransactionSendingResult> in
                account.sendTransaction(wt)
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
        guard let account = ETHWalletManager.instance.account else {
            completion(.failure(WalletError.accountDoesNotExist))
            return
        }

        let sendBlock = {
            HUD.show()
            let g = BigInt(Web3.Utils.parseToBigUInt(String(gasPrice), units: .Gwei)!)
            let promise: Promise<String>
            if tokenInfo.isEtherCoin {
                promise = account.sendEther(to: toAddress, amount: amount, gasPrice: g)
            } else {
                promise = account.sendToken(to: toAddress, amount: amount, gasPrice: g, contractAddress: tokenInfo.ethContractAddress)
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
        let gasLimit = tokenInfo.isEtherCoin ? ETHWalletManager.defaultGasLimitForEthTransfer: ETHWalletManager.defaultGasLimitForTokenTransfer
        let feeString = gasPrice.ethGasFeeDisplay(Float(gasLimit))

        let viewModel = ConfirmEthTransactionViewModel(tokenInfo: tokenInfo, addressString: toAddress, amountString: amountString, feeString: feeString)
        confirmWorkflow(viewModel: viewModel, confirmSuccess: sendBlock, confirmFailure: { completion(Result.failure($0)) })
    }
}
