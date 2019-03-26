//
//  BalanceExtension.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/18.
//

import ViteWallet
import BigInt

extension Balance {

    public func amountShort(decimals: Int) -> String {
        return pri_amount(decimals: decimals, count: 4)
    }

    public func amountFull(decimals: Int) -> String {
        return pri_amount(decimals: decimals, count: 8)
    }

    fileprivate func pri_amount(decimals: Int, count: Int) -> String {
        let bigDecimal = BigDecimal(number: value, digits: decimals)
        return BigDecimalFormatter.format(bigDecimal: bigDecimal, style: .decimalTruncation(min(count, decimals)), padding: .padding)
    }
}

