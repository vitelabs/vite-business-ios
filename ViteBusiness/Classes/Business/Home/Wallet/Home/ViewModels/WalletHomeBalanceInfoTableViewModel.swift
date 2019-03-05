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
    var balance: Balance { get }
}

extension BalanceInfo: WalletHomeBalanceInfo {
    var tokenInfo: TokenInfo {
        return MyTokenInfosService.instance.tokenInfo(forViteTokenId: token.id)!
    }
}

extension ETHBalanceInfo: WalletHomeBalanceInfo {}

final class WalletHomeBalanceInfoTableViewModel {
    var  balanceInfosDriver: Driver<[WalletHomeBalanceInfo]>

    init() {
        balanceInfosDriver = Driver.combineLatest(
            ExchangeRateManager.instance.rateMapDriver,
            ViteBalanceInfoManager.instance.balanceInfosDriver,
            ETHBalanceInfoManager.instance.balanceInfosDriver).map({ (_, viteMap, ethMap) -> [WalletHomeBalanceInfo] in
                return MyTokenInfosService.instance.tokenInfos.map({ (tokenInfo) -> WalletHomeBalanceInfo in
                    switch tokenInfo.coinType {
                    case .vite:
                        return viteMap[tokenInfo.viteTokenId] ?? BalanceInfo(token: tokenInfo.toViteToken()!, balance: Balance(), unconfirmedBalance: Balance(), unconfirmedCount: 0)
                    case .eth:
                        return ethMap[tokenInfo.tokenCode] ?? ETHBalanceInfo(tokenCode: tokenInfo.tokenCode, balance: Balance())
                    }
                })
            })
    }

    func registerFetchAll() {
        ViteBalanceInfoManager.instance.registerFetch(tokenInfos: MyTokenInfosService.instance.tokenInfos.filter({ $0.coinType == .vite }))
        ETHBalanceInfoManager.instance.registerFetch(tokenInfos: MyTokenInfosService.instance.tokenInfos.filter({ $0.coinType == .eth }))
    }

    func unregisterFetchAll() {
        ViteBalanceInfoManager.instance.unregisterFetch(tokenInfos: MyTokenInfosService.instance.tokenInfos.filter({ $0.coinType == .vite }))
        ETHBalanceInfoManager.instance.unregisterFetch(tokenInfos: MyTokenInfosService.instance.tokenInfos.filter({ $0.coinType == .eth }))
    }
}
