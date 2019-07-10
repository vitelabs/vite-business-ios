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

import BinanceChain

public extension Workflow {
    static func sendBnbTransactionWithConfirm(toAddress: String,
                                              tokenInfo: TokenInfo,
                                              amount: Double,
                                              fee: Double,
                                              completion: @escaping (Result<String>) -> ()) {
        let sendBlock = {
            HUD.show()
            let promise: Promise<[Transaction]>
            //send
            promise = BnbWallet.shared.sendTransactionPromise(toAddress: toAddress, amount: amount, symbol: tokenInfo.tokenCode)

            promise
                .always {
                    HUD.hide()
                }
                .done({ txHash in
                    guard let result = txHash.first else {
                        return
                    }
                    completion(Result.success(result.hash))
                    AlertControl.showCompletion(R.string.localizable.workflowToastTransferSuccess())
                })
                .catch({ error in
                    completion(Result.failure(error))
                })
        }

        var amountString = "\(amount) \(tokenInfo.symbol)"

        var feeStr = "\(fee)"
        var rateFee = ""
        if let rateFeeStr =  ExchangeRateManager.instance.calculateBalanceWithBnbRate(fee) {
            rateFee = String(format: "≈%@",rateFeeStr)
        }
        let feeString = String(format: "%@ BNB %@", feeStr,rateFee)

        let viewModel = ConfirmBnbTransactionViewModel(tokenInfo: tokenInfo, addressString: toAddress, amountString: amountString, feeString: feeString)
        confirmWorkflow(viewModel: viewModel, confirmSuccess: sendBlock, confirmFailure: { completion(Result.failure($0)) })
    }
}

