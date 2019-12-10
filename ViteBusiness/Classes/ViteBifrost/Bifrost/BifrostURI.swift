//
//  BifrostURI.swift
//  ViteBusiness
//
//  Created by Stone on 2019/6/11.
//

import enum Result.Result

public struct BifrostURI: URIType {

    public enum BifrostURIError: Error {
        case InvalidFormat(String)
        case scheme
        case InvalidTopic
        case InvalidChainId
        case InvalidBridge
        case InvalidKey
    }

    static let scheme: String = "vc"
    let topic: String
    let chainId: String
    let bridge: URL
    let key: String
    private let rawString: String

    static func parser(string: String) -> Result<BifrostURI, BifrostURIError> {
        guard let (prefix, suffix) = separate(string, by: ":") else {
            return Result(error: BifrostURIError.InvalidFormat(":"))
        }

        guard let topic_chainId_parametersString = suffix else {
            return Result(error: BifrostURIError.InvalidTopic)
        }

        guard prefix == scheme else {
            return Result(error: BifrostURIError.scheme)
        }

        guard let (topic_chainId, parametersString) = separate(topic_chainId_parametersString, by: "?") else {
            return Result(error: BifrostURIError.InvalidFormat("?"))
        }

        guard let (topic, c) = separate(topic_chainId, by: "@") else {
            return Result(error: BifrostURIError.InvalidFormat("@"))
        }

        guard let chainId = c else {
            return Result(error: BifrostURIError.InvalidChainId)
        }

        guard let p = parametersString else {
            return Result(error: BifrostURIError.InvalidBridge)
        }

        var b: String?
        var k: String?
        switch parser2Array(parameters: p) {
        case .success(let a):

            for (key, value) in a {
                if key == "bridge" {
                    b = value
                } else if key == "key" {
                    k = value
                }
            }
        case .failure:
            return Result(error: BifrostURIError.InvalidBridge)
        }

        guard let text = b?.removingPercentEncoding, let bridge = URL(string: text) else {
            return Result(error: BifrostURIError.InvalidBridge)
        }

        guard let key = k else {
            return Result(error: BifrostURIError.InvalidKey)
        }

        return Result.success(BifrostURI(topic: topic, chainId: chainId, bridge: bridge, key: key, rawString: string))
    }

    func string() -> String {
        return rawString
    }
}
