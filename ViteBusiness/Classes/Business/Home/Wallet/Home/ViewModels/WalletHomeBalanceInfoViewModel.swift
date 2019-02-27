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

final class WalletHomeBalanceInfoViewModel: WalletHomeBalanceInfoViewModelType {

    let token: Token
    let symbol: String
    let balance: Balance
    let unconfirmed: Balance
    let unconfirmedCount: UInt64

    init(balanceInfo: BalanceInfo) {
        self.token = balanceInfo.token
        self.symbol = balanceInfo.token.symbol
        self.balance = balanceInfo.balance
        self.unconfirmed = balanceInfo.unconfirmedBalance
        self.unconfirmedCount = balanceInfo.unconfirmedCount
    }
}

final class n_WalletHomeBalanceInfoViewModel {

    let tokenInfo: TokenInfo
    let icon: URL
    let symbol: String
    let coinFamily: String
    let balance: String
    let price: String

    init(balanceInfo: CommonBalanceInfo) {
        self.tokenInfo = balanceInfo.tokenInfo
        self.icon = URL(string: tokenInfo.icon)!
        self.symbol = tokenInfo.symbol
        self.coinFamily = tokenInfo.coinFamily
        self.balance = balanceInfo.balance.amountShort(decimals: tokenInfo.decimals)
        self.price = "Come Soon"
    }
}
