//
//  MarketDepthList.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/20.
//

import ObjectMapper

struct MarketDepthList: Mappable {

    fileprivate(set) var asks: [Depth] = []
    fileprivate(set) var bids: [Depth] = []

    func calcPercent() {
        let maxAskAmount = asks.reduce(Double(0)) { (max, depth) -> Double in
            if let amount = Double(depth.amount), amount > max {
                return amount
            } else {
                return max
            }
        }

        let maxBidAmount = bids.reduce(Double(0)) { (max, depth) -> Double in
            if let amount = Double(depth.amount), amount > max {
                return amount
            } else {
                return max
            }
        }

        asks.forEach {
            $0.percent = (Double($0.amount) ?? 0) / maxAskAmount
        }

        bids.forEach {
            $0.percent = (Double($0.amount) ?? 0) / maxBidAmount
        }
    }

    init(asks: [Depth], bids: [Depth]) {
        self.asks = asks
        self.bids = bids
    }

    init?(map: Map) { }

    mutating func mapping(map: Map) {
        asks <- map["asks"]
        bids <- map["bids"]
    }

    static func generate(proto: DepthListProto) -> MarketDepthList {
        let asks = proto.asks.map { Depth(price: $0.price, quantity: $0.quantity, amount: $0.amount)}
        let bids = proto.bids.map { Depth(price: $0.price, quantity: $0.quantity, amount: $0.amount)}

        let ret = MarketDepthList(asks: asks, bids: bids)
        ret.calcPercent()
        return ret
    }

    class Depth: Mappable {
        fileprivate(set) var price: String = ""
        fileprivate(set) var quantity: String = ""
        fileprivate(set) var amount: String = ""
        fileprivate(set) var percent: Double = 0

        init(price: String, quantity: String, amount: String) {
            self.price = price
            self.quantity = quantity
            self.amount = amount
        }

        required init?(map: Map) { }

        func mapping(map: Map) {
            price <- map["price"]
            quantity <- map["quantity"]
            amount <- map["amount"]
        }


    }
}

