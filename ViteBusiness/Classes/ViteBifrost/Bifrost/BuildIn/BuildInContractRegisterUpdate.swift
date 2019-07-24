//
//  BuildInContractRegisterUpdate.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit

struct BuildInContractRegisterUpdate: BuildInContractProtocol {

    let functionSignatureHexString = "3b7bdf74"
    let toAddress = ViteWalletConst.ContractAddress.consensus.rawValue
    let abi = ABI.BuildIn.registerUpdate.rawValue
    let description = VBViteSendTx.Description(JSONString: "{\"function\":{\"name\":{\"base\":\"Update SBP\",\"zh\":\"更新 SBP\"}},\"inputs\":[{\"name\":{\"base\":\"Update Address\",\"zh\":\"更新地址\"}}]}")!

    func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
        guard sendTx.block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }
        let title = description.function.title ?? ""
        do {
            let values = try ABI.Decoding.decodeParameters(sendTx.block.data!, abiString: abi)
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
