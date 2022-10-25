//
//  DisplayableError.swift
//  ViteBusiness
//
//  Created by Stone on 2019/5/30.
//

import ViteWallet

public protocol DisplayableError: Error {
    var errorMessage: String { get }
}

extension Error {
    var localizedDescription: String {
        if let e = self as? DisplayableError {
            return e.errorMessage
        } else {
            return (self as NSError).localizedDescription
        }
    }
}

extension WalletError: DisplayableError {
    public var errorMessage: String {
        switch self {
        case .notEnoughBalance:
            return R.string.localizable.ethErrorRpcErrorCodeNotEnoughBalance()
        default:
            return rawValue
        }
    }
}

extension ViteError: DisplayableError {
    public var errorMessage: String {
        return viteErrorMessage
    }
}
