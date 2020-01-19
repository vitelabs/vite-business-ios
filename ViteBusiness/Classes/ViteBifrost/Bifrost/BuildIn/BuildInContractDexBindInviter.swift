//
//  BuildInContractDexBindInviter.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit

struct BuildInContractDexBindInviter: BuildInContractProtocol {

    let abi = ABI.BuildIn.dexBindInviteCode
    let description = VBViteSendTx.Description(JSONString: "{\"function\":{\"name\":{\"base\":\"Use Referral Code\",\"zh\":\"使用邀请码\"}},\"inputs\":[{\"name\":{\"base\":\"Beneficiary Address\",\"zh\":\"接受邀请地址\"}},{\"name\":{\"base\":\"Referral Code\",\"zh\":\"邀请码\"}}]}")!

    func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
        guard let account = HDWalletManager.instance.account else { return Promise(error: ConfirmError.unknown("not logon")) }
        guard sendTx.block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }
        let title = description.function.title ?? ""
        do {

            let values = try ABI.Decoding.decodeParameters(sendTx.block.data!, abiString: abi.rawValue)
            guard let codeValue = values[0] as? ABIUnsignedIntegerValue else {
                return Promise(error: ConfirmError.InvalidData)
            }
            let items = [description.inputs[0].confirmItemInfo(text: account.address),
                         description.inputs[1].confirmItemInfo(text: codeValue.toString())
            ]
            return Promise.value(BifrostConfirmInfo(title: title, items: items))
        } catch {
            return Promise(error: ConfirmError.InvalidData)
        }
    }
}
