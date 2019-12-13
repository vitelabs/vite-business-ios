//
//  BnbURI.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/19.
//

import ViteWallet
import BigInt
import Vite_HDWalletKit
import enum Result.Result
import BinanceChain

public struct BnbURI: URIType {

    static let scheme: String = "binance"
    let address: String
    let amount: String?
    let bnbSymbol: String // unique token trade symbol in binance chain

    static func transferURI(address: String, amount: String?, bnbSymbol: String?) -> BnbURI {
        return BnbURI(address: address, amount: amount, bnbSymbol: bnbSymbol ?? "BNB")
    }

    func string() -> String {
//        var string = ""
//        string.append(BnbURI.scheme)
//        string.append(":")
//
//        string.append(address)
//        string.append("?")
//        if let amount = amount {
//            string.append(key: "amount", value: amount)
//        }
//
//        string.append(key: "symbol", value: bnbSymbol)
//
//        if string.hasSuffix("?") || string.hasSuffix("&") {
//            string = String(string.dropLast())
//        }

        return address
    }

    private static func parserForRawAddress(string: String) -> Result<BnbURI, URIError> {
        if string.checkBnbAddressIsValid() {
            return Result.success(BnbURI.transferURI(address: string, amount: nil, bnbSymbol: nil))
        } else {
            return Result.failure(URIError.InvalidAddress)
        }
    }

    static func parserForHasScheme(string: String) -> Result<BnbURI, URIError> {

        guard let (prefix, suffix) = separate(string, by: ":") else {
            return Result(error: URIError.InvalidFormat(":"))
        }

        guard let address_parametersString = suffix else {
            return Result(error: URIError.InvalidAddress)
        }

        guard let (address, parametersString) = separate(address_parametersString, by: "?") else {
            return Result(error: URIError.InvalidFormat("?"))
        }

        guard address.checkBnbAddressIsValid() else {
            return Result(error: URIError.InvalidAddress)
        }

        var amount: String? = nil
        var bnbSymbol: String? = nil

        if let string = parametersString {

            switch parser2Array(parameters: string) {
            case .success(let a):
                let map = a.reduce([String: String]()) { (ret, arg) -> [String: String] in
                    let (key, value) = arg
                    var map = ret
                    map[key] = value
                    return map
                }

                if let a = map["amount"] {
                    guard let _ = BigDecimal(a) else {
                        return Result(error: URIError.InvalidAmount)
                    }
                    amount = a
                }

                if let s = map["symbol"] {
                    // only check scheme if there is a symbol
                    guard prefix == scheme else {
                        return Result(error: URIError.scheme)
                    }
                    bnbSymbol = s
                }
            case .failure(let error):
                return Result(error: error)
            }
        }

        return Result.success(BnbURI.transferURI(address: address, amount: amount, bnbSymbol: bnbSymbol))
    }

    static func parser(string: String) -> Result<BnbURI, URIError> {
        if case .success(let uri) = parserForRawAddress(string: string) {
            return Result.success(uri)
        } else {
            return parserForHasScheme(string: string)
        }
    }
}
