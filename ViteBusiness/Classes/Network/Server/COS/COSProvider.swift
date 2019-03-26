//
//  COSProvider.swift
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
import ViteUtils
import enum Alamofire.Result

class COSProvider: MoyaProvider<COSAPI> {
    static let instance = COSProvider(manager: Manager(
        configuration: {
            var configuration = URLSessionConfiguration.default
            configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
            return configuration
    }(),
        serverTrustPolicyManager: ServerTrustPolicyManager(policies: [:])
    ))
}

extension COSProvider {

    func getConfigHash(completion: @escaping (Result<String?>) -> Void) {
        sendRequest(api: .getConfigHash, completion: completion)
    }

    func getLocalizable(language: ViteLanguage, completion: @escaping (Result<String?>) -> Void) {
        sendRequest(api: .getLocalizable(language.rawValue), completion: completion)
    }

    func getAppConfig(completion: @escaping (Result<String?>) -> Void) {
        sendRequest(api: .getAppConfig, completion: completion)
    }

    func checkUpdate(completion: @escaping (Result<String?>) -> Void) {
        sendRequest(api: .checkUpdate, completion: completion)
    }

    fileprivate func sendRequest(api: COSAPI, completion: @escaping (Result<String?>) -> Void) {
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
