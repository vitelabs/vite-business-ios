//
//  DisplayableError.swift
//  ViteBusiness
//
//  Created by Stone on 2019/5/30.
//

import Web3swift
import ViteEthereum
import ViteWallet

protocol DisplayableError: Error {
    var errorMessage: String { get }
}

extension WalletError: DisplayableError {
    var errorMessage: String {
        switch self {
        case .notEnoughBalance:
            return R.string.localizable.ethErrorRpcErrorCodeNotEnoughBalance()
        default:
            return rawValue
        }
    }
}

extension ViteError: DisplayableError {
    var errorMessage: String {
        return viteErrorMessage
    }
}

extension Web3Error: DisplayableError {
    var errorMessage: String {
        switch self {
        case .transactionSerializationError:
            return "Transaction Serialization Error"
        case .connectionError:
            return "Connection Error"
        case .dataError:
            return "Data Error"
        case .walletError:
            return "Wallet Error"
        case .inputError(let desc):
            return desc
        case .nodeError(let desc):
            if desc == "insufficient funds for gas * price + value" {
                return R.string.localizable.ethErrorRpcErrorCodeNotEnoughFee()
            } else {
                return desc
            }
        case .processingError(let desc):
            return desc
        case .keystoreError(let err):
            return err.localizedDescription
        case .generalError(let err):
            return err.localizedDescription
        case .unknownError:
            return "Unknown Error"
        }
    }
}
