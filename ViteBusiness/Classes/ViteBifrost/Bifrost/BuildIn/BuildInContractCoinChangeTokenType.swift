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
        inputs: [
            VBViteSendTx.InputDescription(name: R.string.localizable.buildinCoinChangeToNonissuableItem0Title()),
            VBViteSendTx.InputDescription(name: R.string.localizable.buildinCoinChangeToNonissuableItem1Title()),
        ])

    func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
        guard sendTx.block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }
        let title = description.function.title ?? ""
        do {
            let values = try ABI.Decoding.decodeParameters(sendTx.block.data!, abiString: abi.rawValue)
            guard let tokenIdValue = values[0] as? ABITokenIdValue else {
                return Promise(error: ConfirmError.InvalidData)
            }

            return TokenInfoCacheService.instance.tokenInfo(forViteTokenId: tokenIdValue.toString())
                .then { tokenInfo -> Promise<BifrostConfirmInfo> in
                    let token = tokenInfo.toViteToken()!
                    let items = [
                        self.description.inputs[0].confirmItemInfo(text: token.name),
                        self.description.inputs[1].confirmItemInfo(text: token.uniqueSymbol),
                    ]
                    return Promise.value(BifrostConfirmInfo(title: title, items: items))
            }
        } catch {
            return Promise(error: ConfirmError.InvalidData)
        }
    }
}
