//
//  BigIntExtension.swift.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/18.
//

import ViteWallet
import BigInt

extension String {

    public func toAmount(decimals: Int) -> Amount? {
        guard let bigDecimal = BigDecimal(self) else { return nil }
        let ret = bigDecimal * BigDecimal(BigInt(10).power(decimals))
        if ret.digits == 0 {
            return ret.number
        } else {
            return nil
        }
    }
}
