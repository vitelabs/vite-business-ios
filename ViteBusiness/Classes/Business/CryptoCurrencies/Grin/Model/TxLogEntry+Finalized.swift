//
//  TxLogEntry+Finalized.swift
//  Action
//
//  Created by haoshenyang on 2019/3/14.
//

import Foundation
import Vite_GrinWallet

extension TxLogEntry {
    var txSentFinalized: Bool {
        guard self.txType == .txSent else {
            return false
        }
        guard let slateId = self.txSlateId else {
            return false
        }
        return GrinManager.default.finalizedTxs().contains(slateId)
    }

    var canCancel: Bool {
        let isCancled = self.txType == .txReceivedCancelled || self.txType == .txSentCancelled
        if isCancled { return false }
        return  !confirmed && (txType == .txReceived || !txSentFinalized)
    }

    var canRepost: Bool {
        return !confirmed && txType == .txSent && txSentFinalized
    }

}
