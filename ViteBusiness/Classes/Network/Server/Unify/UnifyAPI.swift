//
//  UnifyAPI.swift
//  ViteBusiness
//
//  Created by Stone on 2019/11/13.
//

import Moya
import ViteWallet

enum UnifyAPI: TargetType {
    case accountInit(address: ViteAddress)

    var baseURL: URL {
        return URL(string: ViteConst.instance.vite.growth)!
    }

    var path: String {
        switch self {
        case .accountInit:
            return "api/coin/v1/init"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        switch self {
        case .accountInit(let address):
            return .requestParameters(parameters: ["address": address], encoding: URLEncoding.queryString)
        }

    }

    var sampleData: Data {
        return Data()
    }

    var headers: [String: String]? {
        return nil
    }
}
