//
//  MarketTrade.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/20.
//

import Foundation
import ObjectMapper

class MarketTrade: Mappable {
    private var time: Int64 = 0
    private var side: Int32 = 0
    fileprivate(set) var price: String = ""
    fileprivate(set) var quantity: String = ""

    var date: Date { Date(timeIntervalSince1970: TimeInterval(time)) }
    var isBuy: Bool { side == 0 }

    init(time: Int64, side: Int32, price: String, quantity: String) {
        self.time = time
        self.side = side
        self.price = price
        self.quantity = quantity
    }

    required init?(map: Map) { }

    func mapping(map: Map) {
        time <- map["time"]
        side <- map["side"]
        price <- map["price"]
        quantity <- map["quantity"]
    }

    static func generate(proto: Protocol.TradeProto) -> MarketTrade {
        return MarketTrade(time: proto.time, side: 0, price: proto.price, quantity: proto.quantity)
    }

}
