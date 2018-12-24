//
//  Token.swift
//  Vite
//
//  Created by Stone on 2018/9/9.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import ViteWallet

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
