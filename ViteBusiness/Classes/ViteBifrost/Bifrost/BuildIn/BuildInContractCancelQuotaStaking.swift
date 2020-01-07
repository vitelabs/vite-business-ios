//
//  BuildInContractCancelQuotaStaking.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit

struct BuildInContractCancelQuotaStaking: BuildInContractProtocol {

    let abi = ABI.BuildIn.cancelQuotaStaking
    let description = VBViteSendTx.Description(JSONString: "{\"function\":{\"name\":{\"base\":\"Retrieve Staking for Quota\",\"zh\":\"取回配额抵押\"}},\"inputs\":[{\"name\":{\"base\":\"ID\",\"zh\":\"ID\"}}]}")!

    func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
        guard sendTx.block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }
        let title = description.function.title ?? ""
        do {
            let values = try ABI.Decoding.decodeParameters(sendTx.block.data!, abiString: abi.rawValue)
            guard let id = values[0] as? ABIBytesValue else {
                return Promise(error: ConfirmError.InvalidData)
            }
            let idStr = id.toHexString()
            let items = [description.inputs[0].confirmItemInfo(text: idStr)
            ]
            return Promise.value(BifrostConfirmInfo(title: title, items: items))
        } catch {
            return Promise(error: ConfirmError.InvalidData)
        }
    }
}

