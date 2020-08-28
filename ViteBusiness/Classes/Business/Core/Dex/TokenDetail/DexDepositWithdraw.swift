//
//  DexDepositWithdraw.swift
//  Action
//
//  Created by Stone on 2020/8/27.
//

import Foundation
import ObjectMapper

struct DexDepositWithdraw : Mappable {

    enum DType: Int {
        case deposit = 1
        case withdraw = 2
    }

    var type: DType = .deposit
    var symbol : String = ""
    var amountString : String = ""
    var time : Int64 = 0

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        type <- map["type"]
        symbol <- map["tokenSymbol"]
        amountString <- map["amount"]
        time <- map["time"]
    }
}

