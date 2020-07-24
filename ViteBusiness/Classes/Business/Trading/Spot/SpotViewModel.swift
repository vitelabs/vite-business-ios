//
//  SpotViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2020/4/23.
//

import Foundation
import ViteWallet


struct SpotViewModel {
    let marketPairDetailInfo: MarketPairDetailInfo
    let tradeTokenInfo: TokenInfo
    let quoteTokenInfo: TokenInfo
    let vipState: Bool
    let svipState: Bool
    let dexMarketInfo: DexMarketInfo
    let invited: Bool
    let feeRate: BigDecimal

    var operatorInfoIconUrlString: String? { marketPairDetailInfo.operatorInfo?.icon }
    var level: Int { marketPairDetailInfo.operatorInfo?.level ?? 0 }
}
