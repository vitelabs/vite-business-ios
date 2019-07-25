//
//  BuildInContractCoinChangeTokenType.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit

struct BuildInContractCoinChangeTokenType: BuildInContractProtocol {

    let abi = ABI.BuildIn.coinChangeTokenType
    let description = VBViteSendTx.Description(
        function: VBViteSendTx.InputDescription(name: R.string.localizable.buildinCoinChangeToNonissuableFunctionTitle()),
        inputs: [])

    func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
        guard sendTx.block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }
        let title = description.function.title ?? ""
        do {
            let values = try ABI.Decoding.decodeParameters(sendTx.block.data!, abiString: abi.rawValue)
            guard let tokenIdValue = values[0] as? ABITokenIdValue else {
                return Promise(error: ConfirmError.InvalidData)
            }

            return Promise.value(BifrostConfirmInfo(title: title, items: []))
        } catch {
            return Promise(error: ConfirmError.InvalidData)
        }
    }
}
