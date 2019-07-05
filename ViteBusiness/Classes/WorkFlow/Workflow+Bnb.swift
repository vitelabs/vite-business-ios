//
//  Workflow+Bnb.swift
//  Action
//
//  Created by Water on 2019/7/4.
//

import ViteWallet
import BigInt
import PromiseKit
import enum Alamofire.Result

public extension Workflow {
    static func sendBnbTransactionWithConfirm(toAddress: String,
                                              tokenInfo: TokenInfo,
                                              amount: Double,
                                              fee: Float,
                                              completion: @escaping (Result<String>) -> ()) {
//        let sendBlock = {
//            HUD.show()
//            let g = BigInt(Web3.Utils.parseToBigUInt(String(gasPrice), units: .Gwei)!)
//            let promise: Promise<String>
//
//            
//
//            //send
//            if tokenInfo.isEtherCoin {
//                promise = EtherWallet.transaction.sendEther(to: toAddress, amount: amount, gasPrice: g)
//            } else {
//                promise = EtherWallet.transaction.sendToken(to: toAddress, amount: amount, gasPrice: g, contractAddress: tokenInfo.ethContractAddress)
//            }
//
//            promise
//                .always {
//                    HUD.hide()
//                }
//                .done({ txHash in
//                    completion(Result.success(txHash))
//                    AlertControl.showCompletion(R.string.localizable.workflowToastTransferSuccess())
//                })
//                .catch({ error in
//                    completion(Result.failure(error))
//                })
//        }
//
//        let amountString = "\(amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
//        let gasLimit = tokenInfo.isEtherCoin ? EtherWallet.defaultGasLimitForEthTransfer: EtherWallet.defaultGasLimitForTokenTransfer
//        let feeString = gasPrice.ethGasFeeDisplay(Float(gasLimit))
//
//        let viewModel = ConfirmBnbTransactionViewModel(tokenInfo: tokenInfo, addressString: toAddress, amountString: amountString, feeString: feeString)
//        confirmWorkflow(viewModel: viewModel, confirmSuccess: sendBlock, confirmFailure: { completion(Result.failure($0)) })
    }
}

