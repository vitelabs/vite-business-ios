//
//  UnifyProvider+ViteXAPI.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/17.
//

import RxSwift
import RxCocoa
import Alamofire
import Moya
import SwiftyJSON
import ObjectMapper
import enum Alamofire.Result
import ViteWallet
import APIKit
import JSONRPCKit
import PromiseKit
import Alamofire
import BigInt

extension UnifyProvider {
    struct vitex {}
}

extension UnifyProvider.vitex {

    private static var responseToData: UnifyProvider.ResponseToData {
        return { json throws -> String in
            guard let code = json["code"].int else {
                throw UnifyProvider.BackendError.format
            }

            guard code == 0 else {
                throw UnifyProvider.BackendError.response(code, json["msg"].string ?? "")
            }
            guard let string = json["data"].rawString() else {
                throw UnifyProvider.BackendError.format
            }
            if string == "null" {
                return "{}"
            } else {
                return string
            }
        }
    }
    
    static func getMarketsClosedSymbols() -> Promise<[String]> {
        let p: MoyaProvider<ViteXAPI> = UnifyProvider.provider()
        return p.requestPromise(.getMarketsClosed, responseToData: responseToData).map { string in
            var ret = [String]()
            if let json = JSON(parseJSON: string).array {
                json.forEach({
                    if let symbol = $0["symbol"].string, symbol.isNotEmpty {
                        ret.append(symbol)
                    }
                })
            }
            return ret
        }
    }

    static func getLimit() -> Promise<MarketLimit> {
        let p: MoyaProvider<ViteXAPI> = UnifyProvider.provider()
        return p.requestPromise(.getLimit, responseToData: responseToData).map { string in
            let json = JSON(parseJSON: string)
            return MarketLimit(json: json)
        }
    }

    static func getRate(tokenIds: [ViteTokenId]) -> Promise<ExchangeRateMap> {
        let p: MoyaProvider<ViteXAPI> = UnifyProvider.provider()
        return p.requestPromise(.getRate(tokenIds: tokenIds), responseToData: responseToData).map { string in
            var map = ExchangeRateMap()
            if let json = JSON(parseJSON: string).array {
                json.forEach({
                    if let tokenCode = $0["tokenCode"].string,
                        let usd = $0["usd"].string,
                        let cny = $0["cny"].string {
                        map[tokenCode] = [
                            "usd": usd,
                            "cny": cny
                        ]
                    }
                })
            }
            return map
        }
    }

    static func getKlines(symbol: String, type: MarketKlineType) -> Promise<[KlineItem]> {
        let p: MoyaProvider<ViteXAPI> = UnifyProvider.provider()
        return p.requestPromise(.getklines(symbol: symbol, type: type), responseToData: responseToData).map { string in
            let json = JSON(parseJSON: string)
            guard let tArray = json["t"].arrayObject as? [Int64],
                let cArray = json["c"].arrayObject as? [Double],
                let oArray = json["p"].arrayObject as? [Double],
                let hArray = json["h"].arrayObject as? [Double],
                let lArray = json["l"].arrayObject as? [Double],
                let vArray = json["v"].arrayObject as? [Double] else {
                    throw UnifyProvider.BackendError.format
            }

            guard tArray.count == cArray.count,
                tArray.count == oArray.count,
                tArray.count == hArray.count,
                tArray.count == lArray.count,
                tArray.count == vArray.count else {
                    throw UnifyProvider.BackendError.format
            }

            let klineItems = (0..<tArray.count).map {
                KlineItem(t: tArray[$0], c: cArray[$0], o: oArray[$0], h: hArray[$0], l: lArray[$0], v: vArray[$0])
            }

            return klineItems
        }
    }

    static func getDepth(symbol: String, limit: Int) -> Promise<MarketDepthList> {
        let p: MoyaProvider<ViteXAPI> = UnifyProvider.provider()
        return p.requestPromise(.getDepth(symbol: symbol, limit: limit), responseToData: responseToData).map { string in
            guard let ret = MarketDepthList(JSONString: string) else {
                throw UnifyProvider.BackendError.format
            }
            ret.calcPercent()
            return ret
        }
    }

