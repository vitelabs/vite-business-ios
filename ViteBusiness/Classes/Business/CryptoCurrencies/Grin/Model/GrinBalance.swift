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

    var total = "--"
    var amountAwaitingConfirmation = "--"
    var amountCurrentlySpendable = "--"
    var amountLocked = "--"
    var legalTenderWorthed = "≈--"

    init() { }

    init(_ info: Vite_GrinWallet.WalletInfo) {
        let spendableBalance = Balance(value: BigInt(info.amountCurrentlySpendable))
        amountCurrentlySpendable = spendableBalance.amount(decimals: 9, count: 2)
        amountAwaitingConfirmation =
            Balance(value: BigInt(info.amountAwaitingConfirmation + info.amountImmature))
            .amount(decimals: 9, count: 2)
        amountLocked =
            Balance(value: BigInt(info.amountLocked))
            .amount(decimals: 9, count: 2)
        total =
            Balance(value: BigInt(info.total))
            .amount(decimals: 9, count: 2)
        legalTenderWorthed =
            "≈" + ExchangeRateManager.instance.rateMap
                .priceString(for: GrinManager.tokenInfo, balance: spendableBalance)
    }

}
