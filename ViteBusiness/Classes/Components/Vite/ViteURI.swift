//
//  ViteURI.swift
//  Vite
//
//  Created by Stone on 2018/9/18.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import ViteWallet
import BigInt
import Vite_HDWalletKit
import enum Result.Result

protocol URIType {
    static func separate(_ string: String, by separator: String) -> (String, String?)?
}

extension URIType {
    static func separate(_ string: String, by separator: String) -> (String, String?)? {
        let segments = string.components(separatedBy: separator)
        let first = segments[0]
        var second: String? = nil

        if segments.count == 1 {
            // do nothing
        } else if segments.count == 2 {
            second = segments[1]
        } else {
            return nil
        }

        return (first, second)
    }

    static func parser2Array(parameters: String) -> Result<[(key: String, value: String)], URIError> {

        var array: [(String, String)] = []

        for string in parameters.components(separatedBy: "&") {
            guard let (key, v) = separate(string, by: "=") else {
                return Result(error: URIError.InvalidFormat("="))
            }

            guard key.isEmpty == false else {
                return Result(error: URIError.InvalidParameter)
            }

            guard let value = v else {
                return Result(error: URIError.InvalidParameter)
            }

            array.append((key, value))
        }

        return Result.success(array)
    }
}

public enum URIError: Error {
    case InvalidFormat(String)
    case scheme
    case InvalidAddress
    case InvalidFunctionName
    case InvalidTokenId
    case InvalidUserAddress
    case InvalidContractAddress
    case InvalidAmount
    case InvalidFee
    case InvalidData
    case InvalidParameter
}

public struct ViteURI: URIType {

    enum URIType {
        case transfer
        case contract
    }

    static let scheme: String = "vite"
    let address: ViteAddress
    let chainId: String?
    let type: URIType
    let functionName: String?

    let tokenId: ViteTokenId
    let amount: String?
    let fee: String?
    let data: Data?

    func amountForSmallestUnit(decimals: Int) -> Amount? {
        guard let amount = amount else { return Amount(0) }
        return amount.uriNumberTypeStringToBigint(decimals: decimals)
    }

    func feeForSmallestUnit(decimals: Int) -> Amount? {
        guard let fee = fee else { return Amount(0) }
        return fee.uriNumberTypeStringToBigint(decimals: decimals)
    }

    var parameters: [(String, String)]?

    static func transferURI(address: ViteAddress, tokenId: ViteTokenId?, amount: String?, note: String?) -> ViteURI {
        let data = note?.utf8StringToAccountBlockData()
        return ViteURI(address: address, chainId: nil, type: .transfer, functionName: nil, tokenId: tokenId, amount: amount, fee: nil, data: data, parameters: nil)
    }

    init(address: ViteAddress, chainId: String?, type: URIType, functionName: String?,
         tokenId: ViteTokenId?, amount: String?, fee: String?, data: Data?,
         parameters: [(String, String)]?) {
        self.address = address
        self.chainId = chainId
        self.type = type
        self.functionName = functionName
        self.tokenId = tokenId ?? ViteWalletConst.viteToken.id
        self.amount = amount
        self.fee = fee
        self.data = data
        self.parameters = parameters
    }

    func string() -> String {
        var string = ""

        string.append(ViteURI.scheme)
        string.append(":")
        string.append(address)

        if let chainId = chainId {
            string.append("@")
            string.append(chainId)
        }

        if case .contract = type {
            string.append("/")
            if let functionName = functionName {
                string.append(functionName)
            }
        }

        string.append("?")

        if tokenId != ViteWalletConst.viteToken.id  {
             string.append(key: "tti", value: tokenId)
        }

        if let amount = amount {
            string.append(key: "amount", value: amount)
        }

        if let fee = fee {
            string.append(key: "fee", value: fee)
        }

        if let data = data, !data.isEmpty {
            let base64 = Data(bytes: data).base64EncodedWithURLSafeString()
            string.append(key: "data", value: base64)
        }

        parameters?.forEach({ (key, value) in
            string.append(key: key, value: value)
        })

        if string.hasSuffix("?") || string.hasSuffix("&") {
            string = String(string.dropLast())
        }

        return string
    }

