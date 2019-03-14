//
//  TokenInfo.swift
//  Pods
//
//  Created by Stone on 2019/2/21.
//

import ObjectMapper
import ViteWallet

public enum CoinType: String {
    case vite = "VITE"
    case eth = "ETH"

    var name: String {
        switch self {
        case .vite:
            return "VITE"
        case .eth:
            return "ETH"
        }
    }

    static var allTypes: [CoinType] = [.vite, .eth]


    var backgroundGradientColors: [UIColor] {
        switch self {
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

    var mainColor: UIColor {
        switch self {
        case .vite:
            return UIColor(netHex: 0x007AFF)
        case .eth:
            return UIColor(netHex: 0x5BC500)
        }
    }

    var strokeColor: UIColor {
        switch self {
        case .vite:
            return UIColor(netHex: 0x007AFF, alpha: 0.67)
        case .eth:
            return UIColor(netHex: 0x5BC500)
        }
    }

    var shadowColor: UIColor {
        switch self {
        case .vite:
            return UIColor(netHex: 0xF2F8FF)
        case .eth:
            return UIColor(netHex: 0xF8FFF2)
        }
    }
}

public typealias TokenCode = String

extension TokenCode {
    public static let viteCoin = "1157"
    public static let etherCoin = "1"
    public static let viteERC20 = "39"
}

public struct TokenInfo: Mappable {

    public fileprivate(set)  var tokenCode: TokenCode = ""
    public fileprivate(set)  var coinType: CoinType = .vite
    public fileprivate(set)  var name: String = ""
    public fileprivate(set)  var symbol: String = ""
    public fileprivate(set)  var decimals: Int = 0
    public fileprivate(set)  var icon: String = ""
    public fileprivate(set)  var id: String = "" // Vite is tokenId, ERC20 is contractAddress

    public var coinFamily: String {
        switch coinType {
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
        coinType <- (map["platform"], coinTypeTransform)
        name <- map["name"]
        symbol <- map["symbol"]
        decimals <- map["decimal"]
        icon <- map["icon"]
        id <- map["tokenAddress"]
    }

    private let coinTypeTransform = TransformOf<CoinType, String>(fromJSON: { (string) -> CoinType? in
        guard let string = string else { return nil }
        return CoinType(rawValue: string)
    }, toJSON: { (coinType) -> String? in
        guard let coinType = coinType else { return nil }
        return coinType.rawValue
    })

    init(tokenCode: TokenCode, coinType: CoinType, name: String, symbol: String, decimals: Int, icon: String, id: String) {
        self.tokenCode = tokenCode
        self.coinType = coinType
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

    func getCoinHeaderDisplay() -> String? {
        if self.coinType == .vite {
            return R.string.localizable.tokenListPageSectionViteHeader()
        }else if self.coinType == .eth {
            return R.string.localizable.tokenListPageSectionEthHeader()
        }
        return ""
    }
}

extension TokenInfo {
    static var viteCoin: TokenInfo {
        return MyTokenInfosService.instance.tokenInfo(forViteTokenId: ViteWalletConst.viteToken.id)!
    }
}

extension TokenInfo {
    func toViteToken() -> Token? {
        guard coinType == .vite else {
            return nil
        }

        return Token(id: id, name: name, symbol: symbol, decimals: decimals)
    }

    func toETHToken() -> ETHToken? {
        guard coinType == .eth else {
            return nil
        }

        return ETHToken(contractAddress: id, name: name, symbol: symbol, decimals: decimals)
    }
}

// UI Style
extension TokenInfo {
    var chainIcon: UIImage? {
        if case .eth = coinType, !isEtherCoin {
            return R.image.icon_logo_chain_eth()
        } else {
            return nil
        }
    }

    var coinBackgroundGradientColors: [UIColor] {
        return coinType.backgroundGradientColors
    }

    var mainColor: UIColor {
        return coinType.mainColor
    }

    var strokeColor: UIColor {
        return coinType.strokeColor
    }

    var shadowColor: UIColor {
        return coinType.shadowColor
    }
}
