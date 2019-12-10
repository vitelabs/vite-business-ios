//
//  SASConfirmViewModelTransferNormal.swift
//  ViteBusiness
//
//  Created by Stone on 2019/8/26.
//

import PromiseKit
import ViteWallet

struct SASConfirmViewModelTransferNormal: SASConfirmViewModel {

    func confirmInfo(uri: ViteURI, tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
        let title = R.string.localizable.buildinTransferUtf8stringFunctionTitle()


        let addressItem = BifrostConfirmItemInfo(title: R.string.localizable.buildinTransferUtf8stringItem0Title(),
                                                 text: uri.address)
        let amount = uri.amountForSmallestUnit(decimals: tokenInfo.decimals) ?? Amount(0)
        let amountString = "\(amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
        let amountItem = BifrostConfirmItemInfo(title: R.string.localizable.buildinTransferUtf8stringItem1Title(),
                                                text: amountString,
                                                textColor: VBViteSendTx.InputDescription.Style.blue.textColor,
                                                backgroundColor: VBViteSendTx.InputDescription.Style.blue.backgroundColor)
        let note: String?
        if let data = uri.data {
            if let n = data.accountBlockDataToUTF8String() {
                note  = n
            } else {
                note = nil
            }
        } else {
            note  = ""
        }
        let dataItem: BifrostConfirmItemInfo
        if let note = note {
            dataItem = BifrostConfirmItemInfo(title: R.string.localizable.buildinTransferUtf8stringItem2Title(),
                                              text: note)
        } else {
            dataItem = BifrostConfirmItemInfo(title: R.string.localizable.bifrostOperationTitleData(),
                                              text: uri.data?.toHexString() ?? "")
        }

        return Promise.value(BifrostConfirmInfo(title: title, items: [addressItem, amountItem, dataItem]))
    }
}
