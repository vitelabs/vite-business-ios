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
