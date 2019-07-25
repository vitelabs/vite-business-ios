//
//  BuildInContractDexWithdraw.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit

struct BuildInContractDexWithdraw: BuildInContractProtocol {

    let abi =  ABI.BuildIn.dexWithdraw
    let description = VBViteSendTx.Description(JSONString: "{\"function\":{\"name\":{\"base\":\"ViteX Withdrawal\",\"zh\":\"交易所提现\"}},\"inputs\":[{\"name\":{\"base\":\"Amount\",\"zh\":\"提现金额\"},\"style\":{\"textColor\":\"007AFF\",\"backgroundColor\":\"007AFF0F\"}}]}")!

    func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
        guard sendTx.block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }
        let title = description.function.title ?? ""
        do {
            let values = try ABI.Decoding.decodeParameters(sendTx.block.data!, abiString: abi.rawValue)
            guard let tokenIdValue = values[0] as? ABITokenIdValue else {
                return Promise(error: ConfirmError.InvalidData)
            }

            guard let amountValue = values[1] as? ABIUnsignedIntegerValue else {
                return Promise(error: ConfirmError.InvalidData)
            }

            return ViteNode.mintage.getToken(tokenId: tokenIdValue.toString()).then({ (token) -> Promise<BifrostConfirmInfo> in
                let amount = "\(Amount(amountValue.toBigUInt()).amountFullWithGroupSeparator(decimals: token.decimals)) \(token.symbol)"
                let items = [self.description.inputs[0].confirmItemInfo(text: amount)
                ]
                return Promise.value(BifrostConfirmInfo(title: title, items: items))
            })
        } catch {
            return Promise(error: ConfirmError.InvalidData)
        }
    }
}
