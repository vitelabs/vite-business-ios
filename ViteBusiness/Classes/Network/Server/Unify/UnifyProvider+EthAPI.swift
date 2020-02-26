//
//  UnifyProvider+EthAPI.swift
//  ViteBusiness
//
//  Created by Stone on 2020/2/26.
//

import RxSwift
import RxCocoa
import Alamofire
import Moya
import SwiftyJSON
import ObjectMapper
import enum Alamofire.Result
import ViteWallet
import APIKit
import JSONRPCKit
import PromiseKit
import Alamofire

extension UnifyProvider {
    struct eth {}
}

extension UnifyProvider.eth {

    private static var responseToData: UnifyProvider.ResponseToData {
        return { json throws -> String in
            guard let c = json["status"].string, let code = Int(c) else {
                throw UnifyProvider.BackendError.format
            }
            guard code == 1 else {
                throw UnifyProvider.BackendError.response(code, json["message"].string ?? "")
            }
            guard let string = json["result"].rawString() else {
                throw UnifyProvider.BackendError.format
            }
            return string
        }
    }

    static func getEtherTransactions(address: String, page: Int, limit: Int) -> Promise<[ETHTransaction]> {
        let p: MoyaProvider<EthAPI> = UnifyProvider.provider()
        return p.requestPromise(.etherTransactions(address: address, page: page, limit: limit), responseToData: responseToData)
            .map { Mapper<ETHTransaction>(context:
                ETHTransaction.Context(accountAddress: address, tokenInfo: TokenInfo.BuildIn.eth.value))
                .mapArray(JSONString: $0) }
            .compactMap { $0 }
    }

    static func getErc20Transactions(address: String, tokenInfo: TokenInfo, page: Int, limit: Int) -> Promise<[ETHTransaction]> {
        let p: MoyaProvider<EthAPI> = UnifyProvider.provider()
        return p.requestPromise(.erc20Transactions(address: address, contractAddress: tokenInfo.id, page: page, limit: limit), responseToData: responseToData)
            .map { Mapper<ETHTransaction>(context:
                ETHTransaction.Context(accountAddress: address, tokenInfo: tokenInfo))
                .mapArray(JSONString: $0) }
            .compactMap { $0 }
    }
}
