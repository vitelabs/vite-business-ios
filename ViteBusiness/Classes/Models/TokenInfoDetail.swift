//
//  TokenInfoDetail.swift
//  ViteBusiness
//
//  Created by Stone on 2020/5/8.
//

import Foundation
import ObjectMapper
import ViteWallet

struct TokenInfoDetail: Mappable {

    fileprivate(set)  var tokenCode: TokenCode = ""
    fileprivate(set)  var coinType: CoinType = .unsupport
    fileprivate(set)  var rawChainName: String = ""
    fileprivate(set)  var name: String = ""
    fileprivate(set)  var symbol: String = ""
    fileprivate(set)  var decimals: Int = 0
    fileprivate(set)  var index: Int = 0
    fileprivate(set)  var icon: String = ""
    fileprivate(set)  var id: String = "" // Vite is tokenId, ERC20 is contractAddress
    fileprivate(set)  var gatewayInfo: GatewayInfo? = nil
    fileprivate(set)  var total: String? = nil

    fileprivate(set)  var overview = [String:String]()
    fileprivate(set)  var website: String = ""
    fileprivate(set)  var whitepaper: String = ""
    fileprivate(set)  var links: MarketPairDetailInfo.Links = MarketPairDetailInfo.Links()


    init() {}

    var uniqueSymbol: String {
        if case .vite = coinType {
            return toViteToken()!.uniqueSymbol
        } else {
            return symbol
        }
    }

    func toViteToken() -> Token? {
        guard coinType == .vite else {
            return nil
        }

        return Token(id: id, name: name, symbol: symbol, decimals: decimals, index: index)
    }

    var overviewString: String {
        return (LocalizationService.sharedInstance.currentLanguage == .chinese ? overview["zh"] : overview["en"]) ?? overview["en"] ?? ""
    }

    init?(map: Map) {
        guard let platform = map.JSON["platform"] as? [String: Any], let type = platform["symbol"] as? String, let _ = CoinType(rawValue: type) else {
            return nil
        }
    }

    mutating func mapping(map: Map) {
        tokenCode <- map["tokenCode"]
        coinType <- (map["platform.symbol"], TokenInfo.coinTypeTransform)
        rawChainName <- map["platform.symbol"]
        name <- map["name"]
        symbol <- map["symbol"]
        decimals <- map["tokenDigit"]
        index <- map["platform.tokenIndex"]
        icon <- map["icon"]
        id <- map["platform.tokenAddress"]
        gatewayInfo <- map["gatewayInfo"]
        total <- map["total"]
        overview <- map["overview"]
        website <- map["website"]
        whitepaper <- map["whitepaper"]
        links <- map["links"]
    }
}
