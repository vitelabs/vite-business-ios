//
//  COSAPI.swift
//  Vite
//
//  Created by Stone on 2018/11/5.
//  Copyright © 2018 vite labs. All rights reserved.
//

import Foundation
import Moya

enum ExchangeAPI {
    case getRate([TokenCode])
    case recommendTokenInfos
    case searchTokenInfo(String)
    case getTokenInfos([TokenCode])
    case getTokenInfoInChain(String, String)
    case getTokenInfosInChain(String, [String])
}

extension ExchangeAPI: TargetType {

    var baseURL: URL {
        return ExchangeServer.baseURL
    }

    var path: String {
        switch self {
        case .getRate:
            return "/api/v1/cryptocurrency/rate/assign"
        case .recommendTokenInfos:
            return "/api/v1/cryptocurrency/info/default"
        case .searchTokenInfo:
            return "/api/v1/cryptocurrency/info/search"
        case .getTokenInfos:
            return "/api/v1/cryptocurrency/info/assign"
        case .getTokenInfoInChain:
            return "/api/v1/cryptocurrency/info/query"
        case .getTokenInfosInChain:
            return "/api/v1/cryptocurrency/info/platform/query"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getRate:
            return .post
        case .recommendTokenInfos:
            return .get
        case .searchTokenInfo:
            return .get
        case .getTokenInfos:
            return .post
        case .getTokenInfoInChain:
            return .post
        case .getTokenInfosInChain:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .getRate(let tokenCodes):
            return .requestJSONEncodable(tokenCodes)
        case .recommendTokenInfos:
            return .requestPlain
        case .searchTokenInfo(let key):
            return .requestParameters(parameters: ["fuzzy": key], encoding: URLEncoding.queryString)
        case .getTokenInfos(let tokenCodes):
            return .requestJSONEncodable(tokenCodes)
        case .getTokenInfoInChain(let chain, let id):
            return .requestParameters(parameters: ["platformSymbol": chain, "tokenAddress": id], encoding: JSONEncoding.default)
        case .getTokenInfosInChain(let chain, let ids):
            return .requestParameters(parameters: ["platformSymbol": chain, "tokenAddresses": ids], encoding: JSONEncoding.default)
        }
    }

    var sampleData: Data {
        return Data()
    }

    var headers: [String: String]? {
        return nil
    }
}
