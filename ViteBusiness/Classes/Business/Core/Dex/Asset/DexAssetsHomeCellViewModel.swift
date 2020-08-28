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
