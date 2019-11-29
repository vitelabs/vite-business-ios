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
        case DEFAULT
        case PUB_TIME_DESC
        case SUB_TIME_REMAINING_ASC
        case YEAR_RATE_DESC
        case LOAN_DURATION_ASC
        case LOAN_COMPLETENESS_DESC
    }

    enum ProductStatus: Int {
        case all = 0
        case onSale = 1
        case failed = 2
        case success = 3
        case cancel = 4
    }

    case getDeFiProducts(sortType: ProductSortType, status: ProductStatus, address: ViteAddress?, offset: Int, limit: Int)

    var baseURL: URL {
        return URL(string: ViteConst.instance.vite.x)!
    }

    var path: String {
        switch self {
        case .getDeFiProducts:
            return "api/v1/defi/products/loan"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        switch self {
        case let .getDeFiProducts(sortType, status, address, offset, limit):
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
        }
    }

    var sampleData: Data {
        return Data()
    }

    var headers: [String: String]? {
        return nil
    }
}
