//
//  BalanceInfoDetailAdapter.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/5.
//

import Foundation

protocol BalanceInfoDetailAdapter {
    func setup(containerView: UIView, tokenInfo: TokenInfo)
}

extension TokenInfo {
    func createBalanceInfoDetailAdapter() -> BalanceInfoDetailAdapter {
        if isViteCoin {
            return BalanceInfoDetailViteCoinAdapter()
        } else {
            return BalanceInfoDetailViteTokenAdapter()
        }
    }
}
