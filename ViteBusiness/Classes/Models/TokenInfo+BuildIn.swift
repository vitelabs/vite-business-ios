//
//  TokenInfo+BuildIn.swift
//  ViteBusiness
//
//  Created by Stone on 2019/9/10.
//

import Foundation

extension TokenInfo.BuildIn {
    var value: TokenInfo {
        let tokenInfo = TokenInfo(JSONString: jsonString)!
        return TokenInfoCacheService.instance.tokenInfo(for: tokenInfo.tokenCode) ?? tokenInfo
    }
}

extension TokenInfo {

    public enum BuildIn {
        case vite
        case vite_eth_000
        case vite_btc_000
        case vx

        case eth
        case eth_vite

        case grin

        var jsonString: String {
            switch self {
            case .vite:
                return "{\"symbol\":\"VITE\",\"name\":\"Vite Token\",\"tokenCode\":\"1171\",\"platform\":\"VITE\",\"tokenAddress\":\"tti_5649544520544f4b454e6e40\",\"icon\":\"https://static.vite.net/token-profile-1257137467/icon/e6dec7dfe46cb7f1c65342f511f0197c.png\",\"decimal\":18}"
            case .vite_eth_000:
                return  "{\"symbol\":\"ETH\",\"decimal\":18,\"platform\":\"VITE\",\"tokenCode\":\"1352\",\"tokenIndex\":0,\"gatewayInfo\":{\"policy\":{\"en\":\"https://x.vite.net/privacy.html\"},\"isOfficial\":true,\"mappedToken\":{\"symbol\":\"ETH\",\"decimal\":18,\"platform\":\"ETH\",\"tokenCode\":\"1\",\"tokenIndex\":null,\"tokenAddress\":null,\"name\":\"Ether\",\"icon\":\"https://static.vite.net/token-profile-1257137467/icon/887282bdefb9f3c6fc8384e56b380460.png\"},\"support\":\"gateway@vite.org\",\"url\":\"https://crosschain.vite.net/gateway/eth\",\"level\":null,\"links\":{\"website\":[\"https://vite.org\"],\"whitepaper\":[\"https://github.com/vitelabs/whitepaper/\"],\"explorer\":[\"https://vitescan.io\"]},\"overview\":{\"en\":\"The gateway provided by Vite Labs, running cross-chain services for four coins: BTC, ETH, USDT(ERC20)\",\"zh\":\"Vite Labs官方网关，负责BTC、ETH、USDT(ERC20)、GRIN四种代币跨链服务\"},\"name\":\"Vite Labs\",\"icon\":\"https://static.vite.net/token-profile-1257137467/icon/e6dec7dfe46cb7f1c65342f511f0197c.png\"},\"tokenAddress\":\"tti_687d8a93915393b219212c73\",\"name\":\"Ethereum\",\"icon\":\"https://static.vite.net/token-profile-1257137467/icon/887282bdefb9f3c6fc8384e56b380460.png\"}"
            case .vite_btc_000:
                return "{\"symbol\":\"BTC\",\"decimal\":8,\"platform\":\"VITE\",\"tokenCode\":\"1351\",\"tokenIndex\":0,\"gatewayInfo\":{\"support\":\"gateway@vite.org\",\"url\":\"https:\\/\\/crosschain.vite.net\\/gateway\\/btc\",\"serviceSupport\":\"https:\\/\\/vitex.zendesk.com\\/hc\\/en-001\\/requests\\/new\",\"policy\":{\"en\":\"https:\\/\\/x.vite.net\\/viteLabsGatePrivacy.html\"},\"overview\":{\"en\":\"The gateway provided by Vite Labs, running cross-chain services for four coins: BTC, ETH, USDT(ERC20)\",\"zh\":\"Vite Labs官方网关，负责BTC、ETH、USDT(ERC20)、GRIN四种代币跨链服务\"},\"level\":1,\"mappedToken\":{\"symbol\":\"BTC\",\"decimal\":8,\"platform\":\"BTC\",\"tokenCode\":\"3\",\"tokenIndex\":null,\"tokenAddress\":null,\"name\":\"Bitcoin\",\"icon\":\"https:\\/\\/static.vite.net/token-profile-1257137467\\/icon\\/7b04d1b14726fa3c20aa32daa946366f.png\"},\"icon\":\"https:\\/\\/static.vite.net/token-profile-1257137467\\/icon\\/f62f3868f3cbb74e5ece8d5a4723abef.png\",\"links\":{\"email\":[\"gateway@vite.org\"],\"explorer\":[\"https:\\/\\/explorer.vite.net\"],\"website\":[\"https:\\/\\/vite.org\"],\"whitepaper\":[\"https:\\/\\/github.com\\/vitelabs\\/whitepaper\\/\"]},\"isOfficial\":true,\"website\":\"https:\\/\\/vite.org\",\"name\":\"Vite Labs\"},\"tokenAddress\":\"tti_b90c9baffffc9dae58d1f33f\",\"name\":\"Bitcoin\",\"icon\":\"https:\\/\\/static.vite.net/token-profile-1257137467\\/icon\\/7b04d1b14726fa3c20aa32daa946366f.png\"}"
            case .vx:
                return "{\"symbol\":\"VX\",\"decimal\":18,\"platform\":\"VITE\",\"tokenCode\":\"1298\",\"tokenIndex\":0,\"gatewayInfo\":null,\"tokenAddress\":\"tti_564954455820434f494e69b5\",\"name\":\"ViteX Coin\",\"icon\":\"https://static.vite.net/token-profile-1257137467/icon-test/da32251cdc6b4e88963523659d705b83.png\"}"
            case .eth:
                return "{\"symbol\":\"ETH\",\"name\":\"Ether\",\"tokenCode\":\"1\",\"platform\":\"ETH\",\"tokenAddress\":null,\"icon\":\"https://static.vite.net/token-profile-1257137467/icon/887282bdefb9f3c6fc8384e56b380460.png\",\"decimal\":18}"
            case .eth_vite:
                return "{\"symbol\":\"VITE\",\"name\":\"ViteToken\",\"tokenCode\":\"41\",\"platform\":\"ETH\",\"tokenAddress\":\"0x1b793E49237758dBD8b752AFC9Eb4b329d5Da016\",\"icon\":\"https://static.vite.net/token-profile-1257137467/icon/e6dec7dfe46cb7f1c65342f511f0197c.png\",\"decimal\":18}"
            case .grin:
                return "{\"symbol\":\"GRIN\",\"name\":\"Grin\",\"tokenCode\":\"1174\",\"platform\":\"GRIN\",\"tokenAddress\":null,\"tokenIndex\":null,\"icon\":\"https://static.vite.net/token-profile-1257137467/icon/6044b64442aca22b70f53a244ef6f84b.png\",\"decimal\":9,\"gatewayInfo\":null}"
            }
        }
    }
}