    static func getTrades(symbol: String) -> Promise<[MarketTrade]> {
        let p: MoyaProvider<ViteXAPI> = UnifyProvider.provider()
        return p.requestPromise(.getTrades(symbol: symbol), responseToData: responseToData).map { string in
            let json = JSON(parseJSON: string)
            guard let trade = json["trade"].rawString(),
                let ret = [MarketTrade](JSONString: trade) else {
                throw UnifyProvider.BackendError.format
            }
            return ret
        }
    }

    static func getPairDetailInfo(tradeTokenId: ViteTokenId, quoteTokenId: ViteTokenId) -> Promise<MarketPairDetailInfo> {
        let p: MoyaProvider<ViteXAPI> = UnifyProvider.provider()
        return p.requestPromise(.getPairDetailInfo(tradeTokenId: tradeTokenId, quoteTokenId: quoteTokenId), responseToData: responseToData).map { string in
            guard let ret = MarketPairDetailInfo(JSONString: string) else {
                throw UnifyProvider.BackendError.format
            }
            return ret
        }
    }

    static func getOpenedOrderlist(address: ViteAddress, tradeTokenSymbol: String, quoteTokenSymbol: String, offset: Int, limit: Int) -> Promise<[MarketOrder]> {
        let p: MoyaProvider<ViteXAPI> = UnifyProvider.provider()
        return p.requestPromise(.getOpenedOrderlist(address: address, tradeTokenSymbol: tradeTokenSymbol, quoteTokenSymbol: quoteTokenSymbol, offset: offset, limit: limit), responseToData: responseToData).map { string in
            let json = JSON(parseJSON: string)
            guard let order = json["order"].rawString(),
                let ret = [MarketOrder](JSONString: order) else {
                throw UnifyProvider.BackendError.format
            }
            return ret
        }
    }
    
    static func getOrderlist(address: ViteAddress, tradeTokenSymbol: String?, quoteTokenSymbol: String?, startTime: TimeInterval?, side: Int32?, status: MarketOrder.Status?, offset: Int, limit: Int) -> Promise<[MarketOrder]> {
        let p: MoyaProvider<ViteXAPI> = UnifyProvider.provider()
        return p.requestPromise(.getOrderlist(address: address, tradeTokenSymbol: tradeTokenSymbol, quoteTokenSymbol: quoteTokenSymbol, startTime: startTime, side: side, status: status, offset: offset, limit: limit), responseToData: responseToData).map { string in
            let json = JSON(parseJSON: string)
            guard let order = json["order"].rawString(),
                let ret = [MarketOrder](JSONString: order) else {
                throw UnifyProvider.BackendError.format
            }
            return ret
        }
    }
    
    static func getTokenInfoDetail(tokenCode: TokenCode) -> Promise<TokenInfoDetail> {
        let p: MoyaProvider<ViteXAPI> = UnifyProvider.provider()
        return p.requestPromise(.getTokenInfoDetail(tokenCode), responseToData: responseToData).map { string in

            guard let array = [TokenInfoDetail](JSONString: string), let ret = array.first else {
                throw UnifyProvider.BackendError.format
            }

            return ret
        }
    }
}

// Mining
extension UnifyProvider.vitex {
    static func getMiningTradeDetail(address: ViteAddress, offset: Int, limit: Int) -> Promise<MiningTradeDetail> {
        let p: MoyaProvider<ViteXAPI> = UnifyProvider.provider()
        return p.requestPromise(.getMiningTrade(address: address, offset: offset, limit: limit), responseToData: responseToData).map { string in
            let json = JSON(parseJSON: string)
            guard let ret = MiningTradeDetail(JSONString: string) else {
                throw UnifyProvider.BackendError.format
            }
            return ret
        }
    }

    static func getMiningTradePledge(address: ViteAddress, offset: Int, limit: Int) -> Promise<MiningPledgeDetail> {
        let p: MoyaProvider<ViteXAPI> = UnifyProvider.provider()
        return p.requestPromise(.getMiningPledge(address: address, offset: offset, limit: limit), responseToData: responseToData).map { string in
            let json = JSON(parseJSON: string)
            guard let ret = MiningPledgeDetail(JSONString: string) else {
                throw UnifyProvider.BackendError.format
            }
            return ret
        }
    }
    
