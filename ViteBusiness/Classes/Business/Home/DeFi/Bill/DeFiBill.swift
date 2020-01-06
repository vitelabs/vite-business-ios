//
//  DeFiBill.swift
//  Action
//
//  Created by haoshenyang on 2019/12/5.
//
import Foundation
import ObjectMapper
import BigInt
import ViteWallet

struct DeFiBill: Mappable {
    fileprivate(set) var productHash: String! = ""
    fileprivate(set) var accountType: DeFiAPI.Bill.AccountType = .全部
    fileprivate(set) var billType: DeFiAPI.Bill.BillType = .全部
    fileprivate(set) var billAmount: Amount! = Amount(0)
    fileprivate(set) var billTime: TimeInterval = TimeInterval(0)

    public init?(map: Map) {

    }

    public mutating func mapping(map: Map) {
        productHash <- map["productHash"]
        accountType <- map["accountType"]
        billType <- map["billType"]
        billAmount <- (map["billAmount"], JSONTransformer.bigint)
        billTime <- map["billTime"]
    }
}
