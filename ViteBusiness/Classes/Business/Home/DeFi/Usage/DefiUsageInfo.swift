//
//  DefiUsageInfo.swift
//  Action
//
//  Created by haoshenyang on 2019/12/9.
//

import Foundation
import ObjectMapper
import BigInt
import ViteWallet

struct DefiUsageInfo: Mappable {

    struct AmountInfo: Mappable {

        fileprivate(set) var baseAmount: Amount! = Amount(0)
        fileprivate(set) var loanAmount: Amount! = Amount(0)

        public init?(map: Map) {

        }

       public mutating func mapping(map: Map) {
        baseAmount <- (map["baseAmount"], JSONTransformer.bigint)
        loanAmount <- (map["loanAmount"], JSONTransformer.bigint)
       }
    }

    struct UsageInfo: Mappable {
        fileprivate(set) var sbpName: String?
        fileprivate(set) var pledgeAmount: Amount! = Amount(0)
        fileprivate(set) var blockProducingAddress: String?
        fileprivate(set) var rewardWithdrawAddress: String?
        fileprivate(set) var pledgeTime: Int!
        fileprivate(set) var pledgeDueTime: Int!
        fileprivate(set) var pledgeDueHeight: Int!

        fileprivate(set) var svipAddress: String?

        fileprivate(set) var quotaAddress: String?

        public init?(map: Map) {

        }

       public mutating func mapping(map: Map) {

        sbpName <- map["sbpName"]
        pledgeAmount <- (map["pledgeAmount"], JSONTransformer.bigint)
        blockProducingAddress <- map["blockProducingAddress"]
        rewardWithdrawAddress <- map["rewardWithdrawAddress"]
        pledgeTime <- map["pledgeTime"]
        pledgeDueTime <- map["pledgeDueTime"]
        pledgeDueHeight <- map["pledgeDueHeight"]

        svipAddress <- map["svipAddress"]
        quotaAddress <- map["quoteAddress"]


       }
    }


    fileprivate(set) var productHash: String!
    fileprivate(set) var usageHash: String!
    fileprivate(set) var usageType: Int!
    fileprivate(set) var usageInfo: UsageInfo!
    fileprivate(set) var amountInfo: AmountInfo!
    fileprivate(set) var usage_status: Int!
    fileprivate(set) var usageTime: Int!


    public init?(map: Map) {

    }

    public mutating func mapping(map: Map) {
        productHash <- map["productHash"]
        usageHash <- map["usageHash"]
        usageType <- map["usageType"]
        usageInfo <- (map["usageInfo"], TransformOf<UsageInfo, String>(fromJSON: { (string) -> UsageInfo? in
            let info = UsageInfo.init(JSONString: string ?? "")
            return info
        }, toJSON: { (amount) -> String? in
            return nil
        }))
        amountInfo <- (map["amountInfo"], TransformOf<AmountInfo, String>(fromJSON: { (string) -> AmountInfo? in
            let info = AmountInfo.init(JSONString: string ?? "")
            return info
        }, toJSON: { (amount) -> String? in
            return nil
        }))
        usage_status <- map["usage_status"]
        usageTime <- map["usageTime"]

    }
}
