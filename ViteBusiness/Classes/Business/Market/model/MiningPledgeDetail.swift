//
//  MiningPledgeDetail.swift
//  ViteBusiness
//
//  Created by Stone on 2020/6/3.
//

import Foundation
import ObjectMapper

struct MiningPledgeDetail : Mappable {
    var miningTotal: String = ""
    var list: [Pledge] = []

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        miningTotal <- map["miningTotal"]
        list <- map["miningList"]
    }

    struct Pledge: Mappable {
        var date: Int64 = 0
        var pledgeAmount: String = ""
        var miningAmount: String = ""
        var miningToken: String = ""

        init?(map: Map) {

        }

        mutating func mapping(map: Map) {
            date <- map["date"]
            pledgeAmount <- map["pledgeAmount"]
            miningAmount <- map["miningAmount"]
            miningToken <- map["miningToken"]
        }
    }
}

