//
//  DexAssetsHomeCellViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2020/8/27.
//

import Foundation

struct DexAssetsHomeCellViewModel {
    let tokenInfo: TokenInfo
    let balanceString : String
    let legalString: String
    let btcValuation: BigDecimal

    var isValuable: Bool { btcValuation >= BigDecimal("0.00005")! }
}

extension DexAssetsHomeCellViewModel {
    static func defaultIncreasingOrder(e1: DexAssetsHomeCellViewModel, e2: DexAssetsHomeCellViewModel) -> Bool {
        if e1.btcValuation == e2.btcValuation {
            return e1.defaultSortKey < e2.defaultSortKey
        } else {
            return e1.btcValuation > e2.btcValuation
        }
    }

    var defaultSortKey: String {
        if tokenInfo.uniqueSymbol == "VITE" {
            return "@1"
        } else if tokenInfo.uniqueSymbol == "VX" {
            return "@2"
        } else if tokenInfo.uniqueSymbol == "BTC-000" {
            return "@3"
        } else if tokenInfo.uniqueSymbol == "ETH-000" {
            return "@4"
        } else if tokenInfo.uniqueSymbol == "USDT-000" {
            return "@5"
        } else {
            return tokenInfo.uniqueSymbol
        }
    }
}

