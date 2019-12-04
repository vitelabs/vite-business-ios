//
//  DeFiAPI.swift
//  ViteBusiness
//
//  Created by Stone on 2019/11/13.
//

import Moya
import ViteWallet

enum DeFiAPI: TargetType {

    enum ProductSortType: String, CaseIterable {
        case PUB_TIME_DESC
        case SUB_TIME_REMAINING_ASC
        case YEAR_RATE_DESC
        case LOAN_DURATION_ASC
        case LOAN_COMPLETENESS_DESC
    }

    enum ProductStatus: Int, CaseIterable {
        case all = 0
        case onSale = 1
        case failed = 2
        case success = 3
        case cancel = 4
    }

    case getDeFiLoans(sortType: ProductSortType?, status: ProductStatus, address: ViteAddress?, offset: Int, limit: Int)
    case getSubscriptions(status: ProductStatus, address: ViteAddress?, offset: Int, limit: Int)

    case getProductDetail(hash: String)

    var baseURL: URL {
        return URL(string: ViteConst.instance.vite.x)!
    }

    var path: String {
        switch self {
        case .getDeFiLoans:
            return "api/v1/defi/products/loan"
        case .getSubscriptions:
            return "api/v1/defi/products/subscription"
        case .getProductDetail:
            return "api/v1/defi/product/loan"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        switch self {
        case let .getDeFiLoans(sortType, status, address, offset, limit):
            var parameters: [String: String] = [
                "productStatus": String(status.rawValue),
                "offset": String(offset),
                "limit": String(limit)
            ]

            if let sortType = sortType {
                parameters["orderBy"] = sortType.rawValue
            }

            if let address = address {
                parameters["address"] = address
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case let .getSubscriptions(status, address, offset, limit):
            var parameters: [String: String] = [
                "productStatus": String(status.rawValue),
                "offset": String(offset),
                "limit": String(limit)
            ]

            if let address = address {
                parameters["address"] = address
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case let .getProductDetail(hash):
            var parameters: [String: String] = [
                "productHash": hash,
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }

    var sampleData: Data {
        switch self {
        case .getDeFiLoans:
            return Data()
        case .getSubscriptions:
            return Data()
        case .getProductDetail:
            let str = "{  \"code\": 0,  \"msg\": \"ok\",  \"data\": {   \"productHash\": \"ab24ef68b84e642c0ddca06beec81c9acb1977bbd7da27a87a\",   \"subscriptionBeginTime\": 1554722699,   \"subscriptionEndTime\": 1554722699,   \"subscriptionFinishTime\": 1554722699,   \"yearRate\": \"0.02\",   \"loanAmount\": \"1000000000000000000000\",   \"subscriptionCopies\": 10000,   \"singleCopyAmount\": \"10000000000000000000\",   \"loanDuration\": 3,   \"subscribedAmount\": \"1000000000000000000000\",   \"loanCompleteness\": \"0.10\",   \"productStatus\": 1,   \"refundStatus\": 1  } }"
            return str.data(using: .utf8, allowLossyConversion: false) ?? Data()
        default:
            return Data()
        }
        return Data()
    }

    var headers: [String: String]? {
        return nil
    }
}
