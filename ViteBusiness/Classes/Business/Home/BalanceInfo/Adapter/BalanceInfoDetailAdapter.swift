//
//  BalanceInfoDetailAdapter.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/5.
//

import Foundation

protocol BalanceInfoDetailAdapter {
    var tokenInfo: TokenInfo { get }
    init(tokenInfo: TokenInfo)
    func viewDidAppear()
    func viewDidDisappear()
    func setup(containerView: UIView)
}

extension TokenInfo {
    func createBalanceInfoDetailAdapter() -> BalanceInfoDetailAdapter {
        switch coinType {
        case .vite:
            if isViteCoin {
                return BalanceInfoDetailViteCoinAdapter(tokenInfo: self)
            } else if tokenCode == "1226" {
                return BalanceInfoDetailGatewayTokenAdapter(tokenInfo: self)
            } else {
                return BalanceInfoDetailViteTokenAdapter(tokenInfo: self)
            }
        case .eth:
            if isViteERC20 {
                return BalanceInfoDetailEthErc20ViteAdapter(tokenInfo: self)
            } else {
                return BalanceInfoDetailEthChainAdapter(tokenInfo: self)
            }
        case .grin:
            fatalError()
        }
    }
}
