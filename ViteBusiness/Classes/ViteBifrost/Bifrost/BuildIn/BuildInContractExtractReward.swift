//
//  BuildInContractExtractReward.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit

struct BuildInContractExtractReward: BuildInContractProtocol {

    let abi = ABI.BuildIn.withdrawSBPReward
    let description = VBViteSendTx.Description(JSONString: "{\"function\":{\"name\":{\"base\":\"Claim Rewards\",\"zh\":\"提取奖励\"}},\"inputs\":[{\"name\":{\"base\":\"Recipient Address\",\"zh\":\"收款地址\"}}]}")!

    func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
        guard sendTx.block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }
        let title = description.function.title ?? ""
        do {
            let values = try ABI.Decoding.decodeParameters(sendTx.block.data!, abiString: abi.rawValue)
            guard let gidValue = values[0] as? ABIGIdValue else {
                return Promise(error: ConfirmError.InvalidData)
            }
            guard let nameValue = values[1] as? ABIStringValue else {
                return Promise(error: ConfirmError.InvalidData)
            }
            guard let addressValue = values[2] as? ABIAddressValue else {
                return Promise(error: ConfirmError.InvalidData)
            }
            let items = [description.inputs[0].confirmItemInfo(text: addressValue.toString())
            ]
            return Promise.value(BifrostConfirmInfo(title: title, items: items))
        } catch {
            return Promise(error: ConfirmError.InvalidData)
        }
    }
}
