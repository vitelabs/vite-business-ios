//
//  WCEthereumSendTransaction.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/10.
//

import Foundation
import ObjectMapper
import ViteWallet
import BigInt
import enum Result.Result
import PromiseKit
import SwiftyJSON

public struct VBViteSignMessage: Mappable {

    public var message: Data!

    public init?(map: Map) {
        guard let base64 = map.JSON["message"] as? String, let data = Data(base64Encoded: base64), !data.isEmpty else {
            return nil
        }
    }

    public mutating func mapping(map: Map) {
        message <- (map["message"], JSONTransformer.dataToBase64)
    }
}

public struct VBViteSignMessageResponse: Mappable {

    public var publicKey: String!
    public var signature: String!

    init(publicKey: String, signature: String) {
        self.publicKey = publicKey
        self.signature = signature
    }

    public init?(map: Map) {

    }

    public mutating func mapping(map: Map) {
        publicKey <- map["publicKey"]
        signature <- map["signature"]
    }
}
