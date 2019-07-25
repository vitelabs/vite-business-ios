//
//  BuildInContractDexDeposit.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit

struct BuildInContractDexDeposit: BuildInContractProtocol {

    let abi =  ABI.BuildIn.dexDeposit
    let description = VBViteSendTx.Description(JSONString: "{\"function\":{\"name\":{\"base\":\"ViteX Deposit\",\"zh\":\"交易所充值\"}},\"inputs\":[{\"name\":{\"base\":\"Amount\",\"zh\":\"充值金额\"},\"style\":{\"textColor\":\"007AFF\",\"backgroundColor\":\"007AFF0F\"}}]}")!

    func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
        let title = description.function.title ?? ""
        let amount = "\(sendTx.block.amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
        let items = [description.inputs[0].confirmItemInfo(text: amount)
        ]
        return Promise.value(BifrostConfirmInfo(title: title, items: items))
    }
}
