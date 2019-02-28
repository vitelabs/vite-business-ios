//
//  ETHBalanceInfo.swift
//  Action
//
//  Created by Stone on 2019/2/26.
//

import Foundation
import ObjectMapper
import BigInt
import ViteWallet

public struct CommonBalanceInfo: Mappable {

    public fileprivate(set) var tokenCode = ""
    public fileprivate(set) var balance = Balance()

    public var tokenInfo: TokenInfo {
        guard let tokenInfo = MyTokenInfosService.instance.tokenInfo(for: tokenCode) else { fatalError() }
        return tokenInfo
    }

    public init?(map: Map) {

    }

    public init(tokenCode: String, balance: Balance) {
        self.tokenCode = tokenCode
        self.balance = balance
    }

    public mutating func mapping(map: Map) {
        tokenCode <- map["tokenCode"]
        balance <- (map["totalAmount"], JSONTransformer.balance)
    }
}
