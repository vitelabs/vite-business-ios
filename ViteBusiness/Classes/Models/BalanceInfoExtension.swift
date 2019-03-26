//
//  Token.swift
//  Vite
//
//  Created by Stone on 2018/9/9.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import ViteWallet

extension BalanceInfo {

    var balanceShortString: String {
        return balance.amountShort(decimals: token.decimals)
    }

    var balanceFullString: String {
        return balance.amountFull(decimals: token.decimals)
    }
}