    static func parser(string: String) -> Result<ViteURI, URIError> {

        guard let (prefix, suffix) = separate(string, by: ":") else {
            return Result(error: URIError.InvalidFormat(":"))
        }

        guard let address_chainId_functionName_parametersString = suffix else {
            return Result(error: URIError.InvalidAddress)
        }

        guard prefix == scheme else {
            return Result(error: URIError.scheme)
        }

        guard let (address_chainId_functionName, parametersString) = separate(address_chainId_functionName_parametersString, by: "?") else {
            return Result(error: URIError.InvalidFormat("?"))
        }

        guard let (address_chainId, functionName) = separate(address_chainId_functionName, by: "/") else {
            return Result(error: URIError.InvalidFormat("/"))
        }

        let type: URIType = (functionName == nil) ? .transfer : .contract

        guard let (addressString, chainId) = separate(address_chainId, by: "@") else {
            return Result(error: URIError.InvalidFormat("@"))
        }

        let address = addressString

        guard address.isViteAddress else {
            return Result(error: URIError.InvalidAddress)
        }

        switch type {
        case .transfer:
            guard address.viteAddressType == .user else {
                return Result(error: URIError.InvalidUserAddress)
            }
        case .contract:
            guard address.viteAddressType == .contract else {
                return Result(error: URIError.InvalidContractAddress)
            }
        }

        var tokenId: ViteTokenId? = nil
        var amount: String? = nil
        var fee: String? = nil
        var data: Data? = nil
        var parameters: [(String, String)]? = nil

        if let string = parametersString {
            switch parser(parameters: string) {
            case .success(let (t, a, f, d, p)):

                if let t = t {
                    guard t.isViteTokenId else {
                        return Result(error: URIError.InvalidTokenId)
                    }
                    tokenId = t
                }

                if let a = a {
                    guard a.isUriNumberType else {
                        return Result(error: URIError.InvalidAmount)
                    }
                    amount = a
                }

                if let f = f {
                    guard f.isUriNumberType else {
                        return Result(error: URIError.InvalidFee)
                    }
                    fee = f
                }

                if let d = d {
                    guard let ret =  Data(base64EncodedWithURLSafe: d) else {
                        return Result(error: URIError.InvalidData)
                    }
                    data = ret
                }

                if !p.isEmpty {
                    parameters = p
                }
            case .failure(let error):
                return Result(error: error)
            }
        }

        return Result.success(ViteURI(address: address,
                                     chainId: chainId,
                                     type: type,
                                     functionName: functionName,
                                     tokenId: tokenId,
                                     amount: amount,
                                     fee: fee, data: data,
                                     parameters: parameters))
    }
}

extension ViteURI {

    fileprivate static func parser(parameters: String) -> Result<(tokenId: ViteTokenId?, amountString: String?, feeString: String?, dataString: String?, [(key: String, value: String)]), URIError> {

        var tokenId: ViteTokenId? = nil
        var amountString: String? = nil
        var feeString: String? = nil
        var dataString: String? = nil
        var array: [(String, String)] = []

        let ret = parser2Array(parameters: parameters)
        switch ret {
        case .success(let a):
            for (key, value) in a {
                if key == "tti" {
                    tokenId = value
                } else if key == "amount" {
                    amountString = value
                } else if key == "fee" {
                    feeString = value
                } else if key == "data" {
                    dataString = value
                } else {
                    array.append((key, value))
                }
            }
            return Result.success((tokenId, amountString, feeString, dataString, array))
        case .failure(let error):
            return Result(error: error as! URIError)
        }
    }
}

extension NSRegularExpression {
    fileprivate func match(input: String) -> Bool {
        let ret = matches(in: input, options: [], range: NSRange(location: 0, length: input.count))
        return ret.count > 0
    }

    fileprivate func match(in string: String, at index: Int) -> [String] {
        var ret: [String] = []
        let array = matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
        if let m = array.first {
            let range = m.range(at: index)
            if range.location != NSNotFound {
                let text = (string as NSString).substring(with: range) as String
                ret.append(text)
            }
        }
        return ret
    }
}

extension String {

    fileprivate static let uriNumberTypePattern = "^(?<i>[+-]?\\d+)([.]?(?<d>\\d*))?([eE](?<p>[+-]?\\d+))?$"

    fileprivate var isUriNumberType: Bool {
        let regex = try! NSRegularExpression(pattern: String.uriNumberTypePattern)
        return regex.match(input: self)
    }

    fileprivate func uriNumberTypeStringToBigint(decimals: Int) -> BigInt? {
        let regex = try! NSRegularExpression(pattern: String.uriNumberTypePattern)
        let i = regex.match(in: self, at: 1).first ?? "0"
        var d = regex.match(in: self, at: 3).first ?? ""
        let p = regex.match(in: self, at: 5).first ?? "0"

        while d.hasSuffix("0") {
            d = String(d.dropLast())
        }

        let count = d.count
        guard let pow = Int(p) else { return nil }
        guard decimals + pow >= count else { return nil }
        guard let base = BigInt(i + d) else { return nil }
        let ret = base * BigInt(10).power(decimals + pow - count)
        return ret
    }

    mutating func append(key: String, value: String) {
        self = "\(self)\(key)=\(value)&"
    }
}

extension BigInt {
    func toScientificNotationString(decimals: Int = 0) -> String {

        let bigintString = description
        guard bigintString != "0" else { return "0" }
        guard let i = bigintString.first else { return "0" }
        let d = String(bigintString.dropFirst())
        let count = d.count

        var ret = "\(i).\(d)"

        while ret.last == "0" {
            ret = String(ret.dropLast())
        }

        let pow = count - decimals

        if pow != 0 {
            ret = ret + "e" + String(pow)
        }

        return ret
    }
}
