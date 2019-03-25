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
        completion: @escaping (ViteWallet.Result<String>) -> ()) {
        let sendBlock = {
             HUD.show()
            if token.isEtherCoin {
                EtherWallet.transaction.sendEther(to: toAddress, amount: amount, password: "", gasPrice: gasPrice, completion: { (result) in
                    HUD.hide()
                    switch result {
                    case .success(let txHash):
                            completion(ViteWallet.Result(value: txHash))
                    AlertControl.showCompletion(R.string.localizable.sendPageToastSendTransferSuccess())
                    case .failure(let error):
                        completion(ViteWallet.Result(error: error))
                        break
                    }
                })
            }else {
                EtherWallet.transaction.sendToken(to: toAddress, contractAddress: token.ethContractAddress, amount: amount, password: "", decimal: token.decimals, gasPrice: gasPrice, completion: { (result) in
                    HUD.hide()
                    switch result {
                    case .success(let txHash):
                        completion(ViteWallet.Result(value: txHash))
                        AlertControl.showCompletion(R.string.localizable.sendPageToastSendTransferSuccess())
                    case .failure(let error):
                        completion(ViteWallet.Result(error: error))
                        break
                    }
                })
            }
        }

        //TODO::: no use block
        let block = { (r:ViteWallet.Result<AccountBlock>) in

        }

        let amountString = "\(amount) \(token.symbol)"

        let gasLimit = token.isEtherCoin ? EtherWallet.shared.defaultGasLimitForEthTransfer: EtherWallet.shared.defaultGasLimitForTokenTransfer
        let feeString = gasPrice.ethGasFeeDisplay(Float(gasLimit))

        let viewModel = ConfirmEthTransactionViewModel(tokenInfo: token, addressString: toAddress, amountString: amountString, feeString: feeString)
        confirmWorkflow(viewModel: viewModel, completion: block, confirmSuccess: sendBlock)
    }
}
