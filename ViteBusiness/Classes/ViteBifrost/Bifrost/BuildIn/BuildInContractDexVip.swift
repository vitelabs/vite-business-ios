//
//  BuildInContractDexVip.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit
import SwiftyJSON

struct BuildInContractDexVip: BuildInContractProtocol {

    let abi =  ABI.BuildIn.dexStakeForVIP

    func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
        guard let account = HDWalletManager.instance.account else { return Promise(error: ConfirmError.unknown("not logon")) }
        guard sendTx.block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }
        do {

            guard let e = sendTx.extend, let json = try? JSON(e), json["type"].string == "dexFundPledgeForVip",
                let amount = json["amount"].string else {
                    return Promise(error: ConfirmError.InvalidExtend)
            }

            let values = try ABI.Decoding.decodeParameters(sendTx.block.data!, abiString: abi.rawValue)
            guard let typeValue = values[0] as? ABIUnsignedIntegerValue else {
                return Promise(error: ConfirmError.InvalidData)
            }

            let description: VBViteSendTx.Description
            if typeValue.toBigUInt() == 1 {
                description = VBViteSendTx.Description(
                    function: VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexBecomeVipFunctionTitle()),
                    inputs: [
                        VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexBecomeVipItem0Title()),
                        VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexBecomeVipItem1Title()),
                    ])
            } else if typeValue.toBigUInt() == 2 {
                description = VBViteSendTx.Description(
                    function: VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexCancelVipFunctionTitle()),
                    inputs: [
                        VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexCancelVipItem0Title()),
                        VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexCancelVipItem1Title()),
                    ])
            } else {
                return Promise(error: ConfirmError.InvalidData)
            }

            let items = [description.inputs[0].confirmItemInfo(text: account.address),
                         description.inputs[1].confirmItemInfo(text: amount)
            ]
            return Promise.value(BifrostConfirmInfo(title: description.function.title ?? "", items: items))
        } catch {
            return Promise(error: ConfirmError.InvalidData)
        }
    }
}
