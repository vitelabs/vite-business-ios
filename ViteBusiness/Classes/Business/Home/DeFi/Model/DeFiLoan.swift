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

    enum Status: Int {
        case onSale = 1
        case failed = 2
        case success = 3
        case refunding = 4
        case refunded = 5
    }

    fileprivate(set) var productHash: String!
    fileprivate(set) var subscriptionEndHeight: UInt64!
    fileprivate(set) var subscriptionEndTimestamp: Date!
    fileprivate(set) var yearRate: Double!
    fileprivate(set) var loanAmount: Amount!
    fileprivate(set) var singleCopyAmount: Amount!
    fileprivate(set) var loanDuration: UInt64!
    fileprivate(set) var subscribedAmount: Amount!
    fileprivate(set) var loanCompleteness: Double!
    fileprivate var productStatus: DeFiProductStatus!
    fileprivate var refundStatus: DeFiRefundStatus!

    var status: Status {
        switch productStatus! {
        case .onSale:
            return .onSale
        case .failed:
            return .failed
        case .success:
            return .success
        case .cancel:
            switch refundStatus! {
            case .invalid, .refunding:
                return .refunding
            case .refunded:
                return .refunded
            }
        }
    }

    public init?(map: Map) {

    }

    public mutating func mapping(map: Map) {
        productHash <- map["productHash"]
        subscriptionEndHeight <- map["subscriptionEndHeight"]
        subscriptionEndTimestamp <- (map["subscriptionEndTimestamp"], JSONTransformer.timestamp)
        yearRate <- (map["yearRate"], JSONTransformer.stringToDouble)
        loanAmount <- (map["loanAmount"], JSONTransformer.bigint)
        singleCopyAmount <- (map["singleCopyAmount"], JSONTransformer.bigint)
        loanDuration <- map["loanDuration"]
        subscribedAmount <- (map["subscribedAmount"], JSONTransformer.bigint)
        loanCompleteness <- (map["loanCompleteness"], JSONTransformer.stringToDouble)
        productStatus <- map["productStatus"]
        refundStatus <- map["refundStatus"]
    }

    var countDownString: String {
        let now = Date()
        let components = NSCalendar.current.dateComponents([.day, .hour, .minute, .second], from: now, to: subscriptionEndTimestamp)
        return R.string.localizable.defiHomePageCellEndTimeFormat("\(components.day!)", String(format: "%02d:%02d:%02d", components.hour!, components.minute!, components.second!))
    }
}

struct DeFiProductDetail: Mappable {

    enum Status: Int {
        case onSale = 1
        case failed = 2
        case success = 3
        case refunding = 4
        case refunded = 5
    }

    fileprivate(set) var productHash: String!
    fileprivate(set) var subscriptionBeginTime: UInt64!
    fileprivate(set) var subscriptionEndTime: UInt64!
    fileprivate(set) var subscriptionFinishTime: UInt64!
    fileprivate(set) var yearRate: Double!
    fileprivate(set) var loanAmount: Amount!
    fileprivate(set) var subscriptionCopies: UInt64!
    fileprivate(set) var singleCopyAmount: Amount!
    fileprivate(set) var loanDuration: UInt64!
    fileprivate(set) var subscribedAmount: Amount!
    fileprivate(set) var loanCompleteness: Double!
    fileprivate var productStatus: DeFiProductStatus!
    fileprivate var refundStatus: DeFiRefundStatus!

    var status: Status {
        switch productStatus! {
        case .onSale:
            return .onSale
        case .failed:
            return .failed
        case .success:
            return .success
        case .cancel:
            switch refundStatus! {
            case .invalid, .refunding:
                return .refunding
            case .refunded:
                return .refunded
            }
        }
    }

    public init?(map: Map) {
        
    }

    public mutating func mapping(map: Map) {
        productHash <- map["productHash"]
        subscriptionBeginTime <- map["subscriptionBeginTime"]
        subscriptionEndTime <- map["subscriptionEndTime"]
        subscriptionFinishTime <- map["subscriptionFinishTime"]
        yearRate <- (map["yearRate"], JSONTransformer.stringToDouble)
        loanAmount <- (map["loanAmount"], JSONTransformer.bigint)
        subscriptionCopies <- map["subscriptionCopies"]
        singleCopyAmount <- (map["singleCopyAmount"], JSONTransformer.bigint)
        loanDuration <- map["loanDuration"]
        subscribedAmount <- (map["subscribedAmount"], JSONTransformer.bigint)
        loanCompleteness <- (map["loanCompleteness"], JSONTransformer.stringToDouble)
        productStatus <- map["productStatus"]
        refundStatus <- map["refundStatus"]
    }

    var countDownString: String {
        let now = Date()
        let components = NSCalendar.current.dateComponents([.day, .hour, .minute, .second], from: now, to: Date.init(timeIntervalSince1970: TimeInterval(subscriptionEndTime)))
        return R.string.localizable.defiHomePageCellEndTimeFormat("\(components.day!)", String(format: "%02d:%02d:%02d", components.hour!, components.minute!, components.second!))
    }

}

extension Double {
    func percentageString() -> String {
        return String(format: "%.2f%%", self * 100.0)
    }
}

