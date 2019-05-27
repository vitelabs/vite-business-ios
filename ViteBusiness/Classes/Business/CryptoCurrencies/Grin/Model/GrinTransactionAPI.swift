//
//  GrinTransactionAPI.swift
//  Action
//
//  Created by haoshenyang on 2019/3/19.
//

import Foundation
import Moya
import ViteBusiness
import CryptoSwift
import ViteWallet

public enum GrinTransaction {
    case reportViteAddress(address: ViteAddress, signature: String)
    case uploadSlate(from: String, to: String, fname: String, data: String, id: String, type: Int, s: String )
    case getSlate(to: String, s: String, fname:String)
    case reportFinalization(from: String, s: String, id: String)
    case gatewayTransactionList(addressesAndSignature:[[String: String]])
    case gatewayTransactionById(slateID: String)
    case gateWayReSend(address:String, id: String,signature: String)
}

extension GrinTransaction: TargetType {

    public var baseURL: URL {
        return URL(string:"http://129.28.98.62:8080")!
        return URL(string: ViteConst.instance.grin.x)!
    }

    public var path: String {
        switch self {
        case .reportViteAddress:
            return "/api/grin/initAccount"
        case .uploadSlate:
            return "/api/grin/uploadFile"
        case .getSlate:
            return "/api/grin/getUploadFile"
        case .reportFinalization:
            return "/api/grin/finishTrx"
        case .gatewayTransactionList:
            return "/api/gringateway/getTxList"
        case .gatewayTransactionById:
            return "/api/gringateway/getTxById"
        case .gateWayReSend:
            return "/api/gringateway/resend"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .getSlate, .reportViteAddress,.gatewayTransactionById:
            return .get
        case .uploadSlate, .reportFinalization, .gateWayReSend, .gatewayTransactionList:
            return .post
        }
    }

    public var task: Task {
        switch self {
        case let .getSlate(toAddress, signature, fileName):
            return
                .requestCompositeData(bodyData: Data(),
                                      urlParameters: [
                                        "toAddress": toAddress,
                                        "fileName": fileName,
                                        "signature": signature,
                ])
        case let .uploadSlate(fromAddress, toAddress, fileName, data, slateId, type, signature):
            var parameters: [String : Any] = [
                "fromAddress": fromAddress,
                "toAddress": toAddress,
                "fileName": fileName,
                "data": data,
                "slateId": slateId,
                "type": type,
                "signature": signature
            ]
            return .requestParameters(parameters: parameters, encoding: Moya.JSONEncoding() as! ParameterEncoding )
        case let .reportViteAddress(address, signature):
            var parameters: [String : Any] = [
                "address": address,
                "signature": signature,
            ]
             return .requestCompositeData(bodyData: Data(),
                                      urlParameters: parameters)
        case let .reportFinalization(fromAddress,signature,slateId):
            var parameters: [String : Any] = [
                "fromAddress": fromAddress,
                "slateId": slateId,
                "signature": signature,
                ]
            return .requestParameters(parameters: parameters, encoding: Moya.JSONEncoding() as! ParameterEncoding)
        case let .gatewayTransactionList(addressesAndSignature):
            var parameters: [String : Any] = [
                "addressList": addressesAndSignature,
            ]
            return .requestParameters(parameters: parameters, encoding: Moya.JSONEncoding() as! ParameterEncoding)
        case let .gatewayTransactionById(slateID):
            var parameters: [String : Any] = [
                "id": slateID,
            ]
            return .requestCompositeData(bodyData: Data(),
                                         urlParameters: parameters)
        case let .gateWayReSend(address, id, signature):
            var parameters: [String : Any] = [
                "address": address,
                "id": id,
                "signature": signature
            ]
            return .requestCompositeData(bodyData: Data(),
                                         urlParameters: parameters)
        }
    }

    public var headers: [String : String]? {
        return [
            "versionCode": String(Bundle.main.buildNumberInt),
            "platform": "ios",
            "language": LocalizationService.sharedInstance.currentLanguage.rawValue
        ]
    }

    public var sampleData: Data {
        return Data()
    }

}

