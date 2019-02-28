//
//  TokenInfo.swift
//  Pods
//
//  Created by Stone on 2019/2/21.
//

import ObjectMapper
import ViteWallet

public enum ChainType: String {
    case vite
    case eth
}

public typealias TokenCode = String

extension TokenCode {
    public static let viteCoin = "viteCoin"
    public static let etherCoin = "etherCoin"
    public static let viteERC20 = "viteERC20"
}

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
            if isViteCoin {
                return "Vite Coin"
            } else {
                return "Vite Token"
            }
        case .eth:
            if isEtherCoin {
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
        chainType <- (map["platform"], chainTypeTransform)
        name <- map["name"]
        symbol <- map["symbol"]
        decimals <- map["decimals"]
        icon <- map["icon"]
        id <- map["tokenAddress"]
    }

    private let chainTypeTransform = TransformOf<ChainType, String>(fromJSON: { (string) -> ChainType? in
        guard let string = string else { return nil }
        return ChainType(rawValue: string)
    }, toJSON: { (chainType) -> String? in
        guard let chainType = chainType else { return nil }
        return chainType.rawValue
    })

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

    var isViteCoin: Bool { return tokenCode == TokenCode.viteCoin }
    var isEtherCoin: Bool { return tokenCode == TokenCode.etherCoin }
    var isViteERC20: Bool { return tokenCode == TokenCode.viteERC20 }
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

// UI Style
extension TokenInfo {
    var chainIcon: UIImage? {
        if isEtherCoin {
            return R.image.icon_logo_chain_eth()
        } else {
            return nil
        }
    }

    var chainBackgroundGradientColors: [UIColor] {
        switch chainType {
        case .vite:
            return [
                UIColor(netHex: 0x0B30E4),
                UIColor(netHex: 0x0D6CEF),
                UIColor(netHex: 0x0998F3),
                UIColor(netHex: 0x00C3FF),
                UIColor(netHex: 0x00ECFF),
            ]
        case .eth:
            return [
                UIColor(netHex: 0x429321),
                UIColor(netHex: 0xB4EC51),
            ]
        }
    }
}
