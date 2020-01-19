//
//  AmountExtension.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/18.
//

import ViteWallet
import BigInt

extension Amount {

    public func amountShortStringForDeFiWithGroupSeparator(decimals: Int) -> String {
        return amount(decimals: decimals, count: 2, groupSeparator: true)
    }

    public func amountShort(decimals: Int) -> String {
        return amount(decimals: decimals, count: 4, groupSeparator: false)
    }

    public func amountFull(decimals: Int) -> String {
        return amount(decimals: decimals, count: 8, groupSeparator: false)
    }

    public func amountShortWithGroupSeparator(decimals: Int) -> String {
        return amount(decimals: decimals, count: 4, groupSeparator: true)
    }

    public func amountFullWithGroupSeparator(decimals: Int) -> String {
        return amount(decimals: decimals, count: 8, groupSeparator: true)
    }

    public func amount(decimals: Int, count: Int, groupSeparator: Bool = true) -> String {
        let bigDecimal = BigDecimal(number: (self as BigInt), digits: decimals)
        let options: [BigDecimalFormatter.Options] = groupSeparator ? [.groupSeparator] : []
        return BigDecimalFormatter.format(bigDecimal: bigDecimal, style: .decimalTruncation(Swift.min(decimals, count)), padding: .none, options: options)
    }
}

