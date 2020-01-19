//
//  VBSession.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/10.
//


import Foundation
import CryptoSwift

public struct VBSession {
    public let topic: String
    public let version: String
    public let bridge: URL
    public let key: Data

    public static func from(uri: BifrostURI) -> VBSession {
        return VBSession(topic: uri.topic, version: uri.chainId, bridge: uri.bridge, key: Data(hex: uri.key))
    }
}
