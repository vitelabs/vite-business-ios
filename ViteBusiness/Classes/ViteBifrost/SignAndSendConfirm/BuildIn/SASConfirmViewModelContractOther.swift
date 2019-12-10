//
//  SASConfirmViewModelContractOther.swift
//  ViteBusiness
//
//  Created by Stone on 2019/8/26.
//

import PromiseKit
import ViteWallet

struct SASConfirmViewModelContractOther: SASConfirmViewModel {

    func confirmInfo(uri: ViteURI, tokenInfo: TokenInfo) -> Promise<BifrostConfirmInfo> {

        let title = uri.functionName ?? R.string.localizable.bifrostOperationFunctionTitle()

        let addressItem = BifrostConfirmItemInfo(title: R.string.localizable.bifrostOperationTitleContractAddress(),
                                                 text: uri.address)

        let amount = uri.amountForSmallestUnit(decimals: tokenInfo.decimals) ?? Amount(0)
        let amountString = "\(amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals)) \(tokenInfo.symbol)"
        let amountItem = BifrostConfirmItemInfo(title: R.string.localizable.bifrostOperationTitleAmount(),
                                                text: amountString,
                                                textColor: VBViteSendTx.InputDescription.Style.blue.textColor,
                                                backgroundColor: VBViteSendTx.InputDescription.Style.blue.backgroundColor)

        let dataItem = BifrostConfirmItemInfo(title: R.string.localizable.bifrostOperationTitleData(),
                                              text: uri.data?.toHexString() ?? "")

        if let fee = uri.feeForSmallestUnit(decimals: ViteWalletConst.viteToken.decimals), fee > 0 {
            let feeItem = BifrostConfirmItemInfo(title: R.string.localizable.bifrostOperationTitleFee(),
                                                 text: fee.amountFullWithGroupSeparator(decimals: tokenInfo.decimals))
            return Promise.value(BifrostConfirmInfo(title: title, items: [addressItem, amountItem, feeItem, dataItem]))
        } else {
            return Promise.value(BifrostConfirmInfo(title: title, items: [addressItem, amountItem, dataItem]))
        }
    }
}
