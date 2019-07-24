//
//  BuildInContractOthers.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit

struct BuildInContractOthers {

    static func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {

        guard let abi = sendTx.abi else { return Promise(error: ConfirmError.InvalidParameters) }
        guard let des = sendTx.description else { return Promise(error: ConfirmError.InvalidParameters) }
        let title = des.function.title ?? ""

        do {
            let addressItem = BifrostConfirmItemInfo(title: R.string.localizable.bifrostOperationTitleContractAddress(),
                                                     text: sendTx.block.toAddress)
            let tokenItem = BifrostConfirmItemInfo(title: R.string.localizable.bifrostOperationTitleTokenSymbol(),
                                                   text: tokenInfo.uniqueSymbol)
            let amountItem = BifrostConfirmItemInfo(title: R.string.localizable.bifrostOperationTitleAmount(),
                                                    text: sendTx.block.amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals))

            guard let abi = sendTx.abi else { return Promise(error: ConfirmError.missingAbi) }
            guard let des = sendTx.description else { return Promise(error: ConfirmError.missingDescription) }

            let values = try ABI.Decoding.decodeParameters(sendTx.block.data!, abiString: abi)
            guard values.count == des.inputs.count else { return Promise(error: ConfirmError.InvalidParameters) }
            var items: [BifrostConfirmItemInfo] = [addressItem, tokenItem, amountItem]

            for i in 0..<values.count {
                let input = des.inputs[i]
                let text = values[i].toString()
                items.append(input.confirmItemInfo(text: text))
            }

            return Promise.value(BifrostConfirmInfo(title: title, items: items))
        } catch {
            return Promise(error: ConfirmError.InvalidData)
        }
    }
}
