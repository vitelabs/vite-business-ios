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

public struct VBViteSendTx: Mappable {

    public var block: Block!
    public var abi: String?
    public var description: Description?
    public var extend: [String: Any]?

    public init(block: Block, abi: String?, description: Description?, extend: [String: Any]?) {
        self.block = block
        self.abi = abi
        self.description = description
    }

    public init?(map: Map) {
        guard let json = map.JSON["block"] as? Dictionary<String, Any>,
            let _ = Block(JSON: json) else {
                return nil
        }
    }

    public mutating func mapping(map: Map) {
        block <- map["block"]
        abi <- map["abi"]
        description <- map["description"]
        extend <- map["extend"]
    }
}

extension VBViteSendTx {
    public struct Block: Mappable {
        public var toAddress: ViteAddress!
        public var tokenId: ViteTokenId!
        public var amount: Amount!
        public var fee: Amount?
        public var data: Data?

        public init?(map: Map) {
            guard let toAddress = map.JSON["toAddress"] as? ViteAddress, toAddress.isViteAddress else {
                return nil
            }

            guard let tokenId = map.JSON["tokenId"] as? ViteTokenId, tokenId.isViteTokenId else {
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
            toAddress <- map["toAddress"]
            tokenId <- map["tokenId"]
            amount <- (map["amount"], JSONTransformer.balance)
            fee <- (map["fee"], JSONTransformer.balance)
            data <- (map["data"], JSONTransformer.dataToBase64)
        }
    }
}

extension VBViteSendTx {
    public struct Description: Mappable {
        public var function: InputDescription = InputDescription()
        public var inputs: [InputDescription] = []

        init(function: InputDescription, inputs: [InputDescription]) {
            self.function = function
            self.inputs = inputs
        }

        public init?(map: Map) { }
        public mutating func mapping(map: Map) {
            function <- map["function"]
            inputs <- map["inputs"]
        }
    }
}

extension VBViteSendTx {
    public struct InputDescription: Mappable {

        public struct Style: Mappable {
            public var textColor: UIColor?
            public var backgroundColor: UIColor?

            public init?(map: Map) {}

            public init(textColor: UIColor?, backgroundColor: UIColor?) {
                self.textColor = textColor
                self.backgroundColor = backgroundColor
            }

            public mutating func mapping(map: Map) {
                textColor <- (map["textColor"], type(of: self).TransformOfColor)
                backgroundColor <- (map["backgroundColor"], type(of: self).TransformOfColor)
            }

            static let TransformOfColor = TransformOf<UIColor, String>(fromJSON: { (string) -> UIColor? in
                guard let string = string, let color = UIColor(hexa: string) else { return nil }
                return color
            }, toJSON: { (color) -> String? in
                guard let color = color else { return nil }
                var r: CGFloat = 0
                var g: CGFloat = 0
                var b: CGFloat = 0
                var a: CGFloat = 0
                color.getRed(&r, green: &g, blue: &b, alpha: &a)
                let rInt = Int(r * 255) << 24
                let gInt = Int(g * 255) << 16
                let bInt = Int(b * 255) << 8
                let aInt = Int(a * 255)
                let rgba = rInt | gInt | bInt | aInt
                return String(format:"%08x", rgba)
            })

            static var blue: Style {
                return Style(textColor: UIColor(netHex: 0x007AFF), backgroundColor: UIColor(netHex: 0x007AFF, alpha: 0.06))
            }

            static var red: Style {
                return Style(textColor: UIColor(netHex: 0xFF0008), backgroundColor: UIColor(netHex: 0x007AFF, alpha: 0.06))
            }

            static var green: Style {
                return Style(textColor: UIColor(netHex: 0x5BC500), backgroundColor: UIColor(netHex: 0x007AFF, alpha: 0.06))
            }
        }

        fileprivate var name: [String: String] = [:]
        fileprivate var style: Style?

        init() {}

        public init?(map: Map) { }

        init(name: String, style: Style? = nil) {
            self.name["base"] = name
            self.style = style
        }

        mutating public func mapping(map: Map) {
            name <- map["name"]
            style <- map["style"]
        }

        public var title: String? {
            let key = LocalizationService.sharedInstance.currentLanguage.code
            return name[key] ?? name["base"]
        }

        public func confirmItemInfo(text: String, textColor: UIColor? = nil, backgroundColor: UIColor? = nil) -> BifrostConfirmItemInfo {
            return BifrostConfirmItemInfo(title: title ?? "", text: text, textColor: textColor ?? style?.textColor, backgroundColor: backgroundColor ?? style?.backgroundColor)
        }
    }
}
