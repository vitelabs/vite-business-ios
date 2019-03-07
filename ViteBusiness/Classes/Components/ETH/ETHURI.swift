//
//  ETHURI.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/7.
//

import ViteWallet


public struct ETHURI {

    enum URIType {
        case transfer
    }

    static let scheme: String = "ethereum"
    let address: String
    let type: URIType
    let contractAddress: String?
    let decimal: Int
    let amount: String

    static func transferURI(address: String, contractAddress: String?, decimal: Int, amount: String?) -> ETHURI {
        return ETHURI(address: address, type: .transfer, contractAddress: contractAddress, decimal: decimal, amount: amount ?? "0")
    }

    func string() -> String {
        var string = ""

        string.append(ETHURI.scheme)
        string.append(":")
        string.append(address)
        string.append("?")

        if let contractAddress = contractAddress {
            string.append(key: "contractAddress", value: contractAddress)
        }

        string.append(key: "decimal", value: String(decimal))
        string.append(key: "value", value: amount)

        if string.hasSuffix("?") || string.hasSuffix("&") {
            string = String(string.dropLast())
        }

        return string
    }
}
