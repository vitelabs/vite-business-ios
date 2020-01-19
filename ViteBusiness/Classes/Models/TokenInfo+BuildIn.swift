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
        case vx

        case eth
        case eth_vite

        case grin

        case bnb

        var jsonString: String {
            switch self {
            case .vite:
                return "{\"symbol\":\"VITE\",\"name\":\"Vite Token\",\"tokenCode\":\"1171\",\"platform\":\"VITE\",\"tokenAddress\":\"tti_5649544520544f4b454e6e40\",\"icon\":\"https://token-profile-1257137467.cos.ap-hongkong.myqcloud.com/icon/e6dec7dfe46cb7f1c65342f511f0197c.png\",\"decimal\":18}"
            case .vite_eth_000:
                return  "{\"symbol\":\"ETH\",\"decimal\":18,\"platform\":\"VITE\",\"tokenCode\":\"1352\",\"tokenIndex\":0,\"gatewayInfo\":{\"policy\":{\"en\":\"https://x.vite.net/privacy.html\"},\"isOfficial\":true,\"mappedToken\":{\"symbol\":\"ETH\",\"decimal\":18,\"platform\":\"ETH\",\"tokenCode\":\"1\",\"tokenIndex\":null,\"tokenAddress\":null,\"name\":\"Ether\",\"icon\":\"https://token-profile-1257137467.cos.ap-hongkong.myqcloud.com/icon/887282bdefb9f3c6fc8384e56b380460.png\"},\"support\":\"gateway@vite.org\",\"url\":\"https://crosschain.vite.net/gateway/eth\",\"level\":null,\"links\":{\"website\":[\"https://vite.org\"],\"whitepaper\":[\"https://github.com/vitelabs/whitepaper/\"],\"explorer\":[\"https://explorer.vite.net\"]},\"overview\":{\"en\":\"The gateway provided by Vite Labs, running cross-chain services for four coins: BTC, ETH, USDT(ERC20)\",\"zh\":\"Vite Labs官方网关，负责BTC、ETH、USDT(ERC20)、GRIN四种代币跨链服务\"},\"name\":\"Vite Labs\",\"icon\":\"https://token-profile-1257137467.cos.ap-hongkong.myqcloud.com/icon/e6dec7dfe46cb7f1c65342f511f0197c.png\"},\"tokenAddress\":\"tti_687d8a93915393b219212c73\",\"name\":\"Ethereum\",\"icon\":\"https://token-profile-1257137467.cos.ap-hongkong.myqcloud.com/icon/887282bdefb9f3c6fc8384e56b380460.png\"}"
            case .vx:
                return "{\"symbol\":\"VX\",\"decimal\":18,\"platform\":\"VITE\",\"tokenCode\":\"1298\",\"tokenIndex\":0,\"gatewayInfo\":null,\"tokenAddress\":\"tti_564954455820434f494e69b5\",\"name\":\"ViteX Coin\",\"icon\":\"https://token-profile-1257137467.cos.ap-hongkong.myqcloud.com/icon-test/da32251cdc6b4e88963523659d705b83.png\"}"
            case .eth:
                return "{\"symbol\":\"ETH\",\"name\":\"Ether\",\"tokenCode\":\"1\",\"platform\":\"ETH\",\"tokenAddress\":null,\"icon\":\"https://token-profile-1257137467.cos.ap-hongkong.myqcloud.com/icon/887282bdefb9f3c6fc8384e56b380460.png\",\"decimal\":18}"
            case .eth_vite:
                return "{\"symbol\":\"VITE\",\"name\":\"ViteToken\",\"tokenCode\":\"41\",\"platform\":\"ETH\",\"tokenAddress\":\"0x1b793E49237758dBD8b752AFC9Eb4b329d5Da016\",\"icon\":\"https://token-profile-1257137467.cos.ap-hongkong.myqcloud.com/icon/e6dec7dfe46cb7f1c65342f511f0197c.png\",\"decimal\":18}"
            case .bnb:
                return "{  \"symbol\": \"BNB\", \"name\": \"Binance Coin\", \"tokenCode\": \"1354\", \"platform\": \"BNB\", \"tokenAddress\": \"BNB\", \"tokenIndex\": null, \"icon\": \"https://token-profile-1257137467.cos.ap-hongkong.myqcloud.com/icon-test/34f0d2f4330ccb19de5b823718c61c0e.png\", \"decimal\": 8, \"gatewayInfo\": null  }"
            case .grin:
                return "{\"symbol\":\"GRIN\",\"name\":\"Grin\",\"tokenCode\":\"1174\",\"platform\":\"GRIN\",\"tokenAddress\":null,\"tokenIndex\":null,\"icon\":\"https://token-profile-1257137467.cos.ap-hongkong.myqcloud.com/icon/6044b64442aca22b70f53a244ef6f84b.png\",\"decimal\":9,\"gatewayInfo\":null}"
            }
        }
    }
}
