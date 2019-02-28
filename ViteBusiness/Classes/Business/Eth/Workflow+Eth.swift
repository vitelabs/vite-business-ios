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
        completion: @escaping (Result<AccountBlock>) -> ()) {
        let sendBlock = {
            if token.isEtherCoin {
                do {
                   _ = try EtherWallet.transaction.sendEtherSync(to:toAddress , amount: amount, password: "", gasPrice: gasPrice)
                }catch {

                }
            }else {
                do {
                    _ = try EtherWallet.transaction.sendTokenSync(to: toAddress, contractAddress: token.ethContractAddress, amount:amount, password: "", decimal: 18 ,gasPrice: gasPrice)
                }catch {

                }
            }
        }

        confirmWorkflow(title: R.string.localizable.confirmTransactionPageTitle(),
                        infoTitle: R.string.localizable.confirmTransactionAddressTitle(),
                        info: toAddress.description,
                        token: token.symbol,
                        amount: amount,
                        confirmTitle: R.string.localizable.confirmTransactionPageConfirmButton(),
                        completion: completion,
                        confirmSuccess: sendBlock)
    }
}



