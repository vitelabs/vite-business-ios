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

    func match(_ sendTx: VBViteSendTx) -> Bool {

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

        let note: String?
        if let data = sendTx.block.data {
            if let n = data.accountBlockDataToUTF8String() {
                note  = n
            } else {
                note = nil
            }
        } else {
            note  = ""
        }

        let amount = "\(sendTx.block.amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
        let addressItem = BifrostConfirmItemInfo(title: R.string.localizable.buildinTransferUtf8stringItem0Title(),
                                                 text: sendTx.block.toAddress)
        let amountItem = BifrostConfirmItemInfo(title: R.string.localizable.buildinTransferUtf8stringItem1Title(),
                                                 text: amount)
        let dataItem: BifrostConfirmItemInfo
        if let note = note {
            dataItem = BifrostConfirmItemInfo(title: R.string.localizable.buildinTransferUtf8stringItem2Title(),
                                              text: note)
        } else {
            dataItem = BifrostConfirmItemInfo(title: R.string.localizable.bifrostOperationTitleData(),
                                              text: sendTx.block.data?.toHexString() ?? "")
        }
        return Promise.value(BifrostConfirmInfo(title: R.string.localizable.buildinTransferUtf8stringFunctionTitle(), items: [addressItem, amountItem, dataItem]))
    }
}
