//
//  TokenInfo.swift
//  Pods
//
//  Created by Stone on 2019/2/21.
//

import ObjectMapper
import ViteWallet

public enum ChainType {
    case vite
    case eth
}

public typealias TokenCode = String

public struct TokenInfo: Mappable {

    public fileprivate(set)  var tokenCode: TokenCode = ""
    public fileprivate(set)  var chainType: ChainType = .vite
    public fileprivate(set)  var name: String = ""
    public fileprivate(set)  var symbol: String = ""
    public fileprivate(set)  var decimals: Int = 0
    public fileprivate(set)  var icon: String = ""
    public fileprivate(set)  var id: String = "" // Vite is tokenId, ERC20 is contractAddress

    public var coinFamily: String {
        switch chainType {
        case .vite:
            if tokenCode == TokenInfo.Const.viteCoin.tokenCode {
                return "Vite Coin"
            } else {
                return "Vite Token"
            }
        case .eth:
            if tokenCode == TokenInfo.Const.etherCoin.tokenCode {
                return "ETH Coin"
            } else {
                return "ERC20 Token"
            }
        }
    }

    public var viteTokenId: String {
        return id
    }

    public var ethContractAddress: String {
        return id
    }

    public init?(map: Map) {}

    public mutating func mapping(map: Map) {
        tokenCode <- map["tokenCode"]
        chainType <- map["platform"]
        name <- map["name"]
        symbol <- map["symbol"]
        decimals <- map["decimals"]
        icon <- map["icon"]
        id <- map["tokenAddress"]
    }

    init(tokenCode: TokenCode, chainType: ChainType, name: String, symbol: String, decimals: Int, icon: String, id: String) {
        self.tokenCode = tokenCode
        self.chainType = chainType
        self.name = name
        self.symbol = symbol
        self.decimals = decimals
        self.icon = icon
        self.id = id
    }
}

extension TokenInfo: Equatable {
    public static func == (lhs: TokenInfo, rhs: TokenInfo) -> Bool {
        return lhs.tokenCode == rhs.tokenCode
    }
}

extension TokenInfo {
    func toViteToken() -> Token? {
        guard chainType == .vite else {
            return nil
        }

        return Token(id: id, name: name, symbol: symbol, decimals: decimals)
    }

    func toETHToken() -> ETHToken? {
        guard chainType == .eth else {
            return nil
        }

        return ETHToken(contractAddress: id, name: name, symbol: symbol, decimals: decimals)
    }
}

extension TokenInfo {
    public struct Const {
        public static let etherCoin = TokenInfo(tokenCode: "etherCoin", chainType: .eth, name: "Ether", symbol: "Ether", decimals: 18, icon: "https://xx", id: "")

        public static let viteERC20 = TokenInfo(tokenCode: "viteERC20", chainType: .eth, name: "vite erc20", symbol: "vite erc20", decimals: 18, icon: "https://xx", id: "0x54b716345c14ba851f1b51dcc1491abee6ba8f44")
        
        public static let viteCoin = TokenInfo(tokenCode: "viteCoin",
                                               chainType: .vite,
                                               name: ViteWalletConst.viteToken.name,
                                               symbol: ViteWalletConst.viteToken.symbol,
                                               decimals: ViteWalletConst.viteToken.decimals,
                                               icon: "https://xx",
                                               id: ViteWalletConst.viteToken.id)
    }
}


// UI Style
extension TokenInfo {
    var chainIcon: UIImage? {
        if self == TokenInfo.Const.etherCoin {
            return R.image.icon_logo_chain_eth()
        } else {
            return nil
        }
    }
}
