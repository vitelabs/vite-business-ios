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
    typealias ResponseToData = (JSON) throws -> String

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
    }

    #if DEBUG
    static func mock<Target: TargetType>() -> MoyaProvider<Target> {
        return MoyaProvider<Target>(
            stubClosure: MoyaProvider<Target>.immediatelyStub,
            manager: Manager(
            configuration: {
                var configuration = URLSessionConfiguration.default
                configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
                return configuration
        }(),
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: [:])
        ))
    }
    #endif
}

extension UnifyProvider {
    enum BackendError: Error, DisplayableError {
        case cancel
        case format
        case response(Int, String)
        case bodyFormat
        case invalidParameters

        var errorMessage: String {
            switch self {
            case .cancel:
                return "cancel"
            case .format:
                return "format error"
            case .response(let code, let msg):
                return "\(msg)(\(code))"
            case .bodyFormat:
                return "bodyFormat"
            case .invalidParameters:
                return "Invalid Parameters"
            }
        }
    }
}

extension MoyaProvider {

    static var viteResponseToData: UnifyProvider.ResponseToData {
        return { json throws -> String in
            guard let code = json["code"].int, let msg = json["msg"].string else {
                throw UnifyProvider.BackendError.format
            }
            guard code == 0 else {
                throw UnifyProvider.BackendError.response(code, msg)
            }
            guard let string = json["data"].rawString() else {
                throw UnifyProvider.BackendError.format
            }
            return string
        }
    }

    func requestPromise(_ target: Target, responseToData: @escaping UnifyProvider.ResponseToData = MoyaProvider.viteResponseToData, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none) -> Promise<String> {
        return Promise {[weak self] seal in
            guard let `self` = self else {
                seal.reject(UnifyProvider.BackendError.cancel)
                return
            }
            self.request(target, callbackQueue: callbackQueue, progress: progress) { (result) in
                switch result {
                case .success(let response):
                    guard let j = try? response.mapJSON() else {
                        seal.reject(UnifyProvider.BackendError.format)
                        return
                    }
                    let json = JSON(j)

                    do {
                        let string = try responseToData(json)
                        seal.fulfill(string)
                    } catch {
                        seal.reject(error)
                    }

//                    do {
//                        let string = try responseToData(json)
//                        seal.fulfill(string)
//                    } catch error {
//                        seal.reject(error)
//                    }
//                    guard let code = json["code"].int, let msg = json["msg"].string else {
//                        seal.reject(UnifyProvider.BackendError.format)
//                        return
//                    }
//                    guard code == 0 else {
//                        seal.reject(UnifyProvider.BackendError.response(code, msg))
//                        return
//                    }
//                    guard let string = json["data"].rawString() else {
//                        seal.reject(UnifyProvider.BackendError.format)
//                        return
//                    }
//                    seal.fulfill(string)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
}

extension UnifyProvider {

    static func accountInit(address: ViteAddress) -> Promise<Void> {
        let p: MoyaProvider<UnifyAPI> = UnifyProvider.provider()
        return p.requestPromise(.accountInit(address: address)).asVoid()
    }
}
