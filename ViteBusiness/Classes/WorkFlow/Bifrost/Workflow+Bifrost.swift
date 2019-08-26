//
//  Workflow.swift
//  Vite
//
//  Created by Stone on 2018/12/20.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import UIKit
import ViteWallet
import Vite_HDWalletKit
import PromiseKit
import BigInt
import enum Alamofire.Result

public extension Workflow {

    static func bifrostSendTxWithConfirm(title: String,
                                         account: Wallet.Account,
                                         block: VBViteSendTx.Block,
                                         completion: @escaping (Result<AccountBlock>) -> ()) {
        bifrostSendTxWithConfirm(title: title,
                                 account: account,
                                 toAddress: block.toAddress,
                                 tokenId: block.tokenId,
                                 amount: block.amount,
                                 fee: block.fee,
                                 data: block.data,
                                 completion: completion)
    }

    static func bifrostSendTxWithConfirm(title: String,
                                         account: Wallet.Account,
                                         toAddress: ViteAddress,
                                         tokenId: ViteTokenId,
                                         amount: Amount,
                                         fee: Amount?,
                                         data: Data?,
                                         completion: @escaping (Result<AccountBlock>) -> ()) {
        func showConfirm() {
            BifrostConfirmView(title: title) { (ret) in
                switch ret {
                case .biometryAuthFailed:
                    Alert.show(title: R.string.localizable.workflowConfirmPageBiometryAuthFailedTitle(), message: nil,
                               titles: [.default(title: R.string.localizable.workflowConfirmPageBiometryAuthFailedBack())])
                    completion(Result.failure(ViteError.authFailed))
                case .passwordAuthFailed:
                    Alert.show(title: R.string.localizable.workflowConfirmPageToastPasswordError(), message: nil,
                               titles: [.default(title: R.string.localizable.workflowConfirmPagePasswordAuthFailedRetry())],
                               handler: { _, _ in showConfirm() })
                case .cancelled:
                    completion(Result.failure(ViteError.cancel))
                case .success:
                    send(account: account,
                         toAddress: toAddress,
                         tokenId: tokenId,
                         amount: amount,
                         fee: fee,
                         data: data,
                         successToast: R.string.localizable.bifrostToastOperationSuccess(),
                         type: .other,
                         completion: completion)
                }
                }.show()
        }
        showConfirm()
    }
}
