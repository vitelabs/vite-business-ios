//
//  Data+Hex.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/10.
//


import Foundation
import CryptoSwift

extension Data {
    var hex: String {
        return self.toHexString()
    }
}

extension JSONEncoder {
    func encodeAsUTF8<T>(_ value: T) -> String where T : Encodable {
        guard let data = try? self.encode(value),
            let string = String(data: data, encoding: .utf8) else {
            return ""
        }
        return string
    }
}
