//
//  ViteConst.swift
//  ViteBusiness
//
//  Created by Stone on 2019/5/14.
//

import Foundation
import Vite_GrinWallet
import Web3swift

public struct ViteConst {
    public static let instance = ViteConst()

    public let tokenCode: TokenCode
    public let cos: Cos
    public let vite: Vite
    public let eth: Eth
    public let grin: Grin


    init() {

        #if DEBUG || TEST
        let currentEnv: Env
        switch DebugService.instance.config.appEnvironment {
        case .test:
            currentEnv = Env.testEnv
        case .stage:
            currentEnv = Env.stageEnv
        case .online:
//            currentEnv = Env.premainnet
            currentEnv = Env.transform(Env.premainnet)
        case .custom:
            currentEnv = Env.testEnv
        }
        #else
//        let currentEnv = Env.premainnet
        let currentEnv = Env.transform(Env.premainnet)
        #endif

        // set
        tokenCode = currentEnv.tokenCode
        cos = currentEnv.cos
        vite = currentEnv.vite
        eth = currentEnv.eth
        grin = currentEnv.grin
    }
}

public extension ViteConst {

    public struct TokenCode {
        public let viteCoin: String
        public let etherCoin: String
        public let viteERC20: String
        public let grinCoin: String
    }

    public struct Cos {
        public let config: String
        public let discover: String
    }

    public struct Vite {
        public let nodeHttp: String
        public let explorer: String
        public let growth: String
        public let x: String
        public let genesisPageUrl: String
        public let gateway: String
    }

    public struct Eth {
        public let nodeHttp: String
        public let chainType: Web3swift.Networks
        public let explorer: String
    }

    public struct Grin {
        public let nodeHttp: String
        public let apiSecret: String
        public let chainType: String
        public let x: String
    }

    public struct Env {
        public let tokenCode: TokenCode
        public let cos: Cos
        public let vite: Vite
        public let eth: Eth
        public let grin: Grin

        public static let premainnet =
            Env(tokenCode: TokenCode(viteCoin: "1171",
                                     etherCoin: "1",
                                     viteERC20: "41",
                                     grinCoin: "1174"),
                cos: Cos(config: "https://testnet-vite-1257137467.cos.ap-hongkong.myqcloud.com",
                         discover: "https://testnet-vite-1257137467.cos.ap-hongkong.myqcloud.com"),
                vite: Vite(nodeHttp: "https://api.vitewallet.com/ios",
                           explorer: "https://explorer.vite.net",
                           growth: "https://growth.vite.net",
                           x: "https://vitex.vite.net",
                           genesisPageUrl: "https://x.vite.net/balance?address=%@",
                           gateway: "https://wallet.vite.net"),
                eth: Eth(nodeHttp: "https://api.vitewallet.com/eth/v3/90d6010c57c54cee887413c4c83d1cd8",
                         chainType: .Mainnet,
                         explorer: "https://etherscan.io/address"),
                grin: Grin(nodeHttp: "https://grin.vite.net/fullnode",
                           apiSecret: "Pbwnf9nJDEVcVPR8B42u",
                           chainType: GrinChainType.mainnet.rawValue,
                           x: "https://grinx.vite.net"))

        public static let testEnv =
            Env(tokenCode: TokenCode(viteCoin: "7",
                                     etherCoin: "11",
                                     viteERC20: "14",
                                     grinCoin: "10"),
                cos: Cos(config: "https://testnet-vite-test-1257137467.cos.ap-beijing.myqcloud.com",
                         discover: "https://testnet-vite-test-1257137467.cos.ap-beijing.myqcloud.com"),
                vite: Vite(nodeHttp: "http://148.70.30.139:48132",
                           explorer: "http://132.232.134.168:8080",
                           growth: "https://growth.vite.net/test",
                           x: "http://132.232.1.165:8080",
                           genesisPageUrl: "https://x.vite.net/balance?address=%@",
                           gateway: "http://132.232.60.116:8001"),
                eth: Eth(nodeHttp: "https://api.vitewallet.com/test/eth/v3/90d6010c57c54cee887413c4c83d1cd8",
                         chainType: .Ropsten,
                         explorer: "https://ropsten.etherscan.io/address"),
                grin: Grin(nodeHttp: "http://45.40.197.46:23413",
                           apiSecret: "Hpd670q3Bar0h8V1f2Z6",
                           chainType: GrinChainType.usernet.rawValue,
                           x: "http://132.232.138.139:8081/test"))

        public static let stageEnv =
            Env(tokenCode: TokenCode(viteCoin: "1171",
                                     etherCoin: "1",
                                     viteERC20: "41",
                                     grinCoin: "1174"),
                cos: Cos(config: "https://testnet-vite-stage-1257137467.cos.ap-beijing.myqcloud.com", // stage
                         discover: "https://testnet-vite-stage-1257137467.cos.ap-beijing.myqcloud.com"), // stage
                vite: Vite(nodeHttp: "https://api.vitewallet.com/ios",
                           explorer: "https://explorer.vite.net",
                           growth: "https://growth.vite.net",
                           x: "https://vitex.vite.net",
                           genesisPageUrl: "https://x.vite.net/balance?address=%@",
                           gateway: "https://wallet.vite.net"),
                eth: Eth(nodeHttp: "https://api.vitewallet.com/eth/v3/90d6010c57c54cee887413c4c83d1cd8",
                         chainType: .Mainnet,
                         explorer: "https://etherscan.io/address"),
                grin: Grin(nodeHttp: "https://grin.vite.net/fullnode",
                           apiSecret: "Pbwnf9nJDEVcVPR8B42u",
                           chainType: GrinChainType.mainnet.rawValue,
                           x: "https://grinx.vite.net"))
    }
}


extension ViteConst.Env {

    static func transform(_ env: ViteConst.Env) -> ViteConst.Env {


        let map: [String: String] = [
            "https://explorer.vite.net": "http://132.232.134.168:8080",
            "https://grinx.vite.net": "http://129.28.98.62:8080",
            "https://vitex.vite.net": "http://132.232.1.165:8080",
        ]

        let viteExplorer = map[env.vite.explorer] ?? env.vite.explorer
        let grinX = map[env.grin.x] ?? env.grin.x
        let viteX = map[env.vite.x] ?? env.vite.x

        return ViteConst.Env(tokenCode: env.tokenCode,
                             cos: env.cos,
                             vite: ViteConst.Vite(nodeHttp: env.vite.nodeHttp,
                                                  explorer: viteExplorer,
                                                  growth: env.vite.growth,
                                                  x: viteX,
                                                  genesisPageUrl: env.vite.genesisPageUrl,
                                                  gateway: env.vite.gateway),
                             eth: env.eth,
                             grin: ViteConst.Grin(nodeHttp: env.grin.nodeHttp,
                                                  apiSecret: env.grin.apiSecret,
                                                  chainType: env.grin.chainType,
                                                  x: grinX))
    }
}
