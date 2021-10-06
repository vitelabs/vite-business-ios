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
import enum Alamofire.Result

class ExchangeProvider: MoyaProvider<ExchangeAPI> {
    static let instance = ExchangeProvider(manager: Manager(
        configuration: {
            var configuration = URLSessionConfiguration.default
            configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
            return configuration
    }(),
        serverTrustPolicyManager: ServerTrustPolicyManager(policies: [:])
    ))
}

extension ExchangeProvider {

    @discardableResult
    func getRate(for tokenCodes: [TokenCode], completion: @escaping (Result<ExchangeRateMap>) -> Void) -> Cancellable {
        return sendRequest(api: .getRate(tokenCodes), completion: { (ret) in
            switch ret {
            case .success(let json):
                var map = ExchangeRateMap()
                if let json = json as? [[String: Any]] {
                    json.forEach({
                        if let tokenCode = $0["tokenCode"] as? String,
                           let btc = $0["btc"] as? String,
                           let rub = $0["rub"] as? String,
                           let krw = $0["krw"] as? String,
                           let `try` = $0["try"] as? String,
                           let vnd = $0["vnd"] as? String,
                           let eur = $0["eur"] as? String,
                           let gbp = $0["gbp"] as? String,
                            let usd = $0["usd"] as? String,
                            let cny = $0["cny"] as? String {
                            map[tokenCode] = [
                                "btc": btc,
                                "rub": rub,
                                "krw": krw,
                                "try": `try`,
                                "vnd": vnd,
                                "eur": eur,
                                "gbp": gbp,
                                "usd": usd,
                                "cny": cny
                            ]
                        }
                    })
                }
                completion(Result.success(map))
            case .failure(let error):
                completion(Result.failure(error))
            }
        })
    }

    @discardableResult
    func recommendTokenInfos(completion: @escaping (Result<[String: [TokenInfo]]>) -> Void) -> Cancellable {
        return sendRequest(api: .recommendTokenInfos, completion: { (ret) in
            switch ret {
            case .success(let json):
                var map = [String: [TokenInfo]]()
                if let json = json as? [String: Any] {
                    json.forEach({ (key, value) in
                        if let array = value as? [[String: Any]] {
                            map[key] = [TokenInfo](JSONArray: array).compactMap { $0 }
                        }
                    })
                }
                completion(Result.success(map))
            case .failure(let error):
                completion(Result.failure(error))
            }
        })
    }

    @discardableResult
    func searchTokenInfo(key: String, completion: @escaping (Result<[String: [TokenInfo]]>) -> Void) -> Cancellable {
        return sendRequest(api: .searchTokenInfo(key), completion: { (ret) in
            switch ret {
            case .success(let json):
                var map = [String: [TokenInfo]]()
                if let json = json as? [String: Any] {
                    json.forEach({ (key, value) in
                        if let array = value as? [[String: Any]] {
                            map[key] = [TokenInfo](JSONArray: array).compactMap { $0 }
                        }
                    })
                }
                completion(Result.success(map))
            case .failure(let error):
                completion(Result.failure(error))
            }
        })
    }

    @discardableResult
    func getTokenInfos(tokenCodes: [TokenCode], completion: @escaping (Alamofire.Result<[TokenInfo]>) -> Void) -> Cancellable {
        return sendRequest(api: .getTokenInfos(tokenCodes), completion: { (ret) in
            switch ret {
            case .success(let json):
                var map = [TokenCode: TokenInfo]()
                if let json = json as? [[String: Any]] {
                    let tokenInfos = [TokenInfo](JSONArray: json).compactMap { $0 }
                    tokenInfos.forEach({ (tokenInfo) in
                        map[tokenInfo.tokenCode] = tokenInfo
                    })
                }

                var tokenInfos = [TokenInfo]()
                for tokenCode in tokenCodes {
                    if let tokenInfo = map[tokenCode] {
                        tokenInfos.append(tokenInfo)
                    }
                }

                if tokenInfos.count == tokenCodes.count {
                    completion(Alamofire.Result.success(tokenInfos))
                } else {
                    completion(Alamofire.Result.failure(ExchangeError.notFound))
                }
            case .failure(let error):
                completion(Alamofire.Result.failure(error))
            }
        })
    }

    @discardableResult
    func getTokenInfo(tokenCode: TokenCode, completion: @escaping (Alamofire.Result<TokenInfo>) -> Void) -> Cancellable {
        return getTokenInfos(tokenCodes: [tokenCode], completion: { (ret) in
            switch ret {
            case .success(let tokenInfos):
                completion(Alamofire.Result.success(tokenInfos[0]))
            case .failure(let error):
                completion(Alamofire.Result.failure(error))
            }
        })
    }

    @discardableResult
    func getTokenInfo(chain: String, id: String, completion: @escaping (Alamofire.Result<TokenInfo>) -> Void) -> Cancellable {
        return sendRequest(api: .getTokenInfoInChain(chain, id), completion: { (ret) in
            switch ret {
            case .success(let json):
                var map = [String: TokenInfo]()
                if let json = json as? [[String: Any]] {
                    let tokenInfos = [TokenInfo](JSONArray: json).compactMap { $0 }
                    tokenInfos.forEach({ (tokenInfo) in
                        map[tokenInfo.id.lowercased()] = tokenInfo
                    })
                }
                if let tokenInfo = map[id.lowercased()] {
                    completion(Alamofire.Result.success(tokenInfo))
                } else {
                    completion(Alamofire.Result.failure(ExchangeError.notFound))
                }
            case .failure(let error):
                completion(Alamofire.Result.failure(error))
            }
        })
    }

    func getTokenInfos(chain: String, ids: [String], completion: @escaping (Result<[TokenInfo]>) -> Void) -> Cancellable {
        return sendRequest(api: .getTokenInfosInChain(chain, ids), completion: { (ret) in
            switch ret {
            case .success(let json):
                var map = [String: TokenInfo]()
                if let json = json as? [[String: Any]] {
                    let tokenInfos = [TokenInfo](JSONArray: json).compactMap { $0 }
                    tokenInfos.forEach({ (tokenInfo) in
                        map[tokenInfo.id.lowercased()] = tokenInfo
                    })
                }

                var tokenInfos = [TokenInfo]()
                for id in ids {
                    if let tokenInfo = map[id.lowercased()] {
                        tokenInfos.append(tokenInfo)
                    }
                }

                if tokenInfos.count == ids.count {
                    completion(Result.success(tokenInfos))
                } else {
                    completion(Result.failure(ExchangeError.notFound))
                }
            case .failure(let error):
                completion(Result.failure(error))
            }
        })
    }

    fileprivate func sendRequest(api: ExchangeAPI, completion: @escaping (Result<Any>) -> Void) -> Cancellable {
        return request(api) { (result) in
            switch result {
            case .success(let response):
                if let string = try? response.mapString(),
                    let body = ResponseBody(JSONString: string) {
                    if body.code == 0 {
                        completion(Result.success(body.json))
                    } else {
                        completion(Result.failure(ExchangeError.response(body.code, body.message)))
                    }

                } else {
                    completion(Result.failure(ExchangeError.format))
                }
            case .failure(let error):
                completion(Result.failure(error))
            }
        }
    }

    enum ExchangeError: Error {
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
