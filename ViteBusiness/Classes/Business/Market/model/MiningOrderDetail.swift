//
//  MiningOrderDetail.swift
//  ViteBusiness
//
//  Created by vite on 2022/4/19.
//

import Foundation
import ObjectMapper

struct MiningOrderDetail : Mappable {
    var miningTotal: String = ""
    var miningList: [MarketMaking] = []

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        miningTotal <- map["miningTotal"]
        miningList <- map["miningList"]
    }
    
    struct MarketMaking: Mappable {
        var date: Int64 = 0
        var miningAmount: String = ""
        var miningRatio: String = ""

        init?(map: Map) {

        }

        mutating func mapping(map: Map) {
            date <- map["date"]
            miningAmount <- map["miningAmount"]
            miningRatio <- map["miningRatio"]
        }
    }
    
    struct Estimate: Mappable {
        var ethAmount: String = "0.000000000000000000"
        var btcAmount: String = "0.000000000000000000"
        var usdtAmount: String = "0.000000000000000000"
        var viteAmount: String = "0.000000000000000000"

        init?(map: Map) {

        }

        mutating func mapping(map: Map) {
            ethAmount <- map["orderMiningStat.ETH"]
            btcAmount <- map["orderMiningStat.BTC"]
            usdtAmount <- map["orderMiningStat.USDT"]
            viteAmount <- map["orderMiningStat.VITE"]
        }
    }
}
