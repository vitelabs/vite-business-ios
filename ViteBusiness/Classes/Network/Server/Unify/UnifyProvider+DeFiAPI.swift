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
import Alamofire


extension UnifyProvider {
    struct defi {}
}

extension UnifyProvider.defi {
    enum TestError: Error {
        case text(String)
    }

    static func getAllOnSaleLoans(sortType: DeFiAPI.ProductSortType, offset: Int, limit: Int) -> Promise<[DeFiLoan]> {
/*
        let jsonString = "{\"productHash\":\"ab24ef68b84e642c0ddca06beec81c9acb1977bbd7da27a87a\",\"subscriptionEndHeight\":1554722699,\"subscriptionEndTimestamp\":1575282558,\"yearRate\":\"0.02\",\"loanAmount\":\"1000000000000000000000\",\"singleCopyAmount\":\"10000000000000000000\",\"loanDuration\":3,\"subscribedAmount\":\"1000000000000000000000\",\"loanCompleteness\":\"0.10\",\"productStatus\":1,\"refundStatus\":1}"

        return after(seconds: 0.1).then({ (Void) -> Promise<[DeFiLoan]> in
            if sortType == .PUB_TIME_DESC {
                if offset != 0 {
                    return Promise.value([
                        DeFiLoan(JSONString: jsonString)!
                    ])
                } else {
                    return Promise.value([
                        DeFiLoan(JSONString: jsonString)!,
                        DeFiLoan(JSONString: jsonString)!,
                        DeFiLoan(JSONString: jsonString)!,
                        DeFiLoan(JSONString: jsonString)!
                    ])
                }
            } else if sortType == .SUB_TIME_REMAINING_ASC {
                return Promise.value([])
            } else if sortType == .YEAR_RATE_DESC {
                if offset != 0 {
                    return Promise(error: TestError.text("load error"))
                } else {
                    return Promise.value([
                        DeFiLoan(JSONString: jsonString)!,
                        DeFiLoan(JSONString: jsonString)!,
                        DeFiLoan(JSONString: jsonString)!,
                        DeFiLoan(JSONString: jsonString)!
                    ])
                }
            } else {
                return Promise(error: TestError.text("refrest error"))
            }
        })
*/
        return Promise { seal in
            let p: MoyaProvider<DeFiAPI> = UnifyProvider.provider()
            p.request(.getDeFiLoans(sortType: sortType, status: .onSale, address: nil, offset: offset, limit: limit)) { (result) in
                switch result {
                case .success(let response):
                    if let json = try? response.mapJSON(),
                       let arr = JSON(json)["data"].arrayObject,
                        let models = Mapper<DeFiLoan>().mapArray(JSONObject: arr){
                        seal.fulfill(models)
                    } else {
                        seal.reject(NSError())
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }

    static func getMySubscriptions(status: DeFiAPI.ProductStatus, address: ViteAddress, offset: Int, limit: Int) -> Promise<[DeFiSubscription]> {
//        return after(seconds: 0.1).then({ (Void) -> Promise<[DeFiSubscription]> in
//
//            return Promise.value([
//                DeFiSubscription(JSONString: "{}")!,
//                DeFiSubscription(JSONString: "{}")!,
//                DeFiSubscription(JSONString: "{}")!,
//                DeFiSubscription(JSONString: "{}")!
//            ])
//        })
        return Promise { seal in
            let p: MoyaProvider<DeFiAPI> = UnifyProvider.provider()
            p.request(.getSubscriptions(status: status, address: address, offset: offset, limit: limit)) { (result) in
                switch result {
                case .success(let response):
                    if let json = try? response.mapJSON(),
                        let data = JSON(json)["data"].arrayObject,
                        let detail = Mapper<DeFiSubscription>().mapArray(JSONObject: data){
                        seal.fulfill(detail)
                    } else {
                        seal.reject(NSError())
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }

    static func getMyLoans(status: DeFiAPI.ProductStatus, address: ViteAddress, offset: Int, limit: Int) -> Promise<[DeFiLoan]> {
//        return after(seconds: 0.1).then({ (Void) -> Promise<[DeFiLoan]> in
//            let jsonString = "{\"productHash\":\"ab24ef68b84e642c0ddca06beec81c9acb1977bbd7da27a87a\",\"subscriptionEndHeight\":1554722699,\"subscriptionEndTimestamp\":1575282558,\"yearRate\":\"0.02\",\"loanAmount\":\"1000000000000000000000\",\"singleCopyAmount\":\"10000000000000000000\",\"loanDuration\":3,\"subscribedAmount\":\"1000000000000000000000\",\"loanCompleteness\":\"0.10\",\"productStatus\":1,\"refundStatus\":1}"
//            return Promise.value([
//                DeFiLoan(JSONString: jsonString)!,
//                DeFiLoan(JSONString: jsonString)!,
//                DeFiLoan(JSONString: jsonString)!,
//                DeFiLoan(JSONString: jsonString)!
//            ])
//        })
        return Promise { seal in
            let p: MoyaProvider<DeFiAPI> = UnifyProvider.provider()
            p.request(.getDeFiLoans(sortType: nil, status: status, address: address, offset: offset, limit: limit)) { (result) in
                switch result {
                case .success(let response):
                    if let json = try? response.mapJSON(),
                        let data = JSON(json)["data"].arrayObject,
                        let detail = Mapper<DeFiLoan>().mapArray(JSONObject: data){
                        seal.fulfill(detail)
                    } else {
                        seal.reject(NSError())
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }

    static func getProductDetail(hash: String) -> Promise<DeFiLoan> {
        return Promise { seal in
            let p: MoyaProvider<DeFiAPI> = UnifyProvider.provider()
            p.request(.getProductDetail(hash: hash)) { (result) in
                switch result {
                case .success(let response):
                    if let json = try? response.mapJSON(),
                        let data = JSON(json)["data"].dictionaryObject,
                        let detail = DeFiLoan.init(JSON: data){
                        seal.fulfill(detail)
                    } else {
                        seal.reject(NSError())
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }

    static func getBills(address: ViteAddress,accountType: DeFiAPI.Bill.AccountType,billType: DeFiAPI.Bill.BillType,productHash: String? = nil, offset: Int, limit: Int) -> Promise<[DeFiBill]> {
        return Promise { seal in
            let p: MoyaProvider<DeFiAPI> = UnifyProvider.provider()
            p.request(.getBills(address: address,accountType: accountType,billType: billType,productHash: productHash, offset: offset, limit: limit)) { (result) in
                switch result {
                case .success(let response):
                    if let json = try? response.mapJSON(),
                        let data = JSON(json)["data"].arrayObject,
                        let detail = Mapper<DeFiBill>().mapArray(JSONObject: data){
                        seal.fulfill(detail)
                    } else {
                        seal.reject(NSError())
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }

    static func getUsage(address: ViteAddress,productHash: String? = nil) -> Promise<[DefiUsageInfo]> {
        return Promise { seal in
            let p: MoyaProvider<DeFiAPI> = UnifyProvider.provider()
            p.request(.getUsage(address: address, productHash: productHash)) { (result) in
                switch result {
                case .success(let response):
                    if let json = try? response.mapJSON(),
                        let data = JSON(json)["data"].arrayObject,
                        let detail = Mapper<DefiUsageInfo>().mapArray(JSONObject: data){
                        seal.fulfill(detail)
                    } else {
                        seal.reject(NSError())
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }

    static func getSubscriptionDetail(address: ViteAddress, productHash: String) -> Promise<DeFiSubscription> {
         return Promise { seal in
             let p: MoyaProvider<DeFiAPI> = UnifyProvider.provider()
             p.request(.getSubscriptionDetail(address: address, productHash: productHash)) { (result) in
                 switch result {
                 case .success(let response):
                     if let json = try? response.mapJSON(),
                        let data = JSON(json)["data"].dictionaryObject,
                        let detail = DeFiSubscription.init(JSON: data){
                         seal.fulfill(detail)
                     } else {
                         seal.reject(NSError())
                     }
                 case .failure(let error):
                     seal.reject(error)
                 }
             }
         }
     }
}
