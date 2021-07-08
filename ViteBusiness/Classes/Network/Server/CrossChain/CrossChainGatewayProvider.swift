//
//  CrossChain.swift
//  Action
//
//  Created by haoshenyang on 2019/6/13.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import Moya
import SwiftyJSON
import ObjectMapper
import PromiseKit
import enum Alamofire.Result

class CrossChainGatewayProvider: MoyaProvider<CrossChainGateWayAPI> {
    
    let baseURL: URL
    
    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    func getMetaInfo(for tokenId: String) -> Promise<TokenMetaInfo> {
        return Promise { seal in
            sendRequest(api: .metalInfo(baseURL: baseURL, tokenId: tokenId), completion: { (ret) in
                switch ret {
                case .success(let json):
                    if let info = TokenMetaInfo.init(JSON: json) {
                        seal.fulfill(info)
                    } else {
                        seal.reject(CrossChainGatewayError.notFound)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            })
        }
    }

    func depositInfo(for tokenId: String, viteAddress: String) -> Promise<DepositInfo> {
        return Promise { seal in
            sendRequest(api: .depositInfo(baseURL: baseURL, tokenId: tokenId, viteAddress: viteAddress), completion: { (ret) in
                switch ret {
                case .success(let json):
                    if let info = DepositInfo.init(JSON: json) {
                        seal.fulfill(info)
                    } else {
                        seal.reject(CrossChainGatewayError.notFound)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            })
        }
    }

    func withdrawInfo(for tokenId: String, viteAddress: String) -> Promise<WithdrawInfo> {
        return Promise { seal in
            sendRequest(api: .withdrawInfo(baseURL: baseURL, tokenId: tokenId, viteAddress: viteAddress), completion: { (ret) in
                switch ret {
                case .success(let json):
                    if let info = WithdrawInfo.init(JSON: json) {
                        seal.fulfill(info)
                    } else {
                        seal.reject(CrossChainGatewayError.notFound)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            })
        }
    }

    func verifyWithdrawAddress(for tokenId: String, withdrawAddress: String, label: String?) -> Promise<Bool> {
        return Promise { seal in
            sendRequest(api: .verifyWithdrawAddress(baseURL: baseURL, tokenId: tokenId, withdrawAddress: withdrawAddress, label: label), completion: { (ret) in
                switch ret {
                case .success(let json):
                    if let isValidAddress = json["isValidAddress"] as? Bool {
                        seal.fulfill(isValidAddress)
                    } else {
                        seal.reject(CrossChainGatewayError.notFound)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            })
        }
    }

    func withdrawFee(for tokenId: String, viteAddress: String,amount: String,containsFee: Bool) -> Promise<String> {
        return Promise { seal in
            sendRequest(api: .withdrawFee(baseURL: baseURL, tokenId: tokenId, viteAddress: viteAddress, amount: amount, containsFee: containsFee), completion: { (ret) in
                switch ret {
                case .success(let json):
                    if let fee = json["fee"] as? String {
                        seal.fulfill(fee)
                    } else {
                        seal.reject(CrossChainGatewayError.notFound)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            })
        }
    }

    func depositRecords(for tokenId: String, viteAddress: String,pageNum: Int,pageSize: Int) -> Promise<DepositRecordInfos> {
        return Promise { seal in
            sendRequest(api: .depositRecords(baseURL: baseURL, tokenId: tokenId, viteAddress: viteAddress, pageNum: pageNum, pageSize: pageSize), completion: { (ret) in
                switch ret {
                case .success(let json):
                    if var depositRecordInfos = DepositRecordInfos.init(JSON: json) {
                        depositRecordInfos.depositRecords = depositRecordInfos.depositRecords.map({ (r) -> DepositRecord in
                            var record = r
                            record.inTxExplorer = depositRecordInfos.inTxExplorerFormat.replacingOccurrences(of: "{$tx}", with: record.inTxHash)
                            record.outTxExplorer = depositRecordInfos.outTxExplorerFormat.replacingOccurrences(of: "{$tx}", with: record.outTxHash ?? "")
                            return record
                        })
                        seal.fulfill(depositRecordInfos)
                    } else {
                        seal.reject(CrossChainGatewayError.notFound)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            })
        }
    }

    func withdrawRecords(for tokenId: String, viteAddress: String,pageNum: Int,pageSize: Int) -> Promise<WithdrawRecordInfos> {
        return Promise { seal in
            sendRequest(api: .withdrawRecords(baseURL: baseURL, tokenId: tokenId, viteAddress: viteAddress, pageNum: pageNum, pageSize: pageSize), completion: { (ret) in
                switch ret {
                case .success(let json):
                    if var withdrawRecordInfos = WithdrawRecordInfos.init(JSON: json) {
                       withdrawRecordInfos.withdrawRecords = withdrawRecordInfos.withdrawRecords.map({ (r) -> WithdrawRecord in
                            var record = r
                            record.inTxExplorer = withdrawRecordInfos.inTxExplorerFormat.replacingOccurrences(of: "{$tx}", with: record.inTxHash)
                            record.outTxExplorer = withdrawRecordInfos.outTxExplorerFormat.replacingOccurrences(of: "{$tx}", with: record.outTxHash ?? "")
                            return record
                        })
                        seal.fulfill(withdrawRecordInfos)
                    } else {
                        seal.reject(CrossChainGatewayError.notFound)
                    }
                case .failure(let error):
                    seal.reject(error)
                }
            })
        }
    }

    fileprivate func sendRequest(api: CrossChainGateWayAPI, completion: @escaping (Result<[String: Any]>) -> Void) -> Cancellable {
        return request(api) { (result) in
            switch result {
            case .success(let response):
                if let string = try? response.mapString(),
                    let body = ResponseBody(JSONString: string) {
                    if body.code == 0 {
                        completion(Result.success(body.json))
                    } else {
                        completion(Result.failure(CrossChainGatewayError.response(body.code, body.message)))
                    }
                } else {
                    completion(Result.failure(CrossChainGatewayError.format))
                }
            case .failure(let error):
                completion(Result.failure(error))
            }
        }
    }

}

extension CrossChainGatewayProvider {

    struct ResponseBody: Mappable {
        var code: Int = -1
        var subCode: Int = -1

        var message: String = ""
        var json: [String: Any] = [:]

        init?(map: Map) { }

        mutating func mapping(map: Map) {
            code <- map["code"]
            message <- map["msg"]
            json <- map["data"]
        }
    }

    enum CrossChainGatewayError: Error, DisplayableError {
        case format
        case response(Int, String)
        case notFound
        
        var errorMessage: String {
            switch self {
            case .format:
                return "format error"
            case .response(let code, let string):
                return string
            case .notFound:
                return "not found"
            }
        }
    }
}

struct TokenMetaInfo: Mappable {

    enum `Type`: Int {
        case singelAddress = 0
        case distinguishAddressByNote = 1
        case unknow = -1
    }

    enum State: String {
        case open = "OPEN"
        case maintain = "MAINTAIN"
        case closed = "CLOSED"
    }

    var type: `Type` = .unknow
    var depositState: State = .closed
    var withdrawState: State = .closed

    init?(map: Map) { }

    mutating func mapping(map: Map) {
        type <- map["type"]
        depositState <- map["depositState"]
        withdrawState <- map["withdrawState"]
    }
}

struct DepositInfo: Mappable {
    var depositAddress: String = ""
    var labelName: String?
    var label: String?
    var minimumDepositAmount: String = ""
    var confirmationCount: Int = 0
    var noticeMsg: String?

    init?(map: Map) { }

    mutating func mapping(map: Map) {
        depositAddress <- map["depositAddress"]
        labelName <- map["labelName"]
        label <- map["label"]
        minimumDepositAmount <- map["minimumDepositAmount"]
        confirmationCount <- map["confirmationCount"]
        noticeMsg <- map["noticeMsg"]
    }
}

struct WithdrawInfo: Mappable {
    var gatewayAddress: String = ""
    var noticeMsg: String?
    var labelName: String?
    var minimumWithdrawAmount: String = ""
    var maximumWithdrawAmount: String = ""

    init?(map: Map) { }

    mutating func mapping(map: Map) {
        gatewayAddress <- map["gatewayAddress"]
        minimumWithdrawAmount <- map["minimumWithdrawAmount"]
        maximumWithdrawAmount <- map["maximumWithdrawAmount"]
        noticeMsg <- map["noticeMsg"]
        labelName <- map["labelName"]
    }
}

enum CrossChainState: String {
    case OPPOSITE_PROCESSING = "OPPOSITE_PROCESSING"
    case OPPOSITE_CONFIRMED = "OPPOSITE_CONFIRMED"
    case BELOW_MINIMUM = "BELOW_MINIMUM"
    case TOT_EXCEED_THE_LIMIT = "TOT_EXCEED_THE_LIMIT"
    case WRONG_WITHDRAW_ADDRESS = "WRONG_WITHDRAW_ADDRESS"
    case TOT_PROCESSING = "TOT_PROCESSING"
    case TOT_CONFIRMED = "TOT_CONFIRMED"

    case UNKNOW = "unknow"
}

struct DepositRecordInfos: Mappable {
    var totalCount: Int = 0
    var depositRecords: [DepositRecord] = []
    var inTxExplorerFormat = ""
    var outTxExplorerFormat = ""

    init?(map: Map) { }

    mutating func mapping(map: Map) {
        totalCount <- map["totalCount"]
        depositRecords <- map["depositRecords"]
        inTxExplorerFormat <- map["inTxExplorerFormat"]
        outTxExplorerFormat <- map["outTxExplorerFormat"]
    }
}

struct DepositRecord: Mappable, Record {
    var inTxHash: String = ""
    var outTxHash: String?
    var amount: String = ""
    var fee: String = ""
    var state: CrossChainState = .UNKNOW
    var dateTime: String = ""

    var inTxExplorer = ""
    var outTxExplorer = ""

    var inTxConfirmedCount: Int?
    var inTxConfirmationCount: Int?

    init?(map: Map) { }

    mutating func mapping(map: Map) {
        inTxHash <- map["inTxHash"]
        outTxHash <- map["outTxHash"]
        amount <- map["amount"]
        fee <- map["fee"]
        state <- map["state"]
        dateTime <- map["dateTime"]
        inTxConfirmedCount <- map["inTxConfirmedCount"]
        inTxConfirmationCount <- map["inTxConfirmationCount"]

    }
}

struct WithdrawRecordInfos: Mappable {
    var totalCount: Int = 0
    var withdrawRecords: [WithdrawRecord] = []
    var inTxExplorerFormat = ""
    var outTxExplorerFormat = ""

    init?(map: Map) { }

    mutating func mapping(map: Map) {
        totalCount <- map["totalCount"]
        withdrawRecords <- map["withdrawRecords"]
        inTxExplorerFormat <- map["inTxExplorerFormat"]
        outTxExplorerFormat <- map["outTxExplorerFormat"]
    }
}

struct WithdrawRecord: Mappable, Record {

    var inTxHash: String = ""
    var outTxHash: String?
    var amount: String = ""
    var fee: String = ""
    var state: CrossChainState = .UNKNOW
    var dateTime: String = ""
    var inTxConfirmedCount: Int?
    var inTxConfirmationCount: Int?

    var inTxExplorer = ""
    var outTxExplorer = ""

    init?(map: Map) { }

    mutating func mapping(map: Map) {
        inTxHash <- map["inTxHash"]
        outTxHash <- map["outTxHash"]
        amount <- map["amount"]
        fee <- map["fee"]
        state <- map["state"]
        dateTime <- map["dateTime"]
        inTxConfirmedCount <- map["inTxConfirmedCount"]
        inTxConfirmationCount <- map["inTxConfirmationCount"]
    }
}


protocol Record {

    var inTxHash: String { get }
    var outTxHash: String? { get }
    var inTxConfirmedCount: Int? { get }
    var inTxConfirmationCount: Int? { get }
    var amount: String { get }
    var fee: String { get }
    var state: CrossChainState { get }
    var dateTime: String { get }
    var inTxExplorer: String { get }
    var outTxExplorer: String { get }
}

