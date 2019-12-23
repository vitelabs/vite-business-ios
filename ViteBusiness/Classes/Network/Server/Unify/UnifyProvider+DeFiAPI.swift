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

    static func getAllOnSaleLoans(sortType: DeFiAPI.ProductSortType, offset: Int, limit: Int) -> Promise<[DeFiLoan]> {
        let p: MoyaProvider<DeFiAPI> = UnifyProvider.provider()
        return p.requestPromise(.getDeFiLoans(sortType: sortType, status: .onSale, address: nil, offset: offset, limit: limit))
            .map { [DeFiLoan](JSONString: $0) }
            .compactMap {$0}
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
    }

    static func getMySubscriptions(status: DeFiAPI.ProductStatus, address: ViteAddress, offset: Int, limit: Int) -> Promise<[DeFiSubscription]> {
        let p: MoyaProvider<DeFiAPI> = UnifyProvider.provider()
        return p.requestPromise(.getSubscriptions(status: status, address: address, offset: offset, limit: limit))
            .map { [DeFiSubscription](JSONString: $0) }
            .compactMap {$0}
    }

    static func getMyLoans(status: DeFiAPI.ProductStatus, address: ViteAddress, offset: Int, limit: Int) -> Promise<[DeFiLoan]> {
        let p: MoyaProvider<DeFiAPI> = UnifyProvider.provider()
        return p.requestPromise(.getDeFiLoans(sortType: nil, status: status, address: address, offset: offset, limit: limit))
            .map { [DeFiLoan](JSONString: $0) }
            .compactMap {$0}
    }

    static func getProductDetail(hash: String) -> Promise<DeFiLoan> {
        let p: MoyaProvider<DeFiAPI> = UnifyProvider.provider()
        return p.requestPromise(.getProductDetail(hash: hash))
            .map {
                if let ret = DeFiLoan(JSONString: $0) {
                    return ret
                } else {
                    throw UnifyProvider.BackendError.bodyFormat
                }
        }
    }

    static func getBills(address: ViteAddress,accountType: DeFiAPI.Bill.AccountType,billType: DeFiAPI.Bill.BillType,productHash: String? = nil, offset: Int, limit: Int) -> Promise<[DeFiBill]> {
        let p: MoyaProvider<DeFiAPI> = UnifyProvider.provider()
        return p.requestPromise(.getBills(address: address,accountType: accountType,billType: billType,productHash: productHash, offset: offset, limit: limit))
            .map { [DeFiBill](JSONString: $0) }
            .compactMap {$0}
    }

    static func getUsage(address: ViteAddress,productHash: String? = nil) -> Promise<[DefiUsageInfo]> {
        let p: MoyaProvider<DeFiAPI> = UnifyProvider.provider()
        return p.requestPromise(.getUsage(address: address, productHash: productHash))
            .map { [DefiUsageInfo](JSONString: $0) }
            .compactMap {$0}
    }

    static func getSubscriptionDetail(address: ViteAddress, productHash: String) -> Promise<DeFiSubscription> {
        let p: MoyaProvider<DeFiAPI> = UnifyProvider.provider()
        return p.requestPromise(.getSubscriptionDetail(address: address, productHash: productHash))
            .map {
                    if let ret = DeFiSubscription(JSONString: $0) {
                        return ret
                    } else {
                        throw UnifyProvider.BackendError.bodyFormat
                    }
            }
     }
}
