//
//  GrinBalance.swift
//  Pods
//
//  Created by haoshenyang on 2019/3/12.
//

import UIKit
////import Vite_GrinWallet
import BigInt
import ViteWallet

class GrinBalance: WalletHomeBalanceInfo {

    var tokenInfo: TokenInfo {
        return GrinManager.tokenInfo
    }
    var total: Amount = Amount()

    var totalString = "--"
    var amountAwaitingConfirmation = "--"
    var amountCurrentlySpendable = "--"
    var amountLocked = "--"
    var legalTenderWorthed = "≈--"
    var amountAwaitingFinalization = "--"

    var lastConfirmedHeight = 0

    init() { }

    init(_ info: GRINWalletInfo) {
        let spendableBalance = Amount(info.amountCurrentlySpendable)
        amountCurrentlySpendable = spendableBalance.amount(decimals: 9, count: 9)
        amountAwaitingConfirmation =
            Amount(info.amountAwaitingConfirmation + info.amountImmature)
            .amount(decimals: 9, count: 9)
        amountLocked =
            Amount(info.amountLocked)
            .amount(decimals: 9, count: 9)
        totalString =
            Amount(info.total)
            .amount(decimals: 9, count: 9)
        legalTenderWorthed =
            "≈" + ExchangeRateManager.instance.rateMap
                .priceString(for: GrinManager.tokenInfo, balance: spendableBalance)
        total = spendableBalance
        lastConfirmedHeight = info.lastConfirmedHeight
        amountAwaitingFinalization = Amount(info.amountAwaitingFinalization).amount(decimals: 9, count: 9)
    }

}
