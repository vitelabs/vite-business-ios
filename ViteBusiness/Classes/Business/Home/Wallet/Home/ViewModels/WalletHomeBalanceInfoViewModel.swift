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

final class WalletHomeBalanceInfoViewModel {

    let tokenInfo: TokenInfo
    let symbol: String
    let coinFamily: String
    let balanceString: String
    let price: String
    let balance: Amount

    init(balanceInfo: WalletHomeBalanceInfo, isHidePrice: Bool) {
        self.tokenInfo = balanceInfo.tokenInfo

        self.symbol = tokenInfo.symbol
        self.coinFamily = tokenInfo.coinFamily
        self.balance = balanceInfo.balance
        if isHidePrice {
            self.balanceString = "****"
            self.price = "****"
        } else {
            self.balanceString = balanceInfo.balance.amountShortWithGroupSeparator(decimals: tokenInfo.decimals)
            self.price = "≈" + ExchangeRateManager.instance.rateMap.priceString(for: balanceInfo.tokenInfo, balance: balanceInfo.balance)
        }
    }

    // for unselected vite token
    init(tokenInfo: TokenInfo, balance: Amount) {
        self.tokenInfo = tokenInfo
        self.symbol = tokenInfo.symbol
        self.coinFamily = tokenInfo.coinFamily
        self.balance = balance
        self.balanceString = balance.amountShortWithGroupSeparator(decimals: tokenInfo.decimals)
        self.price = "≈" + ExchangeRateManager.instance.rateMap.priceString(for: tokenInfo, balance: balance)
    }

}
