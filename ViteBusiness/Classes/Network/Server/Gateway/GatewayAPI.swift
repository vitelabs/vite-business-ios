//
//  GatewayAPI.swift
//  Vite
//
//  Created by Stone on 2018/11/5.
//  Copyright © 2018 vite labs. All rights reserved.
//

import Foundation
import Moya
import ObjectMapper
import BigInt
import ViteWallet

enum GatewayAPI {
    case bind(GatewayBindContext)
}

extension GatewayAPI: TargetType {

    var baseURL: URL {
        return URL(string: ViteConst.instance.vite.gateway)!
    }

    var path: String {
        switch self {
        case .bind:
            return "/gw/bind"
        }
    }

    var method: Moya.Method {
        switch self {
        case .bind:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .bind(let context):
            return .requestParameters(parameters: context.toJSON(), encoding: JSONEncoding.default)
        }
    }

    var sampleData: Data {
        return Data()
    }

    var headers: [String: String]? {
        return nil
    }
}
