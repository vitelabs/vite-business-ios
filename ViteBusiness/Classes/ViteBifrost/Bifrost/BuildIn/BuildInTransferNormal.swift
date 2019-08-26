//
//  BuildInTransferNormal.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/24.
//

import ViteWallet
import PromiseKit
import SwiftyJSON

struct BuildInTransferNormal: BuildInTransferProtocol {

    let description = VBViteSendTx.Description(
        function: VBViteSendTx.InputDescription(name: R.string.localizable.buildinTransferUtf8stringFunctionTitle()),
        inputs: [
            VBViteSendTx.InputDescription(name: R.string.localizable.buildinTransferUtf8stringItem0Title()),
            VBViteSendTx.InputDescription(name: R.string.localizable.buildinTransferUtf8stringItem1Title(), style: VBViteSendTx.InputDescription.Style.blue),
            VBViteSendTx.InputDescription(name: R.string.localizable.buildinTransferUtf8stringItem2Title()),
        ])

    func match(_ sendTx: VBViteSendTx) -> Bool {

        if let data = sendTx.block.data, !data.isEmpty {
            guard data.contentTypeInUInt16 == AccountBlockDataContentType.utf8string.rawValue else {
                return false
            }
        }

        if let e = sendTx.extend {
            guard let json = try? JSON(e) else {
                return false
            }
            guard json["type"].string == nil else {
                return false
            }
            return true
        } else {
            return true
        }
    }

    func confirmInfo(_ sendTx: VBViteSendTx, _ tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
        let title = description.function.title ?? ""
        let amount = "\(sendTx.block.amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
        let items = [description.inputs[0].confirmItemInfo(text: sendTx.block.toAddress),
                     description.inputs[1].confirmItemInfo(text: amount),
                     description.inputs[2].confirmItemInfo(text: sendTx.block.data?.toAccountBlockNote ?? "")
        ]
        return Promise.value(BifrostConfirmInfo(title: title, items: items))
    }
}
