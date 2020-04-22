//
//  MarketLimit.swift
//  ViteBusiness
//
//  Created by Stone on 2020/4/22.
//

import ObjectMapper
import ViteWallet
import SwiftyJSON

struct MarketLimit {
    let minAmount: MinAmount

    init(json: JSON?) {
        var btc = Amount(0)
        var usdt = Amount(0)
        var eth = Amount(0)
        var vite = Amount(0)

        if let minAmount = json?["minAmount"] {
            if let string = minAmount["BTC-000"].string, let amount = string.toAmount(decimals: 8) {
                btc = amount
            }

            if let string = minAmount["USDT-000"].string, let amount = string.toAmount(decimals: 6) {
                usdt = amount
            }

            if let string = minAmount["ETH-000"].string, let amount = string.toAmount(decimals: 18) {
                eth = amount
            }

            if let string = minAmount["VITE"].string, let amount = string.toAmount(decimals: 18) {
                vite = amount
            }
        }
        
        self.minAmount = MinAmount(btc: btc, usdt: usdt, eth: eth, vite: vite)
    }

    func getMinAmount(quoteTokenSymbol: String) -> Amount {
        switch quoteTokenSymbol {
        case "BTC-000":
            return minAmount.btc
        case "USDT-000":
            return minAmount.usdt
        case "ETH-000":
            return minAmount.eth
        case "VITE":
            return minAmount.vite
        default:
            return Amount(0)
        }
    }
}

extension MarketLimit {
    struct MinAmount {
        let btc: Amount
        let usdt: Amount
        let eth: Amount
        let vite: Amount
    }
}
