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
    fileprivate(set) var subscriptionDuration: UInt64 = 0
    fileprivate(set) var loanDuration: UInt64 = 0
    fileprivate(set) var yearRate: Double = 0

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

    var remainAmount: Amount { return loanAmount - loanUsedAmount }

    public init?(map: Map) {

    }

    public mutating func mapping(map: Map) {
        productHash <- map["productHash"]

        loanAmount <- (map["loanAmount"], JSONTransformer.bigint)
        singleCopyAmount <- (map["singleCopyAmount"], JSONTransformer.bigint)
        subscriptionCopies <- map["subscriptionCopies"]
        subscriptionDuration <- map["xxxxxxx"]
        loanDuration <- map["loanDuration"]
        yearRate <- (map["yearRate"], JSONTransformer.stringToDouble)

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

    var loanEndTimeString: String {
        return loanEndTime.format("yyyy/MM/dd HH:mm:ss")
    }
}

//struct DeFiProductDetail: Mappable {
//
//    enum Status: Int {
//        case onSale = 1
//        case failed = 2
//        case success = 3
//        case refunding = 4
//        case refunded = 5
//    }
//
//    fileprivate(set) var productHash: String!
//    fileprivate(set) var subscriptionBeginTime: UInt64!
//    fileprivate(set) var subscriptionEndTime: UInt64!
//    fileprivate(set) var subscriptionFinishTime: UInt64!
//    fileprivate(set) var yearRate: Double!
//    fileprivate(set) var loanAmount: Amount!
//    fileprivate(set) var subscriptionCopies: UInt64!
//    fileprivate(set) var singleCopyAmount: Amount!
//    fileprivate(set) var loanDuration: UInt64!
//    fileprivate(set) var subscribedAmount: Amount!
//    fileprivate(set) var loanCompleteness: Double!
//    fileprivate var productStatus: DeFiProductStatus!
//    fileprivate var refundStatus: DeFiRefundStatus!
//
//    var status: Status {
//        switch productStatus! {
//        case .onSale:
//            return .onSale
//        case .failed:
//            return .failed
//        case .success:
//            return .success
//        case .cancel:
//            switch refundStatus! {
//            case .invalid, .refunding:
//                return .refunding
//            case .refunded:
//                return .refunded
//            }
//        }
//    }
//
//    public init?(map: Map) {
//        
//    }
//
//    public mutating func mapping(map: Map) {
//        productHash <- map["productHash"]
//        subscriptionBeginTime <- map["subscriptionBeginTime"]
//        subscriptionEndTime <- map["subscriptionEndTime"]
//        subscriptionFinishTime <- map["subscriptionFinishTime"]
//        yearRate <- (map["yearRate"], JSONTransformer.stringToDouble)
//        loanAmount <- (map["loanAmount"], JSONTransformer.bigint)
//        subscriptionCopies <- map["subscriptionCopies"]
//        singleCopyAmount <- (map["singleCopyAmount"], JSONTransformer.bigint)
//        loanDuration <- map["loanDuration"]
//        subscribedAmount <- (map["subscribedAmount"], JSONTransformer.bigint)
//        loanCompleteness <- (map["loanCompleteness"], JSONTransformer.stringToDouble)
//        productStatus <- map["productStatus"]
//        refundStatus <- map["refundStatus"]
//    }
//
//    var countDownString: String {
//        let now = Date()
//        let components = NSCalendar.current.dateComponents([.day, .hour, .minute, .second], from: now, to: Date.init(timeIntervalSince1970: TimeInterval(subscriptionEndTime)))
//        return R.string.localizable.defiHomePageCellEndTimeFormat("\(components.day!)", String(format: "%02d:%02d:%02d", components.hour!, components.minute!, components.second!))
//    }
//
//}
//
//extension Double {
//    func percentageString() -> String {
//        return String(format: "%.2f%%", self * 100.0)
//    }
//}

struct DeFiBill: Mappable {
    fileprivate(set) var productHash: String!
    fileprivate(set) var accountType: DeFiAPI.Bill.AccountType!
    fileprivate(set) var billType: DeFiAPI.Bill.BillType!
    fileprivate(set) var billAmount: Amount!
    fileprivate(set) var billTime: TimeInterval!

    public init?(map: Map) {

    }

    public mutating func mapping(map: Map) {
        productHash <- map["productHash"]
        accountType <- map["accountType"]
        billType <- map["billType"]
        billAmount <- (map["loanAmount"], JSONTransformer.bigint)
        billTime <- map["billTime"]
    }
}


