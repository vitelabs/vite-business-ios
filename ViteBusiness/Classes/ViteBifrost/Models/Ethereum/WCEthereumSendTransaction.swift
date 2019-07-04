//
//  WCEthereumSendTransaction.swift
//  WalletConnect
//
//  Created by Tao Xu on 4/3/19.
//  Copyright © 2019 Trust. All rights reserved.
//

import Foundation
import ObjectMapper
import ViteWallet
import BigInt


public struct WCEthereumSendTransaction: Codable {
    public let from: String
    public let to: String
    public let nonce: String
    public let gasPrice: String
    public let gasLimit: String
    public let value: String
    public let data: String
}

public struct VBViteSendTransaction: Mappable {
    public var to: ViteAddress!
    public var tokenId: ViteTokenId!
    public var amount: Amount!
    public var data: Data?
    public var abi: String?
    public var description: Description?

    public init(to: ViteAddress, tokenId: ViteTokenId, data: Data?, abi: String?, description: Description?) {
        self.to = to
        self.tokenId = tokenId
        self.data = data
        self.abi = abi
        self.description = description
    }

    public init?(map: Map) {
        guard let to = map.JSON["to"] as? ViteAddress, to.isViteAddress else {
            return nil
        }

        guard let tokenId = map.JSON["tokenId"] as? ViteTokenId, to.isViteTokenId else {
            return nil
        }

        guard let amount = map.JSON["amount"] as? String, let _ = BigInt(amount) else {
            return nil
        }

        if let data = map.JSON["data"] as? String {
            guard let _ = Data(base64Encoded: data) else {
                return nil
            }
        }
    }

    public mutating func mapping(map: Map) {
        to <- map["to"]
        tokenId <- map["tokenId"]
        amount <- (map["amount"], JSONTransformer.balance)
        data <- (map["data"], JSONTransformer.dataToBase64)
        abi <- map["abi"]
        description <- map["description"]
    }

    public struct Description: Mappable {
        public var title: InputDescription = InputDescription(string: "")
        public var inputs: [InputDescription] = []

        init(title: InputDescription, inputs: [InputDescription]) {
            self.title = title
            self.inputs = inputs
        }

        public init?(map: Map) { }
        public mutating func mapping(map: Map) {
            title <- map["title"]
            inputs <- map["inputs"]
        }
    }


    public struct InputDescription: Mappable {

        fileprivate var base: String = ""
        fileprivate var localized: [String: String] = [:]

        public var valueTextColor: UIColor?
        public var backgroundColor: UIColor?

        public init(string: String) {
            self.base = string
        }

        public init?(map: Map) { }

        mutating public func mapping(map: Map) {
            base <- map["base"]
            localized <- map["localized"]
            valueTextColor <- map["color"]
            backgroundColor <- map["backgroundColor"]
        }

        public var title: String {
            return localized[LocalizationService.sharedInstance.currentLanguage.rawValue] ?? base
        }
    }
}
