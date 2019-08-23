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
    case grin = "GRIN"
    case unsupport = "unsupport"


    var name: String {
        return rawValue
    }

    static var allTypes: [CoinType] = [.vite, .eth, .grin]


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
        case .grin:
            return [
                UIColor(netHex: 0xFF5C00),
                UIColor(netHex: 0xFFC800)
            ]
        case .unsupport:
            return [UIColor.white]
        }
    }

    var mainColor: UIColor {
        switch self {
        case .vite:
            return UIColor(netHex: 0x007AFF)
        case .eth:
            return UIColor(netHex: 0x5BC500)
        case .grin:
            return UIColor(netHex: 0xFF9C00)
        case .unsupport:
            return UIColor.white
        }
    }

    var strokeColor: UIColor {
        switch self {
        case .vite:
            return UIColor(netHex: 0x007AFF, alpha: 0.67)
        case .eth:
            return UIColor(netHex: 0x5BC500)
        case .grin:
            return UIColor(netHex: 0xFF9C00)
        case .unsupport:
            return UIColor.white
        }
    }

    var shadowColor: UIColor {
        switch self {
        case .vite:
            return UIColor(netHex: 0xF2F8FF)
        case .eth:
            return UIColor(netHex: 0xF8FFF2)
        case .grin:
            return UIColor(netHex: 0xFFF9E1)
        case .unsupport:
            return UIColor.white
        }
    }

    var labelBackgroundColor: UIColor {
        switch self {
        case .vite:
            return UIColor(netHex: 0xF2F8FF)
        case .eth:
            return UIColor(netHex: 0xF1FFE6)
        case .grin:
            return UIColor(netHex: 0xFFF7DD)
        case .unsupport:
            return UIColor.white
        }
    }
}

public typealias TokenCode = String

extension TokenCode {
    public static let viteCoin = ViteConst.instance.tokenCode.viteCoin
    public static let etherCoin = ViteConst.instance.tokenCode.etherCoin
    public static let viteERC20 = ViteConst.instance.tokenCode.viteERC20
    public static let grinCoin = ViteConst.instance.tokenCode.grinCoin
}

public struct TokenInfo: Mappable {

    public fileprivate(set)  var tokenCode: TokenCode = ""
    public fileprivate(set)  var coinType: CoinType = .unsupport
    public fileprivate(set)  var rawChainName: String = ""
    public fileprivate(set)  var name: String = ""
    public fileprivate(set)  var symbol: String = ""
    public fileprivate(set)  var decimals: Int = 0
    public fileprivate(set)  var index: Int = 0
    public fileprivate(set)  var icon: String = ""
    public fileprivate(set)  var id: String = "" // Vite is tokenId, ERC20 is contractAddress
    public fileprivate(set)  var gatewayInfo: GatewayInfo? = nil



    public var uniqueSymbol: String {
        if case .vite = coinType {
            return toViteToken()!.uniqueSymbol
        } else {
            return symbol
        }
    }

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
                return "Ethereum Coin"
            } else {
                return "ERC20 Token"
            }
        case .grin:
             return "Grin Coin"
        case .unsupport:
            return "unsupport"
        }
    }

    public var viteTokenId: ViteTokenId {
        return id
    }

    public var ethContractAddress: String {
        return id
    }

    public init?(map: Map) {
        guard let type = map.JSON["platform"] as? String, let _ = CoinType(rawValue: type) else {
            return nil
        }
    }

    public mutating func mapping(map: Map) {
        tokenCode <- map["tokenCode"]
        coinType <- (map["platform"], coinTypeTransform)
        rawChainName <- map["platform"]
        name <- map["name"]
        symbol <- map["symbol"]
        decimals <- map["decimal"]
        index <- map["tokenIndex"]
        icon <- map["icon"]
        id <- map["tokenAddress"]
        gatewayInfo <- map["gatewayInfo"]
    }

    private let coinTypeTransform = TransformOf<CoinType, String>(fromJSON: { (string) -> CoinType? in
        guard let string = string else { return nil }
        return CoinType(rawValue: string)
    }, toJSON: { (coinType) -> String? in
        guard let coinType = coinType else { return nil }
        return coinType.rawValue
    })

    init(tokenCode: TokenCode, coinType: CoinType, rawChainName: String, name: String, symbol: String, decimals: Int, index: Int, icon: String, id: String, gatewayInfo: GatewayInfo? = nil) {
        self.tokenCode = tokenCode
        self.coinType = coinType
        self.rawChainName = rawChainName
        self.name = name
        self.symbol = symbol
        self.decimals = decimals
        self.index = index
        self.icon = icon
        self.id = id
        self.gatewayInfo = gatewayInfo
    }
}

extension TokenInfo: Equatable {
    public static func == (lhs: TokenInfo, rhs: TokenInfo) -> Bool {
        return lhs.tokenCode == rhs.tokenCode
    }

