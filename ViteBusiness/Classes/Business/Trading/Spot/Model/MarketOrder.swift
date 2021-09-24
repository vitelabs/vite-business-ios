//
//  MarketOrder.swift
//  ViteBusiness
//
//  Created by Stone on 2020/4/7.
//

import Foundation
import ObjectMapper

struct MarketOrder : Mappable {

    enum Status: Int32 {
        case open = 1
        case closed = 2
        case canceled = 3
        case failed = 4
    }

    var orderHash : String = ""
    var _orderId : String = ""
    var symbol : String = ""
    var tradeTokenSymbol : String = ""
    var quoteTokenSymbol : String = ""
    var tradeToken : String = ""
    var quoteToken : String = ""
    var side : Int32 = 0
    var price : String = ""
    var quantity : String = ""
    var amount : String = ""
    var executedQuantity : String = ""
    var executedAmount : String = ""
    var executedPercent : String = ""
    var executedAvgPrice : String = ""
    var fee : String = ""
    var status : Status = .failed
    var type : Int32 = 0
    var createTime : Int64 = 0

    var tradeTokenSymbolWithoutIndex : String {
        tradeTokenSymbol.components(separatedBy: "-").first ?? tradeTokenSymbol
    }

    var quoteTokenSymbolWithoutIndex : String {
        quoteTokenSymbol.components(separatedBy: "-").first ?? quoteTokenSymbol
    }
    
    var orderId : String {
        orderHash.isEmpty ? _orderId : orderHash
    }

    init(orderProto: OrderProto) {
        self.orderHash = orderProto.orderHash
        self._orderId = orderProto.orderHash
        self.symbol = orderProto.symbol
        self.tradeTokenSymbol = orderProto.tradeTokenSymbol
        self.quoteTokenSymbol = orderProto.quoteTokenSymbol
        self.tradeToken = orderProto.tradeToken
        self.quoteToken = orderProto.quoteToken
        self.side = orderProto.side
        self.price = orderProto.price
        self.quantity = orderProto.quantity
        self.amount = orderProto.amount
        self.executedQuantity = orderProto.executedQuantity
        self.executedAmount = orderProto.executedAmount
        self.executedPercent = orderProto.executedPercent
        self.executedAvgPrice = orderProto.executedAvgPrice
        self.fee = orderProto.fee
        self.status = Status(rawValue: orderProto.status) ?? .failed
        self.type = orderProto.type
        self.createTime = orderProto.createTime
    }

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        orderHash <- map["orderHash"]
        _orderId <- map["orderId"]
        symbol <- map["symbol"]
        tradeTokenSymbol <- map["tradeTokenSymbol"]
        quoteTokenSymbol <- map["quoteTokenSymbol"]
        tradeToken <- map["tradeToken"]
        quoteToken <- map["quoteToken"]
        side <- map["side"]
        price <- map["price"]
        quantity <- map["quantity"]
        amount <- map["amount"]
        executedQuantity <- map["executedQuantity"]
        executedAmount <- map["executedAmount"]
        executedPercent <- map["executedPercent"]
        executedAvgPrice <- map["executedAvgPrice"]
        fee <- map["fee"]
        status <- map["status"]
        type <- map["type"]
        createTime <- map["createTime"]
    }

}
