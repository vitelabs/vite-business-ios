//
//  TokenInfoProvider.swift
//  ViteBusiness
//
//  Created by Water on 2019/2/25.
//

import UIKit
import Alamofire
import Moya
import ViteBusiness
import enum Alamofire.Result

class TokenInfoProvider: MoyaProvider<TokenInfoAPI> {
    static let instance = TokenInfoProvider(manager: Manager(
        configuration: {
            var configuration = URLSessionConfiguration.default
            configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
            return configuration
    }(),
        serverTrustPolicyManager: ServerTrustPolicyManager(policies: [:])
    ))
}

extension TokenInfoProvider {

    func getAllList(completion: @escaping (Result<String?>) -> Void) {
        sendRequest(api: .getAllList, completion: completion)
    }

    fileprivate func sendRequest(api: TokenInfoAPI, completion: @escaping (Result<String?>) -> Void) {
        request(api) { (result) in
            switch result {
            case .success(let response):
                if let string = try? response.mapString() {
                    completion(Result.success(string))
                } else {
                    completion(Result.success(nil))
                }
            case .failure(let error):
                completion(Result.failure(error))
            }
        }
    }
}