    var isViteCoin: Bool { return tokenCode == TokenCode.viteCoin }
    var isEtherCoin: Bool { return tokenCode == TokenCode.etherCoin }
    var isViteERC20: Bool { return tokenCode == TokenCode.viteERC20 }

    static var viteERC20ContractAddress: String {
        #if DEBUG || TEST
        return DebugService.instance.config.rpcUseOnlineUrl ? "0x1b793E49237758dBD8b752AFC9Eb4b329d5Da016" : "0x54b716345c14ba851f1b51dcc1491abee6ba8f44"
        #else
        return "0x1b793E49237758dBD8b752AFC9Eb4b329d5Da016"
        #endif
    }

    func getCoinHeaderDisplay() -> String? {
        if self.coinType == .vite {
            return R.string.localizable.tokenListPageSectionViteHeader()
        }else if self.coinType == .eth {
            return R.string.localizable.tokenListPageSectionEthHeader()
        }else if self.coinType == .grin {
            return R.string.localizable.tokenListPageSectionGrinHeader()
        }
        return ""
    }
}

extension TokenInfo {
    static var viteCoin: TokenInfo {
        return MyTokenInfosService.instance.tokenInfo(forViteTokenId: ViteWalletConst.viteToken.id)!
    }

    static var viteERC20: TokenInfo {
        return MyTokenInfosService.instance.tokenInfo(for: TokenCode.viteERC20)!
    }

    static var eth: TokenInfo {
        return MyTokenInfosService.instance.tokenInfo(for: TokenCode.etherCoin)!
    }
    static var eth000: TokenInfo {
        return MyTokenInfosService.instance.tokenInfo(for: "1352")!
    }
}

extension TokenInfo {
    func toViteToken() -> Token? {
        guard coinType == .vite else {
            return nil
        }

        return Token(id: id, name: name, symbol: symbol, decimals: decimals, index: index)
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
        } else if case .vite = coinType, !isViteCoin {
            return R.image.icon_logo_chain_vite()
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

extension TokenInfo {

    public var isGateway: Bool {
        return self.gatewayInfo != nil
    }

    public var gatewayName: String? {
        if !isGateway {
            return nil
        }
        return self.gatewayInfo?.name
    }
}

public struct GatewayInfo: Mappable {

    var name =  ""
    var url = ""
    var icon = ""
    var website = ""
    var overview = [String:String]()
    var policy = [String:String]()
    var support = ""
    var isOfficial = false

    private var mappedTokenInfo = MappedTokenInfo()


    public init?(map: Map) {

    }

    init(name: String, url: String, mappedTokenInfo: MappedTokenInfo) {
        self.name = name
        self.url = url
        self.mappedTokenInfo = mappedTokenInfo
    }

    public mutating func mapping(map: Map) {
        name <- map["name"]
        url <- map["url"]
        icon <- map["icon"]
        website <- map["website"]
        overview <- map["overview"]
        policy <- map["policy"]
        support <- map["support"]
        mappedTokenInfo <- map["mappedToken"]
        isOfficial <- map["isOfficial"]
    }


    var mappedToken: TokenInfo {
        let mapped = mappedTokenInfo
        return TokenInfo(tokenCode: mapped.tokenCode, coinType: mapped.coinType, rawChainName: mapped.rawChainName, name: mapped.name, symbol: mapped.symbol, decimals: mapped.decimals, index: mapped.index, icon: mapped.icon, id: mapped.id)
    }
}

public struct MappedTokenInfo: Mappable {

    public fileprivate(set)  var tokenCode: TokenCode = ""
    public fileprivate(set)  var name: String = ""
    public fileprivate(set)  var symbol: String = ""
    public fileprivate(set)  var coinType: CoinType = .unsupport
    public fileprivate(set)  var rawChainName: String = ""
    public fileprivate(set)  var decimals: Int = 0
    public fileprivate(set)  var index: Int = 0
    public fileprivate(set)  var icon: String = ""
    public fileprivate(set)  var id: String = ""

    public var uniqueSymbol: String {
        if case .vite = coinType {
            return Token(id: id, name: name, symbol: symbol, decimals: decimals, index: index).uniqueSymbol
        } else {
            return symbol
        }
    }

    public init?(map: Map) {

    }

    init() {

    }

    public mutating func mapping(map: Map) {
        tokenCode <- map["tokenCode"]
        name <- map["name"]
        symbol <- map["symbol"]
        coinType <- (map["platform"], coinTypeTransform)
        rawChainName <- map["platform"]
        decimals <- map["decimal"]
        index <- map["tokenIndex"]
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

    init(tokenCode: TokenCode, coinType: CoinType, rawChainName: String, name: String, symbol: String, decimals: Int, index: Int, icon: String, id: String) {
        self.tokenCode = tokenCode
        self.coinType = coinType
        self.rawChainName = rawChainName
        self.name = name
        self.symbol = symbol
        self.decimals = decimals
        self.index = index
        self.icon = icon
        self.id = id
    }

}
