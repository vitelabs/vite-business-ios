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
    case getTokenInfo(TokenCode)
    case getTokenInfoInChain(String, String)
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
        case .getTokenInfo:
            return "/api/v1/cryptocurrency/info/assign"
        case .getTokenInfoInChain:
            return "/api/v1/cryptocurrency/info/search"
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
        case .getTokenInfo:
            return .get
        case .getTokenInfoInChain:
            return .get
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
        case .getTokenInfo(let tokenCode):
            return .requestParameters(parameters: ["token": tokenCode], encoding: URLEncoding.queryString)
        case .getTokenInfoInChain(let chain, let id):
            return .requestParameters(parameters: ["platformSymbol": chain, "tokenAddress": id], encoding: URLEncoding.queryString)
        }
    }

    var sampleData: Data {
        return Data()
    }

    var headers: [String: String]? {
        return nil
    }
}
