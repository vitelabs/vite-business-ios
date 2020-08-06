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

public struct ETHTransaction: Mappable {

    enum TransactionType {
        case receive
        case send
        case me
    }

    fileprivate(set) var isError: Bool = false
    fileprivate(set) var blockNumber: String = ""
    fileprivate(set) var confirmations: String = ""
    fileprivate(set) var nonce: BigInt = BigInt(0)
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
        let from = fromAddress.lowercased()
        let to = toAddress.lowercased()
        let account = accountAddress.lowercased()

        if from == to {
            return .me
        } else if account == to {
            return .receive
        } else {
            return .send
        }
    }


    var isConfirmed: Bool {
        if let num = Int(confirmations), num == 0 {
            return false
        } else {
            return true
        }
    }

    mutating func update(confirmations: BigInt) {
        self.confirmations = confirmations.description
    }

    public init?(map: Map) { }

    init(result: TransactionSendingResult, accountAddress: String, tokenInfo: TokenInfo) {
        self.isError = false
        self.blockNumber = ""
        self.confirmations = "0"
        self.nonce = BigInt(result.transaction.nonce)
        self.timeStamp = Date()
        self.hash = result.hash
        self.blockHash = ""
        self.fromAddress = accountAddress
        self.toAddress = result.transaction.to.address
        self.amount = Amount(result.transaction.value)
        self.gas = Amount(0)
        self.gasUsed = Amount(0)
        self.gasPrice = Amount(result.transaction.gasPrice)
        self.input = "0x" + result.transaction.data.toHexString()
        self.contractAddress = tokenInfo.ethContractAddress

        self.accountAddress = accountAddress
        self.tokenInfo = tokenInfo
    }

    mutating public func mapping(map: Map) {
        isError <- (map["isError"], ETHTransaction.isErrorTransform)
        blockNumber <- map["blockNumber"]
        confirmations <- map["confirmations"]
        nonce <- (map["nonce"], JSONTransformer.bigint)
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

    static let isErrorTransform = TransformOf<Bool, String>(fromJSON: { (text) -> Bool in
        return text != "0"
    }, toJSON: { (ret) -> String? in
        guard let ret = ret else { return nil }
        return ret ? "1" : "0"
    })
}
