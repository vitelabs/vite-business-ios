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
    var balance: Amount { get }
}

extension BalanceInfo: WalletHomeBalanceInfo {
    var tokenInfo: TokenInfo {
        return MyTokenInfosService.instance.tokenInfo(forViteTokenId: token.id)!
    }
}

extension ETHBalanceInfo: WalletHomeBalanceInfo {}

final class WalletHomeBalanceInfoTableViewModel {

    var  balanceInfosDriver: Driver<[WalletHomeBalanceInfoViewModel]>
    var  viteXBalanceInfosDriver: Driver<[WalletHomeBalanceInfoViewModel]>


    init(isHidePriceDriver: Driver<Bool>) {
        balanceInfosDriver = Driver.combineLatest(
            isHidePriceDriver,
            ExchangeRateManager.instance.rateMapDriver,
            ViteBalanceInfoManager.instance.balanceInfosDriver,
            ETHBalanceInfoManager.instance.balanceInfosDriver,
            GrinManager.default.balanceDriver)
            .map({ (arg) -> [WalletHomeBalanceInfoViewModel] in
                let (isHidePrice, _, viteMap, ethMap, grinBalance) = arg
                return MyTokenInfosService.instance.tokenInfos
                    .map({ (tokenInfo) -> WalletHomeBalanceInfo in
                        switch tokenInfo.coinType {
                        case .vite:
                            return viteMap[tokenInfo.viteTokenId] ?? BalanceInfo(token: tokenInfo.toViteToken()!, balance: Amount(), unconfirmedBalance: Amount(), unconfirmedCount: 0)
                        case .eth:
                            return ethMap[tokenInfo.tokenCode] ?? ETHBalanceInfo(tokenCode: tokenInfo.tokenCode, balance: Amount())
                        case .grin:
                            return grinBalance
                        default:
                            fatalError()
                        }
                    }).map({ (balanceInfo) -> WalletHomeBalanceInfoViewModel in
                        return WalletHomeBalanceInfoViewModel(balanceInfo: balanceInfo, isHidePrice: isHidePrice)
                        })
            })

        viteXBalanceInfosDriver = balanceInfosDriver.map { (vms) -> [WalletHomeBalanceInfoViewModel] in
            return vms.filter({ (vm) -> Bool in
                return vm.tokenInfo.coinType == .vite
            })
        }
    }

    func registerFetchAll() {
        ViteBalanceInfoManager.instance.registerFetch(tokenInfos: MyTokenInfosService.instance.tokenInfos.filter({ $0.coinType == .vite }))
        ETHBalanceInfoManager.instance.registerFetch(tokenInfos: MyTokenInfosService.instance.tokenInfos.filter({ $0.coinType == .eth }))
        GrinManager.default.getBalance()
    }

    func unregisterFetchAll() {
        ViteBalanceInfoManager.instance.unregisterFetch(tokenInfos: MyTokenInfosService.instance.tokenInfos.filter({ $0.coinType == .vite }))
        ETHBalanceInfoManager.instance.unregisterFetch(tokenInfos: MyTokenInfosService.instance.tokenInfos.filter({ $0.coinType == .eth }))
    }
}


