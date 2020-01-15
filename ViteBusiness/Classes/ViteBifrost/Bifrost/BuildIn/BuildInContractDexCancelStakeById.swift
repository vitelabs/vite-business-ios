//
//  BuildInContractDexCancelStakeById.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit
import SwiftyJSON

struct BuildInContractDexCancelStakeById: BuildInContractProtocol {

    let abi = ABI.BuildIn.dexCancelStakeById

    func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
        guard let account = HDWalletManager.instance.account else { return Promise(error: ConfirmError.unknown("not logon")) }
        guard sendTx.block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }
        do {
            let values = try ABI.Decoding.decodeParameters(sendTx.block.data!, abiString: abi.rawValue)
            guard let id = values[0] as? ABIBytesValue else {
                return Promise(error: ConfirmError.InvalidData)
            }
            let description = VBViteSendTx.Description(function: VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexCancelStakeFunctionTitle()), inputs: [VBViteSendTx.InputDescription(name: R.string.localizable.buildinDexCancelStakeItem0Title())])
            let items = [description.inputs[0].confirmItemInfo(text: account.address)]
            return Promise.value(BifrostConfirmInfo(title: description.function.title ?? "", items: items))
        } catch {
            return Promise(error: ConfirmError.InvalidData)
        }
    }
}
