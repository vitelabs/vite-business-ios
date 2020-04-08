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

    var orderId : String = ""
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

    init(orderProto: OrderProto) {
        self.orderId = orderProto.orderID
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

        orderId <- map["orderId"]
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
