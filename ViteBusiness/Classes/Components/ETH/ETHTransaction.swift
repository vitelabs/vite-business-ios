//
//  ETHTransaction.swift
//  ViteBusiness
//
//  Created by Stone on 2020/2/26.
//

import Foundation
import ObjectMapper
import BigInt
import ViteWallet
import web3swift

struct ETHTransaction: Mappable {

    enum TransactionType {
        case receive
        case send
        case other
    }

    fileprivate(set) var blockNumber: String = ""
    fileprivate(set) var timeStamp: Date = Date()
    fileprivate(set) var hash: String = ""
    fileprivate(set) var blockHash: String = ""

    fileprivate(set) var fromAddress: String = ""
    fileprivate(set) var toAddress: String = ""
    fileprivate(set) var amount: Amount = Amount(0)
    fileprivate(set) var gas: Amount = Amount(0)
    fileprivate(set) var gasUsed: Amount = Amount(0)
    fileprivate(set) var gasPrice: Amount = Amount(0)
    fileprivate(set) var input: String = ""
    fileprivate(set) var contractAddress: String = ""

    fileprivate(set) var accountAddress: String = ""
    fileprivate(set) var tokenInfo: TokenInfo = TokenInfo.BuildIn.eth.value

    var type: TransactionType {
        if accountAddress.lowercased() == toAddress.lowercased() {
            return .receive
        } else {
            return .send
        }
    }

    public init?(map: Map) { }

    mutating func mapping(map: Map) {
        blockNumber <- map["blockNumber"]
        timeStamp <- (map["timeStamp"], ETHTransaction.timestampTransform)
        hash <- map["hash"]
        blockHash <- map["blockHash"]
        fromAddress <- map["from"]
        toAddress <- map["to"]
        amount <- (map["value"], JSONTransformer.bigint)
        gas <- (map["gas"], JSONTransformer.bigint)
        gasUsed <- (map["gasUsed"], JSONTransformer.bigint)
        gasPrice <- (map["gasPrice"], JSONTransformer.bigint)
        input <- map["input"]
        contractAddress <- map["contractAddress"]

        if let context = map.context as? Context {
            accountAddress = context.accountAddress
            tokenInfo = context.tokenInfo
        }
    }

    struct Context: MapContext {
        let accountAddress: String
        let tokenInfo: TokenInfo
    }

    static let timestampTransform = TransformOf<Date, String>(fromJSON: { (timestamp) -> Date? in
        guard let timestamp = timestamp, let t = TimeInterval(timestamp) else { return nil }
        return Date(timeIntervalSince1970: t)
    }, toJSON: { (date) -> String? in
        guard let date = date else { return nil }
        return String(date.timeIntervalSinceNow)
    })
}
