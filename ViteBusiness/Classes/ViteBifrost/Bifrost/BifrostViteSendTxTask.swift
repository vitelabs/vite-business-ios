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
        case waitingForRetry
        case failed
        case finished
        case canceled
    }

    enum TaskType {
        case sendTx(tx : VBViteSendTx, tokenInfo: TokenInfo)
        case signMessage(signMessage: VBViteSignMessage)
    }

    let timestamp: Date
    let id: Int64
    let info: BifrostConfirmInfo
    let type: TaskType

    var status: Status = .pending

    init(id: Int64, info: BifrostConfirmInfo, tx : VBViteSendTx, tokenInfo: TokenInfo) {
        self.timestamp = Date()
        self.id = id
        self.info = info
        self.type = .sendTx(tx: tx, tokenInfo: tokenInfo)
    }

    init(id: Int64, info: BifrostConfirmInfo, signMessage : VBViteSignMessage) {
        self.timestamp = Date()
        self.id = id
        self.info = info
        self.type = .signMessage(signMessage: signMessage)
    }

    var statusDescription: String {
        switch status {
        case .pending:
            return R.string.localizable.bifrostListPageStatusPending()
        case .processing, .waitingForRetry:
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
