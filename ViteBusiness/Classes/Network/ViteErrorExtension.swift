//
//  ViteError.swift
//  Vite
//
//  Created by haoshenyang on 2018/10/18.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import ViteWallet
import APIKit
import JSONRPCKit

extension ViteError {

    fileprivate static let code2MessageMap: [ViteErrorCode: String] = [
        ViteErrorCode.rpcNotEnoughBalance: R.string.localizable.viteErrorRpcErrorCodeNotEnoughBalance(),
        ViteErrorCode.rpcNotEnoughQuota: R.string.localizable.viteErrorRpcErrorCodeNotEnoughQuota(),
        ViteErrorCode.rpcIdConflict: R.string.localizable.viteErrorRpcErrorCodeIdConflict(),
        ViteErrorCode.rpcContractDataIllegal: R.string.localizable.viteErrorRpcErrorCodeContractDataIllegal(),
        ViteErrorCode.rpcRefrenceSameSnapshootBlock: R.string.localizable.viteErrorRpcErrorCodeRefrenceSameSnapshootBlock(),
        ViteErrorCode.rpcContractMethodNotExist: R.string.localizable.viteErrorRpcErrorCodeContractMethodNotExist(),
        ViteErrorCode.rpcNoTransactionBefore: R.string.localizable.viteErrorRpcErrorCodeNoTransactionBefore(),
        ViteErrorCode.rpcHashVerifyFailure: R.string.localizable.viteErrorRpcErrorCodeVerifyFailure(String(ViteErrorCode.rpcHashVerifyFailure.id)),
        ViteErrorCode.rpcSignatureVerifyFailure: R.string.localizable.viteErrorRpcErrorCodeVerifyFailure(String(ViteErrorCode.rpcSignatureVerifyFailure.id)),
        ViteErrorCode.rpcPowNonceVerifyFailure: R.string.localizable.viteErrorRpcErrorCodeVerifyFailure(String(ViteErrorCode.rpcPowNonceVerifyFailure.id)),
        ViteErrorCode.rpcRefrenceSnapshootBlockIllegal: R.string.localizable.viteErrorRpcErrorCodeRefrenceSnapshootBlockIllegal(),
        ViteErrorCode.rpcRefrencePrevBlockFailed: R.string.localizable.viteErrorRpcErrorCodeVerifyFailure(String(ViteErrorCode.rpcRefrencePrevBlockFailed.id)),
        ViteErrorCode.rpcRefrenceBlockIsPending: R.string.localizable.viteErrorRpcErrorCodeVerifyFailure(String(ViteErrorCode.rpcRefrenceBlockIsPending.id)),
        ]

    public var localizedDescription: String {
        return viteErrorMessage
    }
}

extension Error {

    var viteErrorCode: ViteErrorCode {
        if let error = self as? ViteError {
            return error.code
        } else {
            return ViteError.conversion(from: self).code
        }
    }

    // show in UI
    var viteErrorMessage: String {
        var ret = ""
        let error = ViteError.conversion(from: self)
        if let str = ViteError.code2MessageMap[error.code] {
            ret = str
        } else {
            switch error.code.type {
            case .custom:
                ret = error.rawMessage
            case .st_con, .st_req, .st_res:
                ret = "\(R.string.localizable.viteErrorNetworkError())(\(error.code.toString()))"
            default:
                ret = "\(R.string.localizable.viteErrorOperationFailure())(\(error.code.toString()))"
            }
        }
        return ret
    }

    // print in log
    var viteErrorRawMessage: String {
        if let error = self as? ViteError {
            return error.rawMessage
        } else {
            return ViteError.conversion(from: self).rawMessage
        }
    }
}
