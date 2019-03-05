//
//  Workflow+Eth.swift
//  Action
//
//  Created by Water on 2019/2/25.
//

import ViteEthereum
import web3swift
import ViteWallet
import BigInt

public extension Workflow {
    static func sendEthTransactionWithConfirm(
        toAddress: String,
        token: TokenInfo,
        amount: String,
        gasPrice: Float,
        completion: @escaping (Result<String>) -> ()) {
        let sendBlock = {
             HUD.show()
            if token.isEtherCoin {
                   EtherWallet.transaction.sendEther(to: toAddress, amount: amount, password: "", completion: { (r ) in
                        guard let result = r else{
                            completion(Result(error: ViteError.authFailed))
                            HUD.hide()
                            return
                        }
                        completion(Result(value: result))
                        AlertControl.showCompletion(R.string.localizable.sendPageToastSendSuccess())
                        HUD.hide()
                    })
            }else {
                EtherWallet.transaction.sendToken(to: toAddress, contractAddress: token.ethContractAddress, amount: amount, password: "", decimal: token.decimals, gasPrice: gasPrice, completion: { (r) in
                    guard let result = r else{
                        completion(Result(error: ViteError.authFailed))
                        HUD.hide()
                        return
                    }
                    completion(Result(value: result))
                    AlertControl.showCompletion(R.string.localizable.sendPageToastSendSuccess())
                    HUD.hide()
                })
            }
        }

        //TODO::: no use block
        let block = { (r:Result<AccountBlock>) in

        }

        confirmWorkflow(title: R.string.localizable.confirmTransactionPageTitle(),
                        infoTitle: R.string.localizable.confirmTransactionAddressTitle(),
                        info: toAddress.description,
                        token: token.symbol,
                        amount: amount,
                        confirmTitle: R.string.localizable.confirmTransactionPageConfirmButton(),
                        completion: block,
                        confirmSuccess: sendBlock)
    }
}
