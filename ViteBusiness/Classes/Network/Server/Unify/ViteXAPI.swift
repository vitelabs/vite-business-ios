//
//  ViteXAPI.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/17.
//

import Moya
import ViteWallet

enum ViteXAPI: TargetType {
    case getLimit
    case getRate(tokenIds: [ViteTokenId])
    case getklines(symbol: String, type: MarketKlineType)
    case getDepth(symbol: String, limit: Int)
    case getTrades(symbol: String)
    case getPairDetailInfo(tradeTokenId: ViteTokenId, quoteTokenId: ViteTokenId)
    case getOpenedOrderlist(address: ViteAddress, tradeTokenSymbol: String, quoteTokenSymbol: String, offset: Int, limit: Int)

    case getTokenInfoDetail(TokenCode)
    case getMiningTrade(address: ViteAddress, offset: Int, limit: Int)
    
    var baseURL: URL {
        return URL(string: ViteConst.instance.vite.x)!
    }

    var path: String {
        switch self {
        case .getLimit: return "api/v2/limit"
        case .getRate: return "api/v2/exchange-rate"
        case .getklines: return "api/v2/klines"
        case .getDepth: return "api/v2/depth/all"
        case .getTrades: return "api/v2/trades/all"
        case .getPairDetailInfo: return "api/v1/operator/tradepair"
        case .getOpenedOrderlist: return "api/v2/orders/open"
        case .getTokenInfoDetail: return "/api/v1/cryptocurrency/info/detail"
        case .getMiningTrade: return "/api/v1/mining/trade"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getLimit: return .get
        case .getRate: return .get
        case .getklines: return .get
        case .getDepth: return .get
        case .getTrades: return .get
        case .getPairDetailInfo: return .get
        case .getOpenedOrderlist: return .get
        case .getTokenInfoDetail: return .post
        case .getMiningTrade: return .get
        }
    }

    var task: Task {
        switch self {
        case .getLimit:
            return .requestPlain
        case .getRate(let tokenIds):
            let parameters = ["tokenIds": tokenIds.joined(separator: ",")]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case let .getklines(symbol, type):
            let parameters = [
                "limit": "500",
                "symbol": symbol,
                "interval": type.requestParameter
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case let .getDepth(symbol, limit):
            let parameters = [
                "limit": "\(limit)",
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
        case let .getOpenedOrderlist(address, tradeTokenSymbol, quoteTokenSymbol, offset, limit):
            let parameters = [
                "address": address,
                "quoteTokenSymbol": quoteTokenSymbol,
                "tradeTokenSymbol": tradeTokenSymbol,
                "offset": String(offset),
                "limit": String(limit)
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .getTokenInfoDetail(let tokenCode):
            return .requestJSONEncodable([tokenCode])
        case let .getMiningTrade(address, offset, limit):
            let parameters = [
                "address": address,
                "offset": String(offset),
                "limit": String(limit)
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
