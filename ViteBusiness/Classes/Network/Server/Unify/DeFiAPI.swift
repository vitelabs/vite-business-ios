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

        var sortType: ProductSortType {
            switch self {
            case .all:
                return .LOAN_DURATION_ASC
            case .onSale:
                return .SUB_TIME_REMAINING_ASC
            case .failed:
                return .PUB_TIME_DESC
            case .success:
                return .PUB_TIME_DESC
            case .cancel:
                return .PUB_TIME_DESC
            }
        }
    }

    case getDeFiLoans(sortType: ProductSortType, status: ProductStatus, address: ViteAddress?, offset: Int, limit: Int)
    case getSubscriptions(status: ProductStatus, address: ViteAddress?, offset: Int, limit: Int)

    var baseURL: URL {
        return URL(string: ViteConst.instance.vite.x)!
    }

    var path: String {
        switch self {
        case .getDeFiLoans:
            return "api/v1/defi/products/loan"
        case .getSubscriptions:
            return "api/v1/defi/products/subscription"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        switch self {
        case let .getDeFiLoans(sortType, status, address, offset, limit):
            var parameters: [String: String] = [
                "orderBy": sortType.rawValue,
                "productStatus": String(status.rawValue),
                "offset": String(offset),
                "limit": String(limit)
            ]

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
        }
    }

    var sampleData: Data {
        return Data()
    }

    var headers: [String: String]? {
        return nil
    }
}
