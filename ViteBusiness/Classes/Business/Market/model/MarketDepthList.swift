//
//  MarketDepthList.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/20.
//

import ObjectMapper
import BigInt

struct MarketDepthList: Mappable {

    fileprivate(set) var asks: [Depth] = []
    fileprivate(set) var bids: [Depth] = []

    func calcPercent() {
        let maxAskQuantity = asks.reduce(Double(0)) { (max, depth) -> Double in
            if let quantity = Double(depth.quantity), quantity > max {
                return quantity
            } else {
                return max
            }
        }

        let maxBidQuantity = bids.reduce(Double(0)) { (max, depth) -> Double in
            if let quantity = Double(depth.quantity), quantity > max {
                return quantity
            } else {
                return max
            }
        }

        asks.forEach {
            $0.percent = (Double($0.quantity) ?? 0) / maxAskQuantity
        }

        bids.forEach {
            $0.percent = (Double($0.quantity) ?? 0) / maxBidQuantity
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

    static func generate(proto: DepthListProto, count: Int) -> MarketDepthList {
        var asks = proto.asks.map { Depth(price: $0.price, quantity: $0.quantity, amount: $0.amount)}
        var bids = proto.bids.map { Depth(price: $0.price, quantity: $0.quantity, amount: $0.amount)}

        if asks.count > count {
            asks = Array(asks[..<count])
        }

        if bids.count > count {
            bids = Array(bids[..<count])
        }

        let ret = MarketDepthList(asks: asks, bids: bids)
        ret.calcPercent()
        return ret
    }

    class Depth: Mappable {
        fileprivate(set) var price: String = ""
        fileprivate(set) var quantity: String = ""
        fileprivate(set) var amount: String = ""
        fileprivate(set) var percent: Double = 0

        var quantityString: String {
            guard let bigDecimal = BigDecimal(quantity) else { return quantity }
            if bigDecimal < BigDecimal(BigInt(1000)) {
                return quantity
            } else if bigDecimal < BigDecimal(BigInt(1000000)) {
                let ret = bigDecimal / BigDecimal(BigInt(1000))
                return BigDecimalFormatter.format(bigDecimal: ret, style: .decimalTruncation(1), padding: .none, options: []) + "K"
            } else {
                let ret = bigDecimal / BigDecimal(BigInt(1000000))
                return BigDecimalFormatter.format(bigDecimal: ret, style: .decimalTruncation(1), padding: .none, options: []) + "M"
            }
        }

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

