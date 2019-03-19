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
        return !confirmed && (txType == .txReceived || !txSentFinalized)
    }

    var canRepost: Bool {
        return !confirmed && txType == .txSent && txSentFinalized
    }

}
