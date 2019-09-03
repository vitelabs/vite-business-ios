//
//  BifrostViteSendTxTask.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/10.
//

import Foundation

class BifrostViteSendTxTask {

    enum Status {
        case pending
        case processing
        case retry
        case failed
        case finished
        case canceled
    }

    let timestamp: Date
    let id: Int64
    let tx : VBViteSendTx
    let info: BifrostConfirmInfo
    let tokenInfo: TokenInfo

    var status: Status = .pending

    init(id: Int64, tx : VBViteSendTx, info: BifrostConfirmInfo, tokenInfo: TokenInfo) {
        self.timestamp = Date()
        self.id = id
        self.tx = tx
        self.info = info
        self.tokenInfo = tokenInfo
    }

    var statusDescription: String {
        switch status {
        case .pending:
            return R.string.localizable.bifrostListPageStatusPending()
        case .processing, .retry:
            return R.string.localizable.bifrostListPageStatusProcessing()
        case .failed:
            return R.string.localizable.bifrostListPageStatusFailed()
        case .finished:
            return R.string.localizable.bifrostListPageStatusFinished()
        case .canceled:
            return R.string.localizable.bifrostListPageStatusCanceled()
        }
    }
}
