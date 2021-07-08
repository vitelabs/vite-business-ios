//
//  CrossChainGateWayAPI.swift
//  Action
//
//  Created by haoshenyang on 2019/6/13.
//

import Foundation
import Moya
import ObjectMapper
import BigInt
import ViteWallet

enum CrossChainGateWayAPI {
    case metalInfo(baseURL: URL, tokenId: String)
    case depositInfo(baseURL: URL, tokenId: String, viteAddress: String)
    case withdrawInfo(baseURL: URL, tokenId: String, viteAddress: String)
    case verifyWithdrawAddress(baseURL: URL, tokenId: String, withdrawAddress: String, label: String?)
    case withdrawFee(baseURL: URL, tokenId: String, viteAddress: String, amount: String, containsFee: Bool)
    case depositRecords(baseURL: URL, tokenId: String, viteAddress: String, pageNum: Int, pageSize: Int)
    case withdrawRecords(baseURL: URL, tokenId: String, viteAddress: String, pageNum: Int, pageSize: Int)
}

extension CrossChainGateWayAPI: TargetType {

    var baseURL: URL {
        switch self {
        case .metalInfo(let args):
            return args.baseURL
        case .depositInfo(let args):
            return args.baseURL
        case .withdrawInfo(let args):
            return args.baseURL
        case .verifyWithdrawAddress(let args):
            return args.baseURL
        case .withdrawFee(let args):
            return args.baseURL
        case .depositRecords(let args):
            return args.baseURL
        case .withdrawRecords(let args):
            return args.baseURL
        }
    }

    var path: String {
        switch self {
        case .metalInfo:
            return "/meta-info"
        case .depositInfo:
            return "/deposit-info"
        case .withdrawInfo:
            return "/withdraw-info"
        case .verifyWithdrawAddress:
            return "/withdraw-address/verification"
        case .withdrawFee:
            return "/withdraw-fee"
        case .depositRecords:
            return "/deposit-records"
        case .withdrawRecords:
            return "/withdraw-records"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        switch self {
        case .metalInfo(let _, let tokenId):
            return .requestParameters(parameters: ["tokenId": tokenId],
                                      encoding: URLEncoding.queryString)
        case .depositInfo(let _, let tokenId, let viteAddress):
            return .requestParameters(parameters: ["tokenId": tokenId,
                                                   "walletAddress": viteAddress],
                                      encoding: URLEncoding.queryString)
        case .withdrawInfo(let _, let tokenId, let viteAddress):
            return .requestParameters(parameters: ["tokenId": tokenId,
                                                   "walletAddress": viteAddress],
                                      encoding: URLEncoding.queryString)
        case .verifyWithdrawAddress(let _, let tokenId, let withdrawAddress, let label):
            var parameters = ["tokenId": tokenId,
                              "withdrawAddress": withdrawAddress]
            if let label = label {
                parameters["label"] = label
            }
            return .requestParameters(parameters: parameters,
                                      encoding: URLEncoding.queryString)
        case .withdrawFee(let _, let tokenId, let walletAddress, let amount, let containsFee):
            return .requestParameters(parameters: ["tokenId": tokenId,
                                                   "walletAddress": walletAddress,
                                                   "amount": amount,
                                                   "containsFee": containsFee],
                                      encoding: URLEncoding.queryString)
        case .depositRecords(let _, let tokenId, let viteAddress, let pageNum, let pageSize):
            return .requestParameters(parameters: ["tokenId": tokenId,
                                                   "walletAddress": viteAddress,
                                                   "pageNum": pageNum,
                                                   "pageSize": pageSize],
                                      encoding: URLEncoding.queryString)
        case .withdrawRecords(let _, let tokenId, let viteAddress, let pageNum, let pageSize):
            return .requestParameters(parameters: ["tokenId": tokenId,
                                                   "walletAddress": viteAddress,
                                                   "pageNum": pageNum,
                                                   "pageSize": pageSize],
                                      encoding: URLEncoding.queryString)

        }
    }

    var sampleData: Data {
        return Data()
    }

    var headers: [String: String]? {
        var language = "en"
        if LocalizationService.sharedInstance.currentLanguage == .chinese {
            language = "zh-cn"
        }
        return ["lang": language,
                "version":"v1.0"]
    }
}

