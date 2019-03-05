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
    let walletNameDriver: Driver<String>
    let priceDriver: Driver<String>
    let isHidePriceDriver: Driver<Bool>

    init(isHidePriceDriver: Driver<Bool>, walletHomeBalanceInfoTableViewModel: WalletHomeBalanceInfoTableViewModel) {
        self.isHidePriceDriver = isHidePriceDriver
        walletNameDriver = HDWalletManager.instance.walletDriver.filterNil().map({ $0.name })
        priceDriver = Driver.combineLatest(
            isHidePriceDriver,
            ExchangeRateManager.instance.rateMapDriver,
            walletHomeBalanceInfoTableViewModel.balanceInfosDriver)
            .map({ (isHidePrice, rateMap, balanceInfos) -> String in
                if isHidePrice {
                    return "****"
                } else {
                    return "9.999999"
                }
            })
    }
}
