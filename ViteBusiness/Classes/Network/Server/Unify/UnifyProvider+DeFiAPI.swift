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


extension UnifyProvider {
    struct defi {}
}

extension UnifyProvider.defi {
    enum TestError: Error {
        case text(String)
    }
    static func getAllOnSaleProducts(sortType: DeFiAPI.ProductSortType, offset: Int, limit: Int) -> Promise<[DeFiProduct]> {

        let jsonString = "{\"productHash\":\"ab24ef68b84e642c0ddca06beec81c9acb1977bbd7da27a87a\",\"subscriptionEndHeight\":1554722699,\"subscriptionEndTimestamp\":1575282558,\"yearRate\":\"0.02\",\"loanAmount\":\"1000000000000000000000\",\"singleCopyAmount\":\"10000000000000000000\",\"loanDuration\":3,\"subscribedAmount\":\"1000000000000000000000\",\"loanCompleteness\":\"0.10\",\"productStatus\":1,\"refundStatus\":1}"

        return after(seconds: 1).then({ (Void) -> Promise<[DeFiProduct]> in
            if sortType == .DEFAULT {
                if offset != 0 {
                    return Promise.value([
                        DeFiProduct(JSONString: jsonString)!
                    ])
                } else {
                    return Promise.value([
                        DeFiProduct(JSONString: jsonString)!,
                        DeFiProduct(JSONString: jsonString)!,
                        DeFiProduct(JSONString: jsonString)!,
                        DeFiProduct(JSONString: jsonString)!
                    ])
                }
            } else if sortType == .PUB_TIME_DESC {
                return Promise.value([])
            } else if sortType == .SUB_TIME_REMAINING_ASC {
                if offset != 0 {
                    return Promise(error: TestError.text("load error"))
                } else {
                    return Promise.value([
                        DeFiProduct(JSONString: jsonString)!,
                        DeFiProduct(JSONString: jsonString)!,
                        DeFiProduct(JSONString: jsonString)!,
                        DeFiProduct(JSONString: jsonString)!
                    ])
                }
            } else {
                return Promise(error: TestError.text("refrest error"))
            }
        })

//        return Promise { seal in
//            let p: MoyaProvider<DeFiAPI> = UnifyProvider.provider()
//            p.request(.getDeFiProducts(sortType: sortType, status: .onSale, address: nil, offset: offset, limit: limit)) { (result) in
//                switch result {
//                case .success(let response):
//                    print(response)
//                    seal.fulfill([])
//                case .failure(let error):
//                    seal.reject(error)
//                }
//            }
//        }
    }
}