    static func getMiningInviteDetail(address: ViteAddress, offset: Int, limit: Int) -> Promise<MiningInviteDetail> {
        let p: MoyaProvider<ViteXAPI> = UnifyProvider.provider()
        
        let inviterString = p.requestPromise(.getInviter(address: address), responseToData: responseToData)
        let miningInviterString = p.requestPromise(.getMiningInviter(address: address, offset: offset, limit: limit), responseToData: responseToData)
        let miningOrderInviterString = p.requestPromise(.getMiningOrderInviter(address: address, offset: offset, limit: limit), responseToData: responseToData)
        
        return when(fulfilled: inviterString, miningInviterString, miningOrderInviterString).map { i, m, o -> MiningInviteDetail in
            let ij = JSON(parseJSON: i)
            let mj = JSON(parseJSON: m)
            let oj = JSON(parseJSON: o)
            
            let json: JSON = [
              "inviter": ij.dictionaryObject,
              "miningInvite": mj.dictionaryObject,
              "miningOrderInvite": oj.dictionaryObject
            ]
            
            guard let string = json.rawString() else {
                throw UnifyProvider.BackendError.format
            }
            
            guard let ret = MiningInviteDetail(JSONString: string) else {
                throw UnifyProvider.BackendError.format
            }
            return ret
        }
    }
    
    static func getMiningOrderDetail(address: ViteAddress, offset: Int, limit: Int) -> Promise<(MiningOrderDetail, MiningOrderDetail.Estimate)> {
        let p: MoyaProvider<ViteXAPI> = UnifyProvider.provider()
        
        let estimateString = p.requestPromise(.getMiningEstimate(address: address), responseToData: responseToData)
        let orderString = p.requestPromise(.getMiningOrder(address: address, offset: offset, limit: limit), responseToData: responseToData)
        
        return when(fulfilled: estimateString, orderString).map { e, o -> (MiningOrderDetail, MiningOrderDetail.Estimate) in
            guard let detail = MiningOrderDetail(JSONString: o) else {
                throw UnifyProvider.BackendError.format
            }
            guard let estimate = MiningOrderDetail.Estimate(JSONString: e) else {
                throw UnifyProvider.BackendError.format
            }
            return (detail, estimate)
        }
    }
}

// Dex
extension UnifyProvider.vitex {
    static func getDexTokenInfos() -> Promise<[TokenInfo]> {
        let p: MoyaProvider<ViteXAPI> = UnifyProvider.provider()
        return p.requestPromise(.getDexTokenInfos, responseToData: responseToData).map { string in
            guard let ret = [TokenInfo](JSONString: string) else {
                throw UnifyProvider.BackendError.format
            }
            return ret
        }
    }

    static func getDexDepositWithdrawList(address: ViteAddress, viteTokenId: ViteTokenId, offset: Int, limit: Int) -> Promise<[DexDepositWithdraw]> {
        let p: MoyaProvider<ViteXAPI> = UnifyProvider.provider()
        return p.requestPromise(.getDexDepositWithdrawList(address: address, viteTokenId: viteTokenId, offset: offset, limit: limit), responseToData: responseToData).map { string in
            let json = JSON(parseJSON: string)
            guard let record = json["record"].rawString(),
                let ret = [DexDepositWithdraw](JSONString: record) else {
                throw UnifyProvider.BackendError.format
            }
            return ret
        }
    }
}

// Full Node
extension UnifyProvider.vitex {
    static func getFullNodeTotalPledgeAmount(address: ViteAddress) -> Promise<Amount> {
        let p: MoyaProvider<ViteXAPI> = UnifyProvider.provider()
        return p.requestPromise(.getFullNodeTotalPledgeAmount(address: address), responseToData: responseToData).map { string in
            let json = JSON(parseJSON: string)
            guard let string = json["pledgeAmount"].string,
                let bigDecimal = BigDecimal(string) else {
                throw UnifyProvider.BackendError.format
            }
            let ret = (bigDecimal * BigDecimal(BigInt(10).power(18))).round()
            return ret
        }
    }
}
