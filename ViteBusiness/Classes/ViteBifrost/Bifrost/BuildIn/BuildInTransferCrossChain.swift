//
//  BuildInTransferCrossChain.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit
import SwiftyJSON

struct BuildInTransferCrossChain: BuildInTransferProtocol {

    let description = VBViteSendTx.Description(JSONString: "{\"function\":{\"name\":{\"base\":\"Cross-Chain Transfer\",\"zh\":\"跨链转出\"}},\"inputs\":[{\"name\":{\"base\":\"Amount\",\"zh\":\"转出金额\"},\"style\":{\"textColor\":\"007AFF\",\"backgroundColor\":\"007AFF0F\"}},{\"name\":{\"base\":\"Fee\",\"zh\":\"手续费\"}},{\"name\":{\"base\":\"Receive Address\",\"zh\":\"收款地址\"}}]}")!

    func match(_ sendTx: VBViteSendTx) -> Bool {

        if let e = sendTx.extend {
            guard let json = try? JSON(e), json["type"].string == "crossChainTransfer" else {
                return false
            }

            guard let data = sendTx.block.data, data.contentTypeInUInt16 == 0x0bc3 else {
                return false
            }

            return true
        } else {
            return false
        }
    }

    func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {

        guard let e = sendTx.extend, let json = try? JSON(e),
            let feeString = json["fee"].string,
            let feeAmount = Amount(feeString) else {
                return Promise(error: ConfirmError.InvalidExtend)
        }


        let title = description.function.title ?? ""
        guard let data = sendTx.block.data, data.count > 3 else { return Promise(error: ConfirmError.InvalidData) }
        let type = data[2]

        let amount = "\((sendTx.block.amount - feeAmount).amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
        let fee = "\(feeAmount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"

        if type == 0x00 {
            guard let address = String(bytes: data[3...], encoding: .utf8) else { return Promise(error: ConfirmError.InvalidData) }

            let items = [description.inputs[0].confirmItemInfo(text: amount),
                         description.inputs[1].confirmItemInfo(text: fee),
                         description.inputs[2].confirmItemInfo(text: address)
            ]
            return Promise.value(BifrostConfirmInfo(title: title, items: items))
        } else if type == 0x01 {
            let addressSize = Int(UInt8(data[3]))
            let addressOffset: Int = 3 + 1
            guard data.count > addressOffset + addressSize + 1 else { return Promise(error: ConfirmError.InvalidData) }
            guard let address = String(bytes: data[addressOffset..<addressOffset + addressSize], encoding: .utf8) else { return Promise(error: ConfirmError.InvalidData) }
            let labelSize = Int(data[Int(addressOffset + addressSize)])
            let labelOffset: Int = addressOffset + addressSize + 1
            guard data.count == labelOffset + labelSize else { return Promise(error: ConfirmError.InvalidData) }
            guard let label = String(bytes: data[labelOffset..<labelOffset + labelSize], encoding: .utf8) else { return Promise(error: ConfirmError.InvalidData) }

            guard let e = sendTx.extend,
                let json = try? JSON(e),
                let labelNameJson = json["labelTitle"].dictionaryObject,
                let labelNameInputDescription = VBViteSendTx.InputDescription(JSON: labelNameJson) else {
                    return Promise(error: ConfirmError.InvalidExtend)
            }

            let items = [description.inputs[0].confirmItemInfo(text: amount),
                         description.inputs[1].confirmItemInfo(text: fee),
                         description.inputs[2].confirmItemInfo(text: address),
                         labelNameInputDescription.confirmItemInfo(text: label)
            ]
            return Promise.value(BifrostConfirmInfo(title: title, items: items))
        } else {
            return Promise(error: ConfirmError.InvalidData)
        }
    }
}
