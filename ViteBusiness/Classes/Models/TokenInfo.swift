//
//  TokenInfo.swift
//  Pods
//
//  Created by Stone on 2019/2/21.
//

import ObjectMapper
import ViteWallet

public enum ChainType {
    case vite
    case eth
}

public struct TokenInfo: Mappable {

    var tokenCode: String = ""
    var chainType: ChainType = .vite
    var name: String = ""
    var symbol: String = ""
    var decimals: Int = 0
    var icon: String = ""
    var id: String = "" // Vite is tokenId, ERC20 is contractAddress

    public init?(map: Map) {}

    public mutating func mapping(map: Map) {
        tokenCode <- map["tokenCode"]
        chainType <- map["platform"]
        name <- map["name"]
        symbol <- map["symbol"]
        decimals <- map["decimals"]
        icon <- map["icon"]
        id <- map["tokenAddress"]
    }
}

extension TokenInfo {
    func toViteToken() -> Token? {
        guard chainType == .vite else {
            return nil
        }

        return Token(id: id, name: name, symbol: symbol, decimals: decimals)
    }

    func toETHToken() -> ETHToken? {
        guard chainType == .eth else {
            return nil
        }

        return ETHToken(contractAddress: id, name: name, symbol: symbol, decimals: decimals)
    }
}

