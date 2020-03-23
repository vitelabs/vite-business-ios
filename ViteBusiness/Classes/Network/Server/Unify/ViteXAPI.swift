//
//  ViteXAPI.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/17.
//

import Moya
import ViteWallet

enum ViteXAPI: TargetType {
    case getklines(symbol: String, type: MarketKlineType)
    case getDepth(symbol: String)
    case getTrades(symbol: String)

    var baseURL: URL {
        return URL(string: ViteConst.instance.vite.x)!
    }

    var path: String {
        switch self {
        case .getklines: return "api/v1/klines"
        case .getDepth: return "api/v1/depth"
        case .getTrades: return "api/v1/trades"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        switch self {
        case let .getklines(symbol, type):
            let parameters = [
                "startTime": "0",
                "endTime": "\(Int(Date().timeIntervalSince1970))",
                "limit": "200",
                "symbol": symbol,
                "interval": type.requestParameter
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case let .getDepth(symbol):
            let parameters = [
                "step": "6",
                "limit": "200",
                "symbol": symbol
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case let .getTrades(symbol):
            let parameters = [
                "limit": "200",
                "symbol": symbol
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }

    var sampleData: Data {
        return Data()
    }

    var headers: [String: String]? {
        return nil
    }
}
