
//
//  Exchangeprivader.swift
//  Action
//
//  Created by haoshenyang on 2019/7/25.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import Moya
import SwiftyJSON
import ObjectMapper
import enum Alamofire.Result

class Exchangeprovider: MoyaProvider<ExchangeApi> {

}

extension Exchangeprovider {

    @discardableResult
    func getRate(for address: String, completion: @escaping (Result<RateInfo>) -> Void) -> Cancellable {
        return sendRequest(api: .getRate(address: address), completion: { (ret) in
            switch ret {
            case .success(let json):
                if let rate = RateInfo.init(JSON: json as! [String : Any]) {
                    completion(Result.success(rate))
                } else {
                    completion(Result.failure(ExchangeError.format))
                }
                
            case .failure(let error):
                completion(Result.failure(error))
            }
        })
    }

    @discardableResult
    func getHistory(address: String, market: String, pageSize: Int, pageNumber: Int, completion: @escaping (Result<[HistoryInfo]>) -> Void) -> Cancellable {
        return sendRequest(api: .getHistory(address: address, market: market, pageSize: pageSize, pageNumber: pageNumber), completion: { (ret) in
            switch ret {
            case .success(let json):
                if let r =  Mapper<HistoryInfo>().mapArray(JSONObject: json) {
                    completion(Result.success(r))
                } else {
                    completion(Result.failure(ExchangeError.format))
                }
            case .failure(let error):
                completion(Result.failure(error))
            }
        })
    }

    @discardableResult
    func exchange(address: String, market: String, hash: String, completion: @escaping (Result<ExchangeResult>) -> Void) -> Cancellable {
        return sendRequest(api: .report(address: address, market: market, hash: hash), completion: { (ret) in
            switch ret {
            case .success(let json):
                if let r = ExchangeResult.init(JSON: json as! [String : Any]) {
                    completion(Result.success(r))
                } else {
                    completion(Result.failure(ExchangeError.format))
                }
            case .failure(let error):
                completion(Result.failure(error))
            }
        })
    }


    fileprivate func sendRequest(api: ExchangeApi, completion: @escaping (Result<Any>) -> Void) -> Cancellable {
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
        var json: Any = ""

        init?(map: Map) { }

        mutating func mapping(map: Map) {
            code <- map["code"]
            message <- map["msg"]
            json <- map["data"]
        }
    }


    struct RateInfo: Mappable {

        var rightRate = 0.0
        var storeAddress: String = ""
        var quota = QuotaInfo()

        init() {

        }

        init?(map: Map) {

        }

        mutating func mapping(map: Map) {
            rightRate <- map["rightRate"]
            storeAddress <- map["storeAddress"]
            quota <- map["quota"]
        }
    }

    struct QuotaInfo: Mappable {

        var id = 0
        var unitQuotaMin = 0.0
        var unitQuotaMax = 0.0
        var quotaRest = 0.0
        var version = 0
        var ctime = ""

        init() {

        }

        init?(map: Map) {

        }

        mutating func mapping(map: Map) {
            id <- map["id"]
            unitQuotaMin <- map["unitQuotaMin"]
            unitQuotaMax <- map["unitQuotaMax"]
            quotaRest <- map["quotaRest"]
            version <- map["version"]
            ctime <- map["ctime"]
        }
    }


    struct HistoryInfo: Mappable {

        var id = 0
        var address = ""
        var market = ""
        var xAmount = 0.0
        var viteAmount = 0.0
        var ratePrice = 0.0
        var receiveHash = ""
        var sendHash = ""
        var ctime = 0.0

        init?(map: Map) {
            self.mapping(map: map)
        }

        mutating func mapping(map: Map) {
            id <- map["id"]
            address <- map["address"]
            market <- map["market"]
            xAmount <- map["xAmount"]
            viteAmount <- map["viteAmount"]
            ratePrice <- map["ratePrice"]
            receiveHash <- map["receiveHash"]
            sendHash <- map["sendHash"]
            ctime <- map["ctime"]
        }

    }


    struct ExchangeResult: Mappable {

        var rightRate = ""
        var sendHash = ""
        var viteAmount = ""

        init?(map: Map) {
            self.mapping(map: map)
        }

        mutating func mapping(map: Map) {
            rightRate <- map["rightRate"]
            sendHash <- map["sendHash"]
            viteAmount <- map["viteAmount"]
        }

    }

}
