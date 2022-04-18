//
//  ViteXAPI.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/17.
//

import Moya
import ViteWallet
import RxSwift
import Foundation

enum ViteXAPI: TargetType {
    case getMarketsClosed
    case getLimit
    case getRate(tokenIds: [ViteTokenId])
    case getklines(symbol: String, type: MarketKlineType)
    case getDepth(symbol: String, limit: Int)
    case getTrades(symbol: String)
    case getPairDetailInfo(tradeTokenId: ViteTokenId, quoteTokenId: ViteTokenId)
    case getOpenedOrderlist(address: ViteAddress, tradeTokenSymbol: String, quoteTokenSymbol: String, offset: Int, limit: Int)
    case getOrderlist(address: ViteAddress, tradeTokenSymbol: String?, quoteTokenSymbol: String?, startTime: TimeInterval?, side: Int32?, status: MarketOrder.Status?, offset: Int, limit: Int)

    case getTokenInfoDetail(TokenCode)
    case getMiningTrade(address: ViteAddress, offset: Int, limit: Int)
    case getMiningPledge(address: ViteAddress, offset: Int, limit: Int)
    case getInviter(address: ViteAddress)
    case getMiningInviter(address: ViteAddress, offset: Int, limit: Int)
    case getMiningOrderInviter(address: ViteAddress, offset: Int, limit: Int)
    case getDexTokenInfos
    case getDexDepositWithdrawList(address: ViteAddress, viteTokenId: ViteTokenId, offset: Int, limit: Int)
    case getFullNodeTotalPledgeAmount(address: ViteAddress)
    
    var baseURL: URL {
        switch self {
        case .getOrderlist: return URL(string: "https://vitex.vite.net")!
        default: return URL(string: ViteConst.instance.vite.x)!
        }
        return URL(string: ViteConst.instance.vite.x)!
    }

    var path: String {
        switch self {
        case .getMarketsClosed: return "/api/v2/markets/closed"
        case .getLimit: return "api/v2/limit"
        case .getRate: return "api/v2/exchange-rate"
        case .getklines: return "api/v2/klines"
        case .getDepth: return "api/v2/depth/all"
        case .getTrades: return "api/v2/trades/all"
        case .getPairDetailInfo: return "api/v1/operator/tradepair"
        case .getOpenedOrderlist: return "api/v2/orders/open"
        case .getOrderlist: return "api/v1/orders"
        case .getTokenInfoDetail: return "/api/v1/cryptocurrency/info/detail"
        case .getMiningTrade: return "/api/v1/mining/trade"
        case .getMiningPledge: return "/api/v1/mining/pledge"
        case .getInviter: return "api/v1/inviter"
        case .getMiningInviter: return "api/v1/mining/invite"
        case .getMiningOrderInviter: return "api/v1/mining/order/invite"
        case .getDexTokenInfos: return "api/v1/cryptocurrency/dex/tokens"
        case .getDexDepositWithdrawList: return "/api/v2/deposit-withdraw"
        case .getFullNodeTotalPledgeAmount: return "/reward/pledge/full/stat"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getMarketsClosed: return .get
        case .getLimit: return .get
        case .getRate: return .get
        case .getklines: return .get
        case .getDepth: return .get
        case .getTrades: return .get
        case .getPairDetailInfo: return .get
        case .getOpenedOrderlist: return .get
        case .getOrderlist: return .get
        case .getTokenInfoDetail: return .post
        case .getMiningTrade: return .get
        case .getMiningPledge: return .get
        case .getInviter: return .get
        case .getMiningInviter: return .get
        case .getMiningOrderInviter: return .get
        case .getDexTokenInfos: return .get
        case .getDexDepositWithdrawList: return .get
        case .getFullNodeTotalPledgeAmount: return .get
        }
    }

    var task: Task {
        switch self {
        case .getMarketsClosed:
            return .requestPlain
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
        case let .getOrderlist(address, tradeTokenSymbol, quoteTokenSymbol, startTime, side, status, offset, limit):
            var parameters = [
                "address": address,
                "offset": String(offset),
                "limit": String(limit)
            ]
            
            if let t = tradeTokenSymbol, let q = quoteTokenSymbol {
                parameters["tradeTokenSymbol"] = t
                parameters["quoteTokenSymbol"] = q
            }
            
            if let s = startTime {
                parameters["startTime"] = String(Int(s))
            }
            
            if let s = side {
                parameters["side"] = String(s)
            }
            
            if let s = status {
                parameters["status"] = String(s.rawValue)
            }
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
        case let .getMiningPledge(address, offset, limit):
            let parameters = [
                "address": address,
                "offset": String(offset),
                "limit": String(limit)
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case let .getInviter(address):
            let parameters = [
                "address": address
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case let .getMiningInviter(address, offset, limit):
            let parameters = [
                "address": address,
                "offset": String(offset),
                "limit": String(limit)
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case let .getMiningOrderInviter(address, offset, limit):
            let parameters = [
                "address": address,
                "offset": String(offset),
                "limit": String(limit)
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .getDexTokenInfos:
            return .requestPlain
        case let .getDexDepositWithdrawList(address, viteTokenId, offset, limit):
            let parameters = [
                "address": address,
                "tokenId": viteTokenId,
                "offset": String(offset),
                "limit": String(limit)
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case let .getFullNodeTotalPledgeAmount(address):
            let parameters = [
                "address": address
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
