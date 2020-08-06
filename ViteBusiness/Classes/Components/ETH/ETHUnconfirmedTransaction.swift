//
//  ETHUnconfirmedTransaction.swift
//  ViteBusiness
//
//  Created by Stone on 2020/8/6.
//

import Foundation
import ObjectMapper
import BigInt
import ViteWallet
import web3swift

public struct ETHUnconfirmedTransaction: Mappable {

    enum CoinType {
        case eth
        case erc20(contractAddress: String, toAddress: String, amount: Amount)
    }

    enum TransactionType {
        case receive
        case send
        case me
    }

    fileprivate(set) var nonce: BigInt = BigInt(0)
    fileprivate(set) var timeStamp: Date = Date()
    fileprivate(set) var hash: String = ""

    fileprivate(set) var fromAddress: String = ""
    fileprivate(set) var toAddress: String = ""
    fileprivate(set) var amount: Amount = Amount(0)

    fileprivate(set) var gasLimit: Amount = Amount(0)
    fileprivate(set) var gasPrice: Amount = Amount(0)
    fileprivate(set) var input: String = ""

    fileprivate(set) var accountAddress: String = ""
    fileprivate(set) var tokenInfo: TokenInfo = TokenInfo.BuildIn.eth.value

    fileprivate(set) var erc20ContractAddress: String = ""
    fileprivate(set) var erc20ToAddress: String = ""
    fileprivate(set) var erc20Amount: Amount = Amount(0)

    var ethTransactionType: TransactionType {
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

    var erc20TransactionType: TransactionType? {
        guard erc20ToAddress.isNotEmpty else { return nil }
        let from = fromAddress.lowercased()
        let to = erc20ToAddress.lowercased()
        let account = accountAddress.lowercased()

        if from == to {
            return .me
        } else if account == to {
            return .receive
        } else {
            return .send
        }
    }

    var isErc20: Bool { erc20ToAddress.isNotEmpty }

    public init?(map: Map) { }

    init(result: TransactionSendingResult, accountAddress: String, tokenInfo: TokenInfo, coinType: CoinType) {

        self.nonce = BigInt(result.transaction.nonce)
        self.timeStamp = Date()
        self.hash = result.hash

        self.fromAddress = accountAddress
        self.toAddress = result.transaction.to.address
        self.amount = Amount(result.transaction.value)

        self.gasLimit = Amount(result.transaction.gasLimit)
        self.gasPrice = Amount(result.transaction.gasPrice)
        self.input = "0x" + result.transaction.data.toHexString()

        self.accountAddress = accountAddress
        self.tokenInfo = tokenInfo

        switch coinType {
        case .eth:
            break
        case let .erc20(contractAddress, toAddress, amount):
            self.erc20ContractAddress = contractAddress
            self.erc20ToAddress = toAddress
            self.erc20Amount = amount
        }
    }

    mutating public func mapping(map: Map) {

        nonce <- (map["nonce"], JSONTransformer.bigint)
        timeStamp <- map["timeStamp"]
        hash <- map["hash"]

        fromAddress <- map["from"]
        toAddress <- map["to"]
        amount <- (map["value"], JSONTransformer.bigint)

        gasLimit <- (map["gasLimit"], JSONTransformer.bigint)
        gasPrice <- (map["gasPrice"], JSONTransformer.bigint)
        input <- map["input"]

        accountAddress <- map["accountAddress"]
        tokenInfo <- map["tokenInfo"]

        erc20ContractAddress <- map["erc20ContractAddress"]
        erc20ToAddress <- map["erc20ToAddress"]
        erc20Amount <- (map["erc20Amount"], JSONTransformer.bigint)
    }
}
