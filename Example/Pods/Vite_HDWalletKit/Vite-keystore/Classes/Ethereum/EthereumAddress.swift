//
//  HDBip.swift
//  Vite
//
//  Created by Stone on 2018/9/7.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import CryptoSwift
import BigInt

public struct EthereumAddress {
    /// Validates that the raw data is a valid address.
    static public func isValid(data: Data) -> Bool {
        return data.count == Ethereum.addressSize
    }

    /// Validates that the string is a valid address.
    static public func isValid(string: String) -> Bool {
        let address =  Data(hex: string)
        let eip55String = EthereumAddress.computeEIP55String(for: address)
        return string == eip55String
    }
}

extension EthereumAddress {
    /// Converts the address to an EIP55 checksumed representation.
    fileprivate static func computeEIP55String(for data: Data) -> String {
        let addressString = data.toHexString()
        let hashInput = addressString.data(using: .ascii)!
        let hash = Crypto.sha3keccak256(hashInput).toHexString()

        var string = "0x"
        for (a, h) in zip(addressString, hash) {
            switch (a, h) {
            case ("0", _), ("1", _), ("2", _), ("3", _), ("4", _), ("5", _), ("6", _), ("7", _), ("8", _), ("9", _):
                string.append(a)
            case (_, "8"), (_, "9"), (_, "a"), (_, "b"), (_, "c"), (_, "d"), (_, "e"), (_, "f"):
                string.append(contentsOf: String(a).uppercased())
            default:
                string.append(contentsOf: String(a).lowercased())
            }
        }

        return string
    }
}
