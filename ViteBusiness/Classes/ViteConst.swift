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
    public let crossChain: CrossChain


    init() {

        #if DEBUG || TEST
        let currentEnv: Env
        switch DebugService.instance.config.appEnvironment {
        case .test:
            currentEnv = Env.testEnv
        case .stage:
            currentEnv = Env.stageEnv
        case .online:
            currentEnv = Env.premainnet
        case .custom:
            currentEnv = Env.testEnv
        }
        #else
        let currentEnv = Env.premainnet
        #endif

        // set
        tokenCode = currentEnv.tokenCode
        cos = currentEnv.cos
        vite = currentEnv.vite
        eth = currentEnv.eth
        grin = currentEnv.grin
        crossChain = currentEnv.crossChain
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
        public let exchange: String

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

    public struct CrossChain {
        public struct ETH {
            public let gateway: String
            public let tokenId: String
        }
        let eth: CrossChain.ETH

    }

    public struct Env {
        public let tokenCode: TokenCode
        public let cos: Cos
        public let vite: Vite
        public let eth: Eth
        public let grin: Grin
        public let crossChain: CrossChain

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
                           gateway: "https://wallet.vite.net",
                           exchange: "http://150.109.40.169:7070/test"),
                eth: Eth(nodeHttp: "https://api.vitewallet.com/eth/v3/90d6010c57c54cee887413c4c83d1cd8",
                         chainType: .Mainnet,
                         explorer: "https://etherscan.io"),
                grin: Grin(nodeHttp: "https://grin.vite.net/fullnode",
                           apiSecret: "Pbwnf9nJDEVcVPR8B42u",
                           chainType: GrinChainType.mainnet.rawValue,
                           x: "https://grinx.vite.net"),
                crossChain: CrossChain(eth: CrossChain.ETH(gateway: "http://132.232.60.116:8083",
                                                tokenId: "tti_4d3a69b12962332e8df52701"))
        )

        public static let testEnv =
            Env(tokenCode: TokenCode(viteCoin: "1171",
                                     etherCoin: "1",
                                     viteERC20: "41",
                                     grinCoin: "1174"),
                cos: Cos(config: "https://testnet-vite-test-1257137467.cos.ap-beijing.myqcloud.com",
                         discover: "https://testnet-vite-test-1257137467.cos.ap-beijing.myqcloud.com"),
                vite: Vite(nodeHttp: "http://148.70.30.139:48132",
                           explorer: "http://132.232.134.168:8080",
                           growth: "https://growth.vite.net/test",
                           x: "http://132.232.65.121:8080/test",
                           genesisPageUrl: "https://x.vite.net/balance?address=%@",
                           gateway: "http://132.232.60.116:8001",
                           exchange: "http://150.109.40.169:7070/test"),
                eth: Eth(nodeHttp: "https://ropsten.infura.io/v3/44210a42716641f6a7c729313322929e",
                         chainType: .Ropsten,
                         explorer: "https://ropsten.etherscan.io"),
                grin: Grin(nodeHttp: "https://grin.vite.net/fullnode",
                           apiSecret: "Pbwnf9nJDEVcVPR8B42u",
                           chainType: GrinChainType.usernet.rawValue,
                           x: "http://129.28.98.62:8080"),
                crossChain: CrossChain(eth: CrossChain.ETH(gateway: "http://132.232.60.116:8083",
                                                           tokenId: "tti_4d3a69b12962332e8df52701"))
        )

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
                           gateway: "https://wallet.vite.net",
                           exchange: "http://150.109.40.169:7070/test"),
                eth: Eth(nodeHttp: "https://api.vitewallet.com/eth/v3/90d6010c57c54cee887413c4c83d1cd8",
                         chainType: .Mainnet,
                         explorer: "https://etherscan.io"),
                grin: Grin(nodeHttp: "https://grin.vite.net/fullnode",
                           apiSecret: "Pbwnf9nJDEVcVPR8B42u",
                           chainType: GrinChainType.mainnet.rawValue,
                           x: "https://grinx.vite.net"),
                crossChain: CrossChain(eth: CrossChain.ETH(gateway: "http://132.232.60.116:8083",
                                                           tokenId: "tti_4d3a69b12962332e8df52701"))
        )
    }
}
