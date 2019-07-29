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

        let title = sendTx.description?.function.title ?? R.string.localizable.bifrostOperationFunctionTitle()

        do {
            let addressItem = BifrostConfirmItemInfo(title: R.string.localizable.bifrostOperationTitleContractAddress(),
                                                     text: sendTx.block.toAddress)
            let tokenItem = BifrostConfirmItemInfo(title: R.string.localizable.bifrostOperationTitleTokenSymbol(),
                                                   text: tokenInfo.uniqueSymbol)
            let amountItem = BifrostConfirmItemInfo(title: R.string.localizable.bifrostOperationTitleAmount(),
                                                    text: sendTx.block.amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals))
            let dataItem = BifrostConfirmItemInfo(title: R.string.localizable.bifrostOperationTitleData(),
                                                  text: sendTx.block.data?.base64EncodedString() ?? "")

            if let abi = sendTx.abi {
                let values = try ABI.Decoding.decodeParameters(sendTx.block.data!, abiString: abi)

                if let des = sendTx.description {
                    guard values.count == des.inputs.count else { return Promise(error: ConfirmError.InvalidParameters) }
                    var items: [BifrostConfirmItemInfo] = [addressItem, tokenItem, amountItem]

                    for i in 0..<values.count {
                        let input = des.inputs[i]
                        let text = values[i].toString()
                        items.append(input.confirmItemInfo(text: text))
                    }

                    return Promise.value(BifrostConfirmInfo(title: title, items: items))
                } else {
                    guard let abiRecord = ABI.Record.tryToConvertToFunctionRecord(abiString: abi) else {
                        return Promise(error: ConfirmError.InvalidAbi)
                    }

                    var items: [BifrostConfirmItemInfo] = [addressItem, tokenItem, amountItem]
                    for i in 0..<values.count {
                        let info = BifrostConfirmItemInfo(title: abiRecord.inputs?[i].name ?? "",
                                                          text: values[i].toString())
                        items.append(info)
                    }

                    return Promise.value(BifrostConfirmInfo(title: title, items: items))
                }
            } else {
                return Promise.value(BifrostConfirmInfo(title: title, items: [addressItem, tokenItem, amountItem, dataItem]))
            }
        } catch {
            return Promise(error: ConfirmError.InvalidData)
        }
    }
}
