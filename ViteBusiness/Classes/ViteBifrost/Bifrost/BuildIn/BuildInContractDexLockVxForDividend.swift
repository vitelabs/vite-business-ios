//
//  BuildInContractDexLockVxForDividend.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit
import SwiftyJSON

struct BuildInContractDexLockVxForDividend: BuildInContractProtocol {

    let abi =  ABI.BuildIn.dexLockVxForDividend

    func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
        guard let account = HDWalletManager.instance.account else { return Promise(error: ConfirmError.unknown("not logon")) }
        guard sendTx.block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }
        do {

            let values = try ABI.Decoding.decodeParameters(sendTx.block.data!, abiString: abi.rawValue)
            guard let typeValue = values[0] as? ABIUnsignedIntegerValue else {
                return Promise(error: ConfirmError.InvalidData)
            }

            guard let amountValue = values[1] as? ABIUnsignedIntegerValue else {
                return Promise(error: ConfirmError.InvalidData)
            }

            let token = TokenInfo.BuildIn.vx.value.toViteToken()!
            let amount = "\(Amount(amountValue.toBigUInt()).amountFullWithGroupSeparator(decimals: token.decimals)) \(token.symbol)"

            let description: VBViteSendTx.Description
            if typeValue.toBigUInt() == 1 {
                description = VBViteSendTx.Description(
                    function: VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexLockVxFunctionTitle()),
                    inputs: [
                        VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexLockVxItem0Title()),
                        VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexLockVxItem1Title()),
                    ])
            } else if typeValue.toBigUInt() == 2 {
                description = VBViteSendTx.Description(
                    function: VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexUnLockVxFunctionTitle()),
                    inputs: [
                        VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexUnLockVxItem0Title()),
                        VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexUnLockVxItem1Title()),
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
