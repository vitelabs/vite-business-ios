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

        let amount = uri.amountForSmallestUnit(decimals: tokenInfo.decimals) ?? Amount(0)

        let addressItem = BifrostConfirmItemInfo(title: R.string.localizable.bifrostOperationTitleContractAddress(),
                                                 text: uri.address)
        let tokenItem = BifrostConfirmItemInfo(title: R.string.localizable.bifrostOperationTitleTokenSymbol(),
                                               text: tokenInfo.uniqueSymbol)
        let amountItem = BifrostConfirmItemInfo(title: R.string.localizable.bifrostOperationTitleAmount(),
                                                text: amount.amountFullWithGroupSeparator(decimals: tokenInfo.decimals))
        let dataItem = BifrostConfirmItemInfo(title: R.string.localizable.bifrostOperationTitleData(),
                                              text: uri.data?.toHexString() ?? "")

        if let fee = uri.feeForSmallestUnit(decimals: ViteWalletConst.viteToken.decimals), fee > 0 {
            let feeItem = BifrostConfirmItemInfo(title: R.string.localizable.bifrostOperationTitleFee(),
                                                 text: fee.amountFullWithGroupSeparator(decimals: tokenInfo.decimals))
            return Promise.value(BifrostConfirmInfo(title: title, items: [addressItem, tokenItem, amountItem, feeItem, dataItem]))
        } else {
            return Promise.value(BifrostConfirmInfo(title: title, items: [addressItem, tokenItem, amountItem, dataItem]))
        }
    }
}
