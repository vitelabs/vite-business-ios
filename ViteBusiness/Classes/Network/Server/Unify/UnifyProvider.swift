//
//  UnifyProvider.swift
//  ViteBusiness
//
//  Created by Stone on 2019/11/13.
//

import RxSwift
import RxCocoa
import Alamofire
import Moya
import SwiftyJSON
import ObjectMapper
import enum Alamofire.Result
import ViteWallet
import PromiseKit

class UnifyProvider {
    static func provider<Target: TargetType>() -> MoyaProvider<Target> {

        return MoyaProvider<Target>(
            stubClosure: MoyaProvider<Target>.neverStub,
            manager: Manager(
            configuration: {
                var configuration = URLSessionConfiguration.default
                configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
                return configuration
        }(),
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: [:])
        ))

        return MoyaProvider<Target>(manager: Manager(
            configuration: {
                var configuration = URLSessionConfiguration.default
                configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
                return configuration
        }(),
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: [:])
        ))
    }
}

extension UnifyProvider {

    static func accountInit(address: ViteAddress) -> Promise<Void> {
        return Promise { seal in
            let p: MoyaProvider<UnifyAPI> = UnifyProvider.provider()
            p.request(.accountInit(address: address)) { (result) in
                switch result {
                case .success(let response):
                    seal.fulfill(Void())
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
}
