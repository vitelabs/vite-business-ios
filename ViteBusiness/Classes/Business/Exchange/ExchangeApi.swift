//
//  ExchangeAPI.swift
//  Action
//
//  Created by haoshenyang on 2019/7/25.
//

import Foundation
import Moya

enum ExchangeApi {
    case getRate(address: String)
    case getHistory(address: String, market: String, pageSize: Int, pageNumber: Int)
    case report(address: String, market: String, hash: String)
}

extension ExchangeApi: TargetType {

    var baseURL: URL {
        return URL(string: ViteConst.instance.vite.exchange)!
    }

    var path: String {
        switch self {
        case .getRate:
            return "/api/coin/convert/v1/convert_rate"
        case .getHistory:
            return "/api/coin/convert/v1/history"
        case .report:
            return "/api/coin/convert/v1/exchange"

        }
    }

    var method: Moya.Method {
        switch self {
        case .getRate:
            return .get
        case .getHistory:
            return .get
        case .report:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .getRate(let address):
            return .requestParameters(parameters: ["address": address],
                                      encoding: URLEncoding.queryString)
        case .getHistory(let address, let market, let pageSize, let pageNumber):
            return .requestParameters(parameters: ["address": address,
                                                    "market": market,
                                                    "pageSize": pageSize,
                                                    "pageIndex": pageNumber],
                                      encoding: URLEncoding.queryString)
        case .report(let address, let market, let hash):
            let parameters = ["address": address,
                              "market": market,
                              "hash": hash] as [String : Any]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }

    var sampleData: Data {
        return Data()
    }

    var headers: [String: String]? {
        return nil
    }
}
