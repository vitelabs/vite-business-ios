//
//  DeFiLoan.swift
//  ViteBusiness
//
//  Created by Stone on 2019/11/29.
//

import Foundation
import ObjectMapper
import BigInt
import ViteWallet

enum DeFiProductStatus: Int {
    case onSale = 1
    case failed = 2
    case success = 3
    case cancel = 4
}

enum DeFiRefundStatus: Int {
    case invalid = 0
    case refunding = 1
    case refunded = 2
}

struct DeFiLoan: Mappable {
    // id
    fileprivate(set) var productHash: String = ""
    // user input
    fileprivate(set) var loanAmount: Amount = Amount()
    fileprivate(set) var singleCopyAmount: Amount = Amount()
    fileprivate(set) var subscriptionCopies: UInt64 = 0
    fileprivate(set) var loanDuration: UInt64 = 0
    fileprivate(set) var yearRate: Double = 0
    fileprivate(set) var dayRate: Double = 0
    fileprivate(set) var loanPayable: Amount = Amount()

    // status
    fileprivate(set) var productStatus: DeFiProductStatus = .onSale
    fileprivate(set) var refundStatus: DeFiRefundStatus = .invalid
    fileprivate(set) var subscribedAmount: Amount = Amount()
    fileprivate(set) var loanCompleteness: Double = 0
    fileprivate(set) var loanUsedAmount: Amount = Amount()

    // time
    fileprivate(set) var subscriptionBeginTime: Date = Date()
    fileprivate(set) var subscriptionEndTime: Date = Date()
    fileprivate(set) var subscriptionFinishTime: Date = Date()
    fileprivate(set) var loanEndTime: Date = Date()
    fileprivate(set) var loanEndSnapshotHeight: UInt64 = 0

    var loanSnapshotCount: UInt64 {
        return loanDuration * 24 * 60 * 60
    }

    var subscriptionDuration: UInt64 {
        let interval = UInt64(subscriptionEndTime.timeIntervalSince1970 - subscriptionBeginTime.timeIntervalSince1970)
        return  interval / (60*60*24)
    }
    var remainAmount: Amount { return loanAmount - loanUsedAmount }

    public init?(map: Map) {

    }

    public mutating func mapping(map: Map) {
        productHash <- map["productHash"]

        loanAmount <- (map["loanAmount"], JSONTransformer.bigint)
        singleCopyAmount <- (map["singleCopyAmount"], JSONTransformer.bigint)
        subscriptionCopies <- map["subscriptionCopies"]
        loanDuration <- map["loanDuration"]
        yearRate <- (map["yearRate"], JSONTransformer.stringToDouble)
        dayRate <- (map["dayRate"], JSONTransformer.stringToDouble)
        loanPayable <- (map["loanPayable"], JSONTransformer.bigint)

        productStatus <- map["productStatus"]
        refundStatus <- map["refundStatus"]
        subscribedAmount <- (map["subscribedAmount"], JSONTransformer.bigint)
        loanCompleteness <- (map["loanCompleteness"], JSONTransformer.stringToDouble)
        loanUsedAmount <- (map["loanUsedAmount"], JSONTransformer.bigint)


        subscriptionBeginTime <- (map["subscriptionBeginTime"], JSONTransformer.timestamp)
        subscriptionEndTime <- (map["subscriptionEndTime"], JSONTransformer.timestamp)
        subscriptionFinishTime <- (map["subscriptionFinishTime"], JSONTransformer.timestamp)
        loanEndTime <- (map["loanEndTime"], JSONTransformer.timestamp)
        loanEndSnapshotHeight <- map["loanEndSnapshotHeight"]


    }

    func countDown(for date: Date) -> (day: String, time: String) {
        let components = NSCalendar.current.dateComponents([.day, .hour, .minute, .second], from: date, to: subscriptionEndTime)
        return (day: "\(max(components.day!, 0))", time: String(format: "%02d:%02d:%02d", max(components.hour!, 0), max(components.minute!, 0), max(components.second!, 0)))
    }

    func countDownString(for date: Date) -> String {
        let (day, time) = countDown(for: date)
        return R.string.localizable.defiHomePageCellEndTimeFormat(day, time)
    }

    var countDownString: String {
        let (day, time) = countDown(for: Date())
        return R.string.localizable.defiHomePageCellEndTimeFormat(day, time)
    }

    var yearRateString: String {
        return String(format: "%.2f%%", yearRate*100)
    }

    var isExpire: Bool {
        let now = UInt64(Date().timeIntervalSince1970)
        return now >= loanEndSnapshotHeight
    }

    var isUsed: Bool {
        return loanUsedAmount > 0
    }

    var dayRateString: String {
        return String(format: "%.4f%%", dayRate*100)
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

    var loanEndTimeString: String {
        return loanEndTime.format("yyyy/MM/dd HH:mm:ss")
    }
}
