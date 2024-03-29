//
//  WalletHomeBalanceInfoTableViewModel.swift
//  Vite
//
//  Created by Stone on 2018/9/9.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ViteWallet

protocol WalletHomeBalanceInfo {
    var tokenInfo: TokenInfo { get }
    var total: Amount { get }
}

extension BalanceInfo: WalletHomeBalanceInfo {
    var tokenInfo: TokenInfo {
        return TokenInfoCacheService.instance.tokenInfo(forViteTokenId: token.id) ?? {
            assert(false)
            return TokenInfo(tokenCode: token.id,
                             coinType: .vite,
                             rawChainName: CoinType.vite.rawValue,
                             name: token.name,
                             symbol: token.symbol,
                             decimals: token.decimals,
                             index: token.index,
                             icon: "",
                             id: token.id,
                             gatewayInfo: nil)
        }()
    }
}

final class WalletHomeBalanceInfoTableViewModel {

    var  balanceInfosDriver: Driver<[WalletHomeBalanceInfoViewModel]>
    var  viteXBalanceInfosDriver: Driver<[WalletHomeViteXBalanceInfoViewModel]>
    var lastViteXBalanceInfos = [WalletHomeViteXBalanceInfoViewModel]()
    let bag = DisposeBag()

    init(isHidePriceDriver: Driver<Bool>) {
        balanceInfosDriver = Driver.combineLatest(
            isHidePriceDriver,
            ExchangeRateManager.instance.rateMapDriver,
            ViteBalanceInfoManager.instance.balanceInfosDriver)
            .map({ (arg) -> [WalletHomeBalanceInfoViewModel] in
                let (isHidePrice, _, viteMap) = arg
                return MyTokenInfosService.instance.tokenInfos
                    .map({ (tokenInfo) -> WalletHomeBalanceInfo in
                        switch tokenInfo.coinType {
                        case .vite:
                            return viteMap[tokenInfo.viteTokenId] ?? BalanceInfo(token: tokenInfo.toViteToken()!, balance: Amount(), unconfirmedBalance: Amount(), unconfirmedCount: 0)
                        case .unsupport:
                            fatalError()
                        }
                    }).map({ (balanceInfo) -> WalletHomeBalanceInfoViewModel in
                        return WalletHomeBalanceInfoViewModel(balanceInfo: balanceInfo, isHidePrice: isHidePrice)
                        })
            })

        viteXBalanceInfosDriver =
            Driver.combineLatest(
                isHidePriceDriver,
                ViteBalanceInfoManager.instance.dexBalanceInfosDriver)
                .map { (arg) -> [WalletHomeViteXBalanceInfoViewModel] in
                    let (isHidePrice, viteXMap) = arg
                    return MyTokenInfosService.instance.tokenInfos
                        .filter { $0.coinType == .vite }
                        .map { (tokenInfo) -> WalletHomeViteXBalanceInfoViewModel in
                            let balanceInfo = viteXMap[tokenInfo.viteTokenId] ?? DexBalanceInfo(token: tokenInfo.toViteToken()!)
                            return WalletHomeViteXBalanceInfoViewModel(tokenInfo: tokenInfo, balanceInfo: balanceInfo, isHidePrice: isHidePrice)
                    }
        }

        viteXBalanceInfosDriver.asObservable() .bind{ [weak self] viteXBalanceInfos in
            self?.lastViteXBalanceInfos = viteXBalanceInfos
            }.disposed(by: bag)


    }

    func registerFetchAll() {
        
    }

    func unregisterFetchAll() {
        
    }
}


