//
//  BuildInContractCancelRegister.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit

struct BuildInContractCancelRegister: BuildInContractProtocol {

    let abi = ABI.BuildIn.old_cancelRegister
    let description = VBViteSendTx.Description(JSONString: "{\"function\":{\"name\":{\"base\":\"Revoke SBP Registration\",\"zh\":\"撤销 SBP 注册\"}},\"inputs\":[{\"name\":{\"base\":\"SBP Name\",\"zh\":\"SBP名称\"}}]}")!

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
            let items = [description.inputs[0].confirmItemInfo(text: nameValue.toString())
            ]
            return Promise.value(BifrostConfirmInfo(title: title, items: items))
        } catch {
            return Promise(error: ConfirmError.InvalidData)
        }

    }
}
