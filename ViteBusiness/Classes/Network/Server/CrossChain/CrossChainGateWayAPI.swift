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
    case metalInfo(tokenId: String)
    case depositInfo(tokenId: String, viteAddress: String)
    case withdrawInfo(tokenId: String, viteAddress: String)
    case verifyWithdrawAddress(tokenId: String, withdrawAddress: String, label: String?)
    case withdrawFee(tokenId: String, viteAddress: String, amount: String, containsFee: Bool)
    case depositRecords(tokenId: String, viteAddress: String, pageNum: Int, pageSize: Int)
    case withdrawRecords(tokenId: String, viteAddress: String, pageNum: Int, pageSize: Int)
}

extension CrossChainGateWayAPI: TargetType {

    var baseURL: URL {
        var tokenId = ""
        switch self {
        case .metalInfo(let args):
            tokenId = args
        case .depositInfo(let args):
            tokenId = args.tokenId
        case .withdrawInfo(let args):
            tokenId = args.tokenId
        case .verifyWithdrawAddress(let args):
            tokenId = args.tokenId
        case .withdrawFee(let args):
            tokenId = args.tokenId
        case .depositRecords(let args):
            tokenId = args.tokenId
        case .withdrawRecords(let args):
            tokenId = args.tokenId
        }
        let gateway = CrossChainGatewayInfoService.gateway[tokenId] ?? ""
        return URL(string: gateway)!

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
        case .metalInfo(let tokenId):
            return .requestParameters(parameters: ["tokenId": tokenId],
                                      encoding: URLEncoding.queryString)
        case .depositInfo(let tokenId, let viteAddress):
            return .requestParameters(parameters: ["tokenId": tokenId,
                                                   "walletAddress": viteAddress],
                                      encoding: URLEncoding.queryString)
        case .withdrawInfo(let tokenId, let viteAddress):
            return .requestParameters(parameters: ["tokenId": tokenId,
                                                   "walletAddress": viteAddress],
                                      encoding: URLEncoding.queryString)
        case .verifyWithdrawAddress(let tokenId, let withdrawAddress, let label):
            var parameters = ["tokenId": tokenId,
                              "withdrawAddress": withdrawAddress]
            if let label = label {
                parameters["label"] = label
            }
            return .requestParameters(parameters: parameters,
                                      encoding: URLEncoding.queryString)
        case .withdrawFee(let tokenId, let walletAddress, let amount, let containsFee):
            return .requestParameters(parameters: ["tokenId": tokenId,
                                                   "walletAddress": walletAddress,
                                                   "amount": amount,
                                                   "containsFee": containsFee],
                                      encoding: URLEncoding.queryString)
        case .depositRecords(let tokenId, let viteAddress, let pageNum, let pageSize):
            return .requestParameters(parameters: ["tokenId": tokenId,
                                                   "walletAddress": viteAddress,
                                                   "pageNum": pageNum,
                                                   "pageSize": pageSize],
                                      encoding: URLEncoding.queryString)
        case .withdrawRecords(let tokenId, let viteAddress, let pageNum, let pageSize):
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

