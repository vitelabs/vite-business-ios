//
//  ViteXAPI.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/17.
//

import Moya
import ViteWallet

enum ViteXAPI: TargetType {
    case getRate(tokenIds: [ViteTokenId])
    case getklines(symbol: String, type: MarketKlineType)
    case getDepth(symbol: String)
    case getTrades(symbol: String)
    case getPairDetailInfo(tradeTokenId: ViteTokenId, quoteTokenId: ViteTokenId)

    var baseURL: URL {
        return URL(string: ViteConst.instance.vite.x)!
    }

    var path: String {
        switch self {
        case .getRate: return "api/v1/exchange-rate"
        case .getklines: return "api/v1/klines"
        case .getDepth: return "api/v1/depth"
        case .getTrades: return "api/v1/trades"
        case .getPairDetailInfo: return "api/v1/operator/tradepair"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getRate: return .get
        case .getklines: return .get
        case .getDepth: return .get
        case .getTrades: return .get
        case .getPairDetailInfo: return .get
        }
    }

    var task: Task {
        switch self {
        case .getRate(let tokenIds):
            let parameters = ["tokenIds": tokenIds.joined(separator: ",")]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case let .getklines(symbol, type):
            let end = Date().timeIntervalSince1970
            let start = type.calcRequestStartTime(end: end, limit: 500)
            let parameters = [
                "startTime": "\(Int(start))",
                "endTime": "\(Int(end))",
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
        case let .getPairDetailInfo(tradeTokenId, quoteTokenId):
            let parameters = [
                "tradeToken": tradeTokenId,
                "quoteToken": quoteTokenId
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
