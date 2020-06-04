//
//  MiningTradeDetail.swift
//  ViteBusiness
//
//  Created by Stone on 2020/6/2.
//

import Foundation
import ObjectMapper

struct MiningTradeDetail : Mappable {
    var miningTotal: String = ""
    var list: [Trade] = []

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        miningTotal <- map["miningTotal"]
        list <- map["miningList"]
    }

    struct Trade: Mappable {
        var date: Int64 = 0
        var feeAmount: String = ""
        var miningAmount: String = ""
        var miningToken: String = ""

        init?(map: Map) {

        }

        mutating func mapping(map: Map) {
            date <- map["date"]
            feeAmount <- map["feeAmount"]
            miningAmount <- map["miningAmount"]
            miningToken <- map["miningToken"]
        }
    }
}

extension String {
    func tryToTruncationDigits(_ digits: Int) -> String {
        if let num = Double(self) {
            return String(format: "%.\(digits)f", num)
        } else {
            return self
        }
    }

    func tryToTruncation6Digits() -> String {
        return tryToTruncationDigits(6)
    }

    func tryToTruncation8Digits() -> String {
        return tryToTruncationDigits(8)
    }
}
