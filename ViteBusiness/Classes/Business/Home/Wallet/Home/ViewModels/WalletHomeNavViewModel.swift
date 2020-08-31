//
//  WalletHomeNavViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/5.
//

import ViteWallet
import RxSwift
import RxCocoa

class WalletHomeNavViewModel {

    enum InfoType {
        case wallet
        case viteX
    }
    let walletNameDriver: Driver<String>
    let priceDriver: Driver<(String, String)>
    let isHidePriceDriver: Driver<Bool>
    var infoTypeBehaviorRelay = BehaviorRelay<InfoType>(value: InfoType.wallet)

    init(isHidePriceDriver: Driver<Bool>, walletHomeBalanceInfoTableViewModel: WalletHomeBalanceInfoTableViewModel) {
        self.isHidePriceDriver = isHidePriceDriver
        walletNameDriver = HDWalletManager.instance.walletDriver.filterNil().map({ $0.name })
        priceDriver = Driver.combineLatest(
            infoTypeBehaviorRelay.asDriver(),
            isHidePriceDriver,
            ExchangeRateManager.instance.rateMapDriver,
            walletHomeBalanceInfoTableViewModel.balanceInfosDriver,
            walletHomeBalanceInfoTableViewModel.viteXBalanceInfosDriver)
            .map({ (infoType,isHidePrice, rateMap, balanceInfos, viteXBalanceInfos) -> (String, String) in
                if isHidePrice {
                    return ("****", "****")
                } else {
                    let btcValuation: BigDecimal
                    switch infoType {
                    case .wallet:
                        btcValuation = balanceInfos.map { $0.tokenInfo.btcValuationForBasicUnit(amount: $0.balance)}.reduce(BigDecimal(), +)
                    case .viteX:
                        btcValuation = viteXBalanceInfos.map { $0.tokenInfo.btcValuationForBasicUnit(amount: $0.balanceInfo.total)}.reduce(BigDecimal(), +)
                    }
                    let btcString = BigDecimalFormatter.format(bigDecimal: btcValuation, style: .decimalRound(8), padding: .none, options: [.groupSeparator])
                    let priceString = "≈" + ExchangeRateManager.instance.rateMap.btcPriceString(btc: btcValuation)
                    return (btcString, priceString)
                }
            })
    }
}
