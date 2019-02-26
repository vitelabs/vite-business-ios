//
//  ETHToken.swift
//  Pods
//
//  Created by Stone on 2019/2/21.
//

import ObjectMapper

public struct ETHToken: Mappable {

    public fileprivate(set) var contractAddress: String = ""
    public fileprivate(set) var name: String = ""
    public fileprivate(set) var symbol: String = ""
    public fileprivate(set) var decimals: Int = 0
    public fileprivate(set) var icon: String = ""

    public init(contractAddress: String = "", name: String = "", symbol: String = "", decimals: Int = 0) {
        self.contractAddress = contractAddress
        self.name = name
        self.symbol = symbol
        self.decimals = decimals
    }

    public init?(map: Map) {

    }

    public mutating func mapping(map: Map) {
        contractAddress <- map["contractAddress"]
        name <- map["tokenName"]
        symbol <- map["tokenSymbol"]
        decimals <- map["decimals"]
    }

    public func  isToken()->Bool {
        if contractAddress != "" {
            return true
        }else {
            return false
        }
    }
}
