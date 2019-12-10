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
    let priceDriver: Driver<String>
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
            .map({ (infoType,isHidePrice, rateMap, balanceInfos, viteXBalanceInfos) -> String in
                if isHidePrice {
                    return "****"
                } else {
                    if infoType == .wallet {
                        var allPrice = BigDecimal()
                        for balanceInfo in balanceInfos {
                            let price = rateMap.price(for: balanceInfo.tokenInfo, balance: balanceInfo.balance)
                            allPrice = allPrice + price
                        }
                        let currency = AppSettingsService.instance.appSettings.currency
                        return "\(currency.symbol) \(BigDecimalFormatter.format(bigDecimal: allPrice, style: .decimalRound(2), padding: .padding, options: [.groupSeparator]))"
                    } else if infoType == .viteX {
                        var allPrice = BigDecimal()
                        for balanceInfo in viteXBalanceInfos {
                            let price = rateMap.price(for: balanceInfo.tokenInfo, balance: balanceInfo.balanceInfo.total)
                            allPrice = allPrice + price
                        }
                        let currency = AppSettingsService.instance.appSettings.currency
                        return "\(currency.symbol) \(BigDecimalFormatter.format(bigDecimal: allPrice, style: .decimalRound(2), padding: .padding, options: [.groupSeparator]))"
                    } else {
                        return ""
                    }

                }
            })
    }
}
