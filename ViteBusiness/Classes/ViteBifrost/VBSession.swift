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

    public static func from(string: String) -> VBSession? {
        guard string .hasPrefix("vb:") else {
            return nil
        }

        let urlString = string.replacingOccurrences(of: "vb:", with: "vb://")
        guard let url = URL(string: urlString),
            let topic = url.user,
            let version = url.host,
            let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false) else {
                return nil
        }

        var dicts = [String: String]()
        for query in components.queryItems ?? [] {
            if let value = query.value {
                dicts[query.name] = value
            }
        }
        guard let bridge = dicts["bridge"],
            let bridgeUrl = URL(string: bridge),
            let key = dicts["key"] else {
                return nil
        }

        return VBSession(topic: topic, version: version, bridge: bridgeUrl, key: Data(hex: key))
    }
}
