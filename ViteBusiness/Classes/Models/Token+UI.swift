//
//  Token.swift
//  Vite
//
//  Created by Stone on 2018/9/9.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import ViteWallet

extension Token {
    var backgroundColors: [UIColor] {
        return TokenCacheService.instance.backgroundColorsForId(id)
    }

    var icon: ImageWrapper {
        return TokenCacheService.instance.iconForId(id)
    }
}

extension BalanceInfo {

    var balanceShortString: String {
        return balance.amountShort(decimals: token.decimals)
    }

    var balanceFullString: String {
        return balance.amountFull(decimals: token.decimals)
    }

    static func mergeDefaultBalanceInfos(_ balanceInfos: [BalanceInfo]) -> [BalanceInfo] {
        let infos = NSMutableArray(array: balanceInfos)
        let ret = NSMutableArray()

        let defaultBalanceInfos = TokenCacheService.instance.defaultTokens.map {
            BalanceInfo(token: $0, balance: Balance(), unconfirmedBalance: Balance(), unconfirmedCount: 0)
        }

        for defaultBalanceInfo in defaultBalanceInfos {
            if let index = (infos as Array).index(where: { ($0 as! BalanceInfo).token.id == defaultBalanceInfo.token.id }) {
                ret.add(infos[index])
                infos.removeObject(at: index)
            } else {
                ret.add(defaultBalanceInfo)
            }
        }
        ret.addObjects(from: infos as! [Any])
        return ret as! [BalanceInfo]
    }
}

extension AccountBlock {
    var amountShortString: String {
        guard let amount = amount, let token = token else { return "" }
        return amount.amountShort(decimals: token.decimals)
    }

    var amountFullString: String {
        guard let amount = amount, let token = token else { return "" }
        return amount.amountFull(decimals: token.decimals)
    }
}
