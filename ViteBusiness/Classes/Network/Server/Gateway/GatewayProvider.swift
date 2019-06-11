//
//  GatewayProvider.swift
//  Vite
//
//  Created by Stone on 2018/11/5.
//  Copyright © 2018 vite labs. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import Moya
import SwiftyJSON
import ObjectMapper
import PromiseKit
import enum Alamofire.Result

class GatewayProvider: MoyaProvider<GatewayAPI> {
    static let instance = GatewayProvider(manager: Manager(
        configuration: {
            var configuration = URLSessionConfiguration.default
            configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
            return configuration
    }(),
        serverTrustPolicyManager: ServerTrustPolicyManager(policies: [:])
    ))
}

extension GatewayProvider {

    func bind(_ context: GatewayBindContext) -> Promise<Void> {
        return Promise { seal in
            request(.bind(context), completion: { (ret) in
                switch ret {
                case .success(let response):
                    if let string = try? response.mapString(),
                        let body = ResponseBody(JSONString: string) {
                        if body.code == 200 {
                            seal.fulfill(())
                        } else {
                            seal.reject(GatewayError.response(body.code, body.message))
                        }
                    } else {
                        seal.reject(GatewayError.format)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            })
        }
    }

    enum GatewayError: Error {
        case format
        case response(Int, String)
        case notFound
    }

    struct ResponseBody: Mappable {
        var code: Int = -1
        var message: String = ""
        var json: Any = String()

        init?(map: Map) { }

        mutating func mapping(map: Map) {
            code <- map["code"]
            message <- map["msg"]
            json <- map["data"]
        }
    }
}
