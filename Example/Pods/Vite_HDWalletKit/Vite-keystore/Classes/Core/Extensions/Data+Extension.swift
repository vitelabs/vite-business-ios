//
//  Data+Extension.swift
//  Vite-keystore
//
//  Created by Water on 2018/8/31.
//

import Foundation

extension Data {
    static func randomBytes(length: Int) -> Data {
        var bytes = Data(count: length)
        _ = bytes.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, length, $0) }
        return bytes
    }

    public func dataToHexString() -> String {
        return map { String(format: "%02x", $0) }.joined()
    }
}
