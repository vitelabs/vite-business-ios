//
//  BuildInContractCoinIssue.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit

struct BuildInContractCoinIssue: BuildInContractProtocol {

    let abi = ABI.BuildIn.coinReIssue
    let description = VBViteSendTx.Description(
        function: VBViteSendTx.InputDescription(name: R.string.localizable.buildinCoinReissueTokenFunctionTitle()),
        inputs: [
            VBViteSendTx.InputDescription(name: R.string.localizable.buildinCoinReissueTokenItem0Title()),
            VBViteSendTx.InputDescription(name: R.string.localizable.buildinCoinReissueTokenItem1Title()),
            VBViteSendTx.InputDescription(name: R.string.localizable.buildinCoinReissueTokenItem2Title()),
            VBViteSendTx.InputDescription(name: R.string.localizable.buildinCoinReissueTokenItem3Title(), style: VBViteSendTx.InputDescription.Style.blue),
        ])

    func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
        guard sendTx.block.amount == 0 else { return Promise(error: ConfirmError.InvalidAmount) }
        let title = description.function.title ?? ""
        do {
            let values = try ABI.Decoding.decodeParameters(sendTx.block.data!, abiString: abi.rawValue)
            guard let tokenIdValue = values[0] as? ABITokenIdValue else {
                return Promise(error: ConfirmError.InvalidData)
            }

            guard let amountValue = values[1] as? ABIUnsignedIntegerValue else {
                return Promise(error: ConfirmError.InvalidData)
            }

            guard let addressValue = values[2] as? ABIAddressValue else {
                return Promise(error: ConfirmError.InvalidData)
            }

            return TokenInfoCacheService.instance.tokenInfo(forViteTokenId: tokenIdValue.toString())
                .then { tokenInfo -> Promise<BifrostConfirmInfo> in
                    let token = tokenInfo.toViteToken()!
                    let amount = "\(Amount(amountValue.toBigUInt()).amountFullWithGroupSeparator(decimals: token.decimals)) \(token.symbol)"
                    let items = [
                        self.description.inputs[0].confirmItemInfo(text: token.name),
                        self.description.inputs[1].confirmItemInfo(text: token.uniqueSymbol),
                        self.description.inputs[2].confirmItemInfo(text: addressValue.toString()),
                        self.description.inputs[3].confirmItemInfo(text: amount),
                    ]
                    return Promise.value(BifrostConfirmInfo(title: title, items: items))
            }
        } catch {
            return Promise(error: ConfirmError.InvalidData)
        }
    }
}
