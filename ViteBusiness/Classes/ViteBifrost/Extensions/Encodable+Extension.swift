//
//  Encodable+Extension.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/10.
//


import Foundation

extension Encodable {
    public var encoded: Data {
        let encoder = JSONEncoder()
//        encoder.outputFormatting = [.sortedKeys]
        return try! encoder.encode(self)
    }
    public var encodedString: String {
        return String(data: encoded, encoding: .utf8)!
    }
}
