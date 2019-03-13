//
//  GrinBalance.swift
//  Pods
//
//  Created by haoshenyang on 2019/3/12.
//

import UIKit
import Vite_GrinWallet
import BigInt
import ViteWallet

class GrinBalance {

    var total = ""
    var amountAwaitingConfirmation = ""
    var amountCurrentlySpendable = ""
    var amountLocked = ""

    init() {

    }

    init(_ info: Vite_GrinWallet.WalletInfo) {
        guard info != nil else {
            return
        }
        self.amountCurrentlySpendable = Balance(value: BigInt(info.amountCurrentlySpendable)).amountShort(decimals:9)
        self.amountAwaitingConfirmation = Balance(value: BigInt(info.amountAwaitingConfirmation)).amountShort(decimals:9)
        self.amountLocked = Balance(value: BigInt(info.amountLocked)).amountShort(decimals:9)
        self.total = Balance(value: BigInt(info.total)).amountShort(decimals:9)
    }

}
