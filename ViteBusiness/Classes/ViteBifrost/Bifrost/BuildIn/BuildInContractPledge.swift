//
//  BuildInContractPledge.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit

struct BuildInContractPledge: BuildInContractProtocol {

    let functionSignatureHexString = "8de7dcfd"
    let toAddress = ViteWalletConst.ContractAddress.pledge.rawValue
    let abi = ABI.BuildIn.pledge.rawValue
    let description = VBViteSendTx.Description(JSONString: "{\"function\":{\"name\":{\"base\":\"Acquire Quota\",\"zh\":\"获取配额\"}},\"inputs\":[{\"name\":{\"base\":\"Amount\",\"zh\":\"抵押金额\"}},{\"name\":{\"base\":\"Beneficiary Address\",\"zh\":\"配额受益地址\"}}]}")!

    func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
        let title = description.function.title ?? ""
        do {
            let values = try ABI.Decoding.decodeParameters(sendTx.block.data!, abiString: abi)
            guard let value = values[0] as? ABIAddressValue else {
                return Promise(error: ConfirmError.InvalidData)
            }

            let amount = "\(sendTx.block.amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
            let items = [description.inputs[0].confirmItemInfo(text: amount),
                         description.inputs[1].confirmItemInfo(text: value.toString())
            ]
            return Promise.value(BifrostConfirmInfo(title: title, items: items))
        } catch {
            return Promise(error: ConfirmError.InvalidData)
        }
    }
}
