//
//  EthAPI.swift
//  ViteBusiness
//
//  Created by Stone on 2020/2/26.
//

import Moya
import ViteWallet

enum EthAPI: TargetType {
    case etherTransactions(address: String, page: Int, limit: Int)
    case erc20Transactions(address: String, contractAddress: String, page: Int, limit: Int)

    var baseURL: URL {
        return URL(string: ViteConst.instance.eth.api)!
    }

    var path: String {
        return "api"
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        var parameters = ["module": "account",
                          "sort": "desc"]
        switch self {
        case let .etherTransactions(address, page, limit):
            parameters["action"] = "txlist"
            parameters["address"] = address
            parameters["page"] = String(page)
            parameters["offset"] = String(limit)
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case let .erc20Transactions(address, contractAddress, page, limit):
            parameters["action"] = "tokentx"
            parameters["address"] = address
            parameters["contractaddress"] = contractAddress
            parameters["page"] = String(page)
            parameters["offset"] = String(limit)
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }

    var sampleData: Data {
        switch self {
        case let .etherTransactions(address, page, limit):
            let str = "{ }"
            return str.data(using: .utf8, allowLossyConversion: false)!
        case let .erc20Transactions(address, contractAddress, page, limit):
            let str = "{ }"
            return str.data(using: .utf8, allowLossyConversion: false)!
        }
    }

    var headers: [String: String]? {
        return nil
    }
}
