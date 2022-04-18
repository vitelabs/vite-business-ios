//
//  MiningInviteDetail.swift
//  ViteBusiness
//
//  Created by vite on 2022/4/18.
//

import Foundation
import ObjectMapper

struct MiningInviteDetail : Mappable {
    var total: String = ""
    var trading: String = ""
    var marketMaking: String = ""
    var inviteCount: UInt = 0
    var tradingList: [Trading] = []
    var marketMakingList: [MarketMaking] = []

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {
        total <- map["miningInvite.allMiningTotal"]
        trading <- map["miningInvite.miningTotal"]
        marketMaking <- map["miningOrderInvite.miningTotal"]
        inviteCount <- map["inviter.inviteCount"]
        tradingList <- map["miningInvite.miningList"]
        marketMakingList <- map["miningOrderInvite.miningList"]
    }
    
    struct Trading: Mappable {
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
    
    struct MarketMaking: Mappable {
        var date: Int64 = 0
        var miningAmount: String = ""
        var miningPercent: String = ""

        init?(map: Map) {

        }

        mutating func mapping(map: Map) {
            date <- map["date"]
            miningAmount <- map["miningAmount"]
            miningPercent <- map["miningPercent"]
        }
    }
}
