//
//  BuildInContractRegister.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit

struct BuildInContractRegister: BuildInContractProtocol {

    let functionSignatureHexString = "f29c6ce2"
    let toAddress = ViteWalletConst.ContractAddress.consensus.rawValue
    let abi = ABI.BuildIn.register.rawValue
    let description = VBViteSendTx.Description(JSONString: "{\"function\":{\"name\":{\"base\":\"Register SBP\",\"zh\":\"注册 SBP\"}},\"inputs\":[{\"name\":{\"base\":\"SBP Name\",\"zh\":\"SBP 名称\"}},{\"name\":{\"base\":\"Amount\",\"zh\":\"抵押金额\"}}]}")!

    func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
        let title = description.function.title ?? ""
        do {
            let values = try ABI.Decoding.decodeParameters(sendTx.block.data!, abiString: abi)
            guard let gidValue = values[0] as? ABIGIdValue else {
                return Promise(error: ConfirmError.InvalidData)
            }
            guard let nameValue = values[1] as? ABIStringValue else {
                return Promise(error: ConfirmError.InvalidData)
            }
            guard let addressValue = values[2] as? ABIAddressValue else {
                return Promise(error: ConfirmError.InvalidData)
            }
            let amount = "\(sendTx.block.amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
            let items = [description.inputs[0].confirmItemInfo(text: nameValue.toString()),
                         description.inputs[1].confirmItemInfo(text: amount)
            ]
            return Promise.value(BifrostConfirmInfo(title: title, items: items))
        } catch {
            return Promise(error: ConfirmError.InvalidData)
        }
    }
}
