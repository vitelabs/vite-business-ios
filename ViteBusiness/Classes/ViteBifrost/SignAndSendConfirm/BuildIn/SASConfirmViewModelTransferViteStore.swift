//
//  SASConfirmViewModelTransferViteStore.swift
//  ViteBusiness
//
//  Created by Stone on 2019/8/26.
//

//import PromiseKit
//import ViteWallet
//
//struct SASConfirmViewModelTransferViteStore: SASConfirmViewModelTransfer {
//
//    func match(uri: ViteURI) -> Bool {
//        return match(uri: uri, contentTypeInUInt16: 0x2323)
//    }
//
//    func confirmInfo(uri: ViteURI, tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {
//        let title = R.string.localizable.appSchemeHomePageViteStoreFunctionTitle()
//        let amount = uri.amountForSmallestUnit(decimals: tokenInfo.decimals) ?? Amount(0)
//        let amountString = "\(amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
//        let amountItem = BifrostConfirmItemInfo(title: R.string.localizable.buildinTransferUtf8stringItem1Title(),
//                                                text: amountString,
//                                                textColor: VBViteSendTx.InputDescription.Style.blue.textColor,
//                                                backgroundColor: VBViteSendTx.InputDescription.Style.blue.backgroundColor)
//        return Promise.value(BifrostConfirmInfo(title: title, items: [amountItem]))
//    }
//}
