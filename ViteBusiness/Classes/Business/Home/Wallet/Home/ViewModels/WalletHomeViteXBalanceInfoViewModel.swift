//
//  WalletHomeBalanceInfoViewModel.swift
//  Vite
//
//  Created by Stone on 2018/9/9.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import ViteWallet
import RxSwift
import RxCocoa

final class WalletHomeViteXBalanceInfoViewModel {

    let tokenInfo: TokenInfo
    let symbol: String
    let totalString: String
    let availableString: String


    init(tokenInfo: TokenInfo, balanceInfo: DexBalanceInfo, isHidePrice: Bool) {
        self.tokenInfo = tokenInfo
        self.symbol = tokenInfo.uniqueSymbol

        if isHidePrice {
            self.totalString = "****"
            self.availableString = "****"
        } else {
            self.totalString = balanceInfo.total.amountShortWithGroupSeparator(decimals: tokenInfo.decimals)
            self.availableString = balanceInfo.available.amountShortWithGroupSeparator(decimals: tokenInfo.decimals)
        }
    }
}
