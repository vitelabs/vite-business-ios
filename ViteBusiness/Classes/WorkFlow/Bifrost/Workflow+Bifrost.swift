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
                                         toAddress: ViteAddress,
                                         tokenInfo: TokenInfo,
                                         amount: Amount,
                                         data: Data?,
                                         completion: @escaping (Result<AccountBlock>) -> ()) {
        func send() {
            HUD.show()
            ViteNode.rawTx.send.withoutPow(account: account,
                                           toAddress: toAddress,
                                           tokenId: tokenInfo.viteTokenId,
                                           amount: amount,
                                           data: data)
                .always {
                    HUD.hide()
                }.recover { (e) -> Promise<AccountBlock> in
                    if ViteError.conversion(from: e).code == ViteErrorCode.rpcNotEnoughQuota {
                        return sendRawTxWithPowWorkflow(getPowPromise: {
                            return ViteNode.rawTx.send.getPow(account: account,
                                                              toAddress: toAddress,
                                                              tokenId: tokenInfo.viteTokenId,
                                                              amount: amount,
                                                              data: data)
                        })
                    } else {
                        return Promise(error: e)
                    }
                }.done {
                    AlertControl.showCompletion(R.string.localizable.bifrostToastOperationSuccess())
                    completion(Result.success($0))
                }
                .catch { e in
                    let error = ViteError.conversion(from: e)
                    if error.code == ViteErrorCode.rpcNotEnoughBalance {
                        AlertSheet.show(title: R.string.localizable.sendPageNotEnoughBalanceAlertTitle(), message: nil,
                                        titles: [.default(title: R.string.localizable.sendPageNotEnoughBalanceAlertButton())])
                    } else if error != ViteError.cancel {
                        Toast.show(error.viteErrorMessage)
                    }
                    completion(Result.failure(error))
            }

        }

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
                    send()
                }
                }.show()
        }
        showConfirm()
    }
}
