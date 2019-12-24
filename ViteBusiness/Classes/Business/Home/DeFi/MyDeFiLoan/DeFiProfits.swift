//
//  DeFiProfits.swift
//  ViteBusiness
//
//  Created by Stone on 2019/12/24.
//

import Foundation
import ObjectMapper
import BigInt
import ViteWallet

struct DeFiProfits: Mappable {

    fileprivate var profitsRate: Double = 0
    fileprivate(set) var totalProfits: Amount = Amount()
    fileprivate(set) var subscribedAmount: Amount = Amount()
    fileprivate(set) var earnProfits: Amount = Amount()


    public init?(map: Map) {}

    public mutating func mapping(map: Map) {
        profitsRate <- (map["profitsRate"], JSONTransformer.stringToDouble)
        totalProfits <- (map["totalProfits"], JSONTransformer.bigint)
        subscribedAmount <- (map["subscribedAmount"], JSONTransformer.bigint)
        earnProfits <- (map["earnProfits"], JSONTransformer.bigint)
    }

    var profitsRateString: String {
        return String(format: "%.2f%%", profitsRate*100)
    }
}
