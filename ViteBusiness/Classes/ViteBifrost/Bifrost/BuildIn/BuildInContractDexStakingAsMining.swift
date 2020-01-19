//
//  BuildInContractDexStakingAsMining.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit
import SwiftyJSON

struct BuildInContractDexStakingAsMining: BuildInContractProtocol {

    let abi =  ABI.BuildIn.dexStakeForMining

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

            let description: VBViteSendTx.Description
            if typeValue.toBigUInt() == 1 {
                description = VBViteSendTx.Description(
                    function: VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexStakingAsMiningFunctionTitle()),
                    inputs: [
                        VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexStakingAsMiningItem0Title()),
                        VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexStakingAsMiningItem1Title()),
                    ])
            } else if typeValue.toBigUInt() == 2 {
                description = VBViteSendTx.Description(
                    function: VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexCancelStakingAsMiningFunctionTitle()),
                    inputs: [
                        VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexCancelStakingAsMiningItem0Title()),
                        VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexCancelStakingAsMiningItem1Title()),
                    ])
            } else {
                return Promise(error: ConfirmError.InvalidData)
            }
            
            let amount = "\(Amount(amountValue.toBigUInt()).amountFullWithGroupSeparator(decimals: ViteWalletConst.viteToken.decimals)) \(ViteWalletConst.viteToken.symbol)"

            let items = [description.inputs[0].confirmItemInfo(text: account.address),
                         description.inputs[1].confirmItemInfo(text: amount)
            ]
            return Promise.value(BifrostConfirmInfo(title: description.function.title ?? "", items: items))
        } catch {
            return Promise(error: ConfirmError.InvalidData)
        }
    }
}
