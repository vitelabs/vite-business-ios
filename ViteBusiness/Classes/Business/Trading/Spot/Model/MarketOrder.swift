//
//  MarketOrder.swift
//  ViteBusiness
//
//  Created by Stone on 2020/4/7.
//

import Foundation
import ObjectMapper

struct MarketOrder : Mappable {
    var orderId : String = ""
    var symbol : String = ""
    var tradeTokenSymbol : String = ""
    var quoteTokenSymbol : String = ""
    var tradeToken : String = ""
    var quoteToken : String = ""
    var side : Int = 0
    var price : String = ""
    var quantity : String = ""
    var amount : String = ""
    var executedQuantity : String = ""
    var executedAmount : String = ""
    var executedPercent : String = ""
    var executedAvgPrice : String = ""
    var fee : String = ""
    var status : Int = 0
    var type : Int = 0
    var createTime : Int = 0

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
