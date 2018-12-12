//
//  Crypto.swift
//  Vite-keystore_Example
//
//  Created by Water on 2018/8/29.
//  Copyright © 2018年 Water. All rights reserved.
//

import CryptoSwift

final class Crypto {
    static func PBKDF2SHA512(password: [UInt8], salt: [UInt8]) -> Data {
        let output: [UInt8]
        do {
            output = try PKCS5.PBKDF2(password: password, salt: salt, iterations: 2048, variant: .sha512).calculate()
        } catch let error {
            fatalError("PKCS5.PBKDF2 faild: \(error.localizedDescription)")
        }
        return Data(output)
    }

    /// Computes the Ethereum hash of a block of data (SHA3 Keccak 256 version).
    static func sha3keccak256(_ data: Data) -> Data {
          return Data(bytes: SHA3(variant: .keccak256).calculate(for: data.bytes))
    }
}
