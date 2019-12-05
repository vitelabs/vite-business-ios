//
//  DeFiSubscription.swift
//  ViteBusiness
//
//  Created by Stone on 2019/12/2.
//

import Foundation
import ObjectMapper
import BigInt
import ViteWallet

struct DeFiSubscription: Mappable {

    // id
    fileprivate(set) var productHash: String = ""
    // user input
    fileprivate(set) var loanAmount: Amount = Amount()
    fileprivate(set) var singleCopyAmount: Amount = Amount()
    fileprivate(set) var subscriptionCopies: UInt64 = 0
    fileprivate(set) var loanDuration: UInt64 = 0
    fileprivate(set) var yearRate: Double = 0
    // status
    fileprivate(set) var productStatus: DeFiProductStatus = .onSale
    fileprivate(set) var refundStatus: DeFiRefundStatus = .invalid
    fileprivate(set) var subscribedAmount: Amount = Amount()
    fileprivate(set) var loanCompleteness: Double = 0
    fileprivate(set) var subscribedCopies: UInt64 = 0
    fileprivate(set) var leftCopies: UInt64 = 0
    fileprivate(set) var mySubscribedAmount: Amount = Amount()
    fileprivate(set) var mySubscribedCopies: UInt64 = 0
    fileprivate(set) var totalProfits: Amount = Amount()
    fileprivate(set) var dayProfits: Amount = Amount()
    fileprivate(set) var earnProfits: Amount = Amount()
    // time
    fileprivate(set) var subscriptionBeginTime: Date = Date()
    fileprivate(set) var subscriptionEndTime: Date = Date()
    fileprivate(set) var subscriptionFinishTime: Date = Date()

    var subscriptionDuration: UInt64 {
        let interval = UInt64(subscriptionEndTime.timeIntervalSince1970 - subscriptionBeginTime.timeIntervalSince1970)
        return  interval / (60*60*24)
    }

    public init?(map: Map) {

    }

    public mutating func mapping(map: Map) {
        productHash <- map["productHash"]

        loanAmount <- (map["loanAmount"], JSONTransformer.bigint)
        singleCopyAmount <- (map["singleCopyAmount"], JSONTransformer.bigint)
        subscriptionCopies <- map["subscriptionCopies"]
        loanDuration <- map["loanDuration"]
        yearRate <- (map["yearRate"], JSONTransformer.stringToDouble)

        productStatus <- map["productStatus"]
        refundStatus <- map["refundStatus"]
        subscribedAmount <- (map["subscribedAmount"], JSONTransformer.bigint)
        loanCompleteness <- (map["loanCompleteness"], JSONTransformer.stringToDouble)
        subscribedCopies <- map["subscribedCopies"]
        leftCopies <- map["leftCopies"]
        mySubscribedAmount <- (map["mySubscribedAmount"], JSONTransformer.bigint)
        mySubscribedCopies <- map["mySubscribedCopies"]
        totalProfits <- (map["totalProfits"], JSONTransformer.bigint)
        dayProfits <- (map["dayProfits"], JSONTransformer.bigint)
        earnProfits <- (map["earnProfits"], JSONTransformer.bigint)

        subscriptionBeginTime <- (map["subscriptionBeginTime"], JSONTransformer.timestamp)
        subscriptionEndTime <- (map["subscriptionEndTime"], JSONTransformer.timestamp)
        subscriptionFinishTime <- (map["subscriptionFinishTime"], JSONTransformer.timestamp)
    }

    var leftSubscriptionAmount: Amount { return loanAmount - subscribedAmount }

    var countDownString: String {
        let now = Date()
        let components = NSCalendar.current.dateComponents([.day, .hour, .minute, .second], from: now, to: subscriptionEndTime)
        return R.string.localizable.defiHomePageCellEndTimeFormat("\(max(components.day!, 0))", String(format: "%02d:%02d:%02d", max(components.hour!, 0), max(components.minute!, 0), max(components.second!, 0)))
    }

    var yearRateString: String {
        return String(format: "%.2f%%", yearRate*100)
    }

    var loanCompletenessString: String {
        return String(format: "%.0f%%", loanCompleteness*100)
    }

    var subscriptionBeginTimeString: String {
        return subscriptionBeginTime.format("yyyy/MM/dd HH:mm:ss")
    }

    var subscriptionFinishTimeString: String {
        return subscriptionFinishTime.format("yyyy-MM-dd HH:mm:ss")
    }
}
