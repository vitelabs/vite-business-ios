//
//  BuildInContractOldCancelStake.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit

struct BuildInContractOldCancelStake: BuildInContractProtocol {

    let abi = ABI.BuildIn.old_cancelStake
    let description = VBViteSendTx.Description(JSONString: "{\"function\":{\"name\":{\"base\":\"Retrieve Staking for Quota\",\"zh\":\"取回配额抵押\"}},\"inputs\":[{\"name\":{\"base\":\"Amount\",\"zh\":\"取回抵押金额\"}}]}")!

    func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
        guard sendTx.block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }
        let title = description.function.title ?? ""
        do {
            let values = try ABI.Decoding.decodeParameters(sendTx.block.data!, abiString: abi.rawValue)
            guard let addressValue = values[0] as? ABIAddressValue else {
                return Promise(error: ConfirmError.InvalidData)
            }

            guard let amountValue = values[1] as? ABIUnsignedIntegerValue else {
                return Promise(error: ConfirmError.InvalidData)
            }

            let amount = "\(Amount(amountValue.toBigUInt()).amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
            let items = [description.inputs[0].confirmItemInfo(text: amount)
            ]
            return Promise.value(BifrostConfirmInfo(title: title, items: items))
        } catch {
            return Promise(error: ConfirmError.InvalidData)
        }
    }
}
