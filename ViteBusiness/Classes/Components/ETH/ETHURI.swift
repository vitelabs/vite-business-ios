//
//  ETHURI.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/7.
//

import ViteWallet
import BigInt
import Vite_HDWalletKit
import enum Result.Result
import Web3swift

public struct ETHURI: URIType {

    enum URIType {
        case transfer
    }

    static let scheme: String = "ethereum"
    let address: String
    let type: URIType
    let contractAddress: String?
    let amount: String?

    static func transferURI(address: String, contractAddress: String?, amount: String?) -> ETHURI {
        return ETHURI(address: address, type: .transfer, contractAddress: contractAddress, amount: amount)
    }

    func string() -> String {
        var string = ""
        string.append(ETHURI.scheme)
        string.append(":")

        if let contractAddress = contractAddress, !contractAddress.isEmpty {
            string.append(contractAddress)
            string.append("/transfer?")
            string.append(key: "address", value: address)
            if let amount = amount {
                string.append(key: "uint256", value: amount)
            }
        } else {
            string.append(address)
            string.append("?")
            if let amount = amount {
                string.append(key: "value", value: amount)
            }
        }

        if string.hasSuffix("?") || string.hasSuffix("&") {
            string = String(string.dropLast())
        }

        return string
    }

    static func parser(string: String) -> Result<ETHURI, URIError> {

        // raw eth address
        if let address = EthereumAddress(string), address.isValid {
            return Result.success(ETHURI(address: string, type: .transfer, contractAddress: nil, amount: nil))
        }

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

        guard (functionName == nil || functionName == "transfer") else {
            return Result(error: URIError.InvalidFunctionName)
        }

        var type = URIType.transfer

        guard let (addressString, chainId) = separate(address_chainId, by: "@") else {
            return Result(error: URIError.InvalidFormat("@"))
        }

        var address = addressString

        guard let ethereumAddress = EthereumAddress(address), ethereumAddress.isValid else {
            return Result(error: URIError.InvalidAddress)
        }

        var contractAddress: String? = nil
        var amount: String? = nil
        var decimal: Int? = nil

        if let string = parametersString {

            switch parser2Array(parameters: string) {
            case .success(let a):
                let map = a.reduce([String: String]()) { (ret, arg) -> [String: String] in
                    let (key, value) = arg
                    var map = ret
                    map[key] = value
                    return map
                }

                if let a = map["address"] { // Official ERC20
                    guard let ethereumAddress = EthereumAddress(a), ethereumAddress.isValid else {
                        return Result(error: URIError.InvalidContractAddress)
                    }

                    contractAddress = address
                    address = a

                    guard functionName == "transfer" else {
                        return Result(error: URIError.InvalidFunctionName)
                    }

                    if let a = map["uint256"] {
                        guard let _ = BigInt(a) else {
                            return Result(error: URIError.InvalidAmount)
                        }
                        amount = a
                    }
                } else if let a = map["contractAddress"] { // imToken ERC20
                    guard let ethereumAddress = EthereumAddress(a), ethereumAddress.isValid else {
                        return Result(error: URIError.InvalidContractAddress)
                    }
                    contractAddress = a

                    guard functionName == nil else {
                        return Result(error: URIError.InvalidFunctionName)
                    }

                    if let a = map["value"] {
                        guard let _ = BigInt(a) else {
                            return Result(error: URIError.InvalidAmount)
                        }
                        amount = a
                    }
                } else { // Official Ether
                    guard functionName == nil else {
                        return Result(error: URIError.InvalidFunctionName)
                    }
                    
                    if let a = map["value"] {
                        guard let _ = BigInt(a) else {
                            return Result(error: URIError.InvalidAmount)
                        }
                        amount = a
                    }
                }
            case .failure(let error):
                return Result(error: error)
            }
        }

        return Result.success(ETHURI(address: address, type: type, contractAddress: contractAddress, amount: amount))

    }
}
