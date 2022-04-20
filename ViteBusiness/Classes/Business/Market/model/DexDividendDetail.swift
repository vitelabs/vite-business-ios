//
//  DexDividendDetail.swift
//  ViteWallet
//
//  Created by vite on 2022/4/21.
//

import Foundation
import ObjectMapper
import ViteWallet

struct DexDividendDetail {
    var myDexDividendInfo: DexDividendInfo = DexDividendInfo()
    var list: [Info] = []
    
    struct Info {
        var date: Int64 = 0
        var vxQuantity: String = "0.000000"
        var dividendInfo: DexDividendInfo = DexDividendInfo()
    }
}
