//
//  ViteConst.swift
//  ViteBusiness
//
//  Created by Stone on 2019/5/14.
//

import Foundation
import Vite_GrinWallet
import web3swift

public struct ViteConst {
    public static let instance = ViteConst()

    public var envType: Env.EnvType {
        return currentEnv.type
    }

    public var cos: Cos {
        return currentEnv.cos
    }

    public var vite: Vite {
        return currentEnv.vite
    }

    public var eth: Eth {
        return currentEnv.eth
    }

    public var grin: Grin {
        return currentEnv.grin
    }


    public var crossChain: CrossChain {
        return currentEnv.crossChain
    }

    public var market: Market {
        return currentEnv.market
    }


    public let currentEnv: Env = {
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
        return currentEnv
    }()


    init() { }
}

public extension ViteConst {

    struct TokenCode {
        public let viteCoin: String
        public let etherCoin: String
        public let viteERC20: String
        public let grinCoin: String
        public let bnbCoin: String
    }

    struct Cos {
        public var config: String
        public var discover: String
        public var strapi: String
    }

    struct Vite {
        public var nodeHttp: String
        public var explorer: String
        public var growth: String
        public var x: String
        public var genesisPageUrl: String
        public var gateway: String
        public var exchange: String
        public var viteXUrl: String
        public var pushReportConfig: String
        public var pushReportBussness: String
        public var snapshotChainHeightPerDay: UInt64

    }

    struct Eth {
        public var nodeHttp: String
        public var chainType: web3swift.Networks
        public var explorer: String
        public var api: String
    }

    struct Grin {
        public var nodeHttp: String
        public var apiSecret: String
        public var chainType: String
        public var x: String
    }

    struct CrossChain {
        public struct ETH {
            public var gateway: String
            public var tokenId: String
        }
        var eth: CrossChain.ETH

    }

    struct Market {
        public var baseWebUrl: String
        public var vitexHost: String
        public var vitexWS: String
    }


    class Env {

        public enum EnvType {
            case test
            case stage
            case premainnet
        }

        init(type: EnvType,cos:Cos,vite:Vite,eth:Eth,grin:Grin, crossChain: CrossChain,market: Market ) {
            self.type = type
            self.cos = cos
            self.vite = vite
            self.eth = eth
            self.grin = grin
            self.crossChain = crossChain
            self.market = market
        }

        public var type: EnvType
        public var cos: Cos
        public var vite: Vite
        public var eth: Eth
        public var grin: Grin
        public var crossChain: CrossChain
        public var market: Market

        public static var premainnet =
            Env(type: .premainnet,
                cos: Cos(config: "https://testnet-vite-1257137467.cos.ap-hongkong.myqcloud.com",
                         discover: "https://testnet-vite-1257137467.cos.ap-hongkong.myqcloud.com",
                         strapi: "https://wallet-config.vitewallet.com"),
                vite: Vite(nodeHttp: "https://api.vitewallet.com/ios",
                           explorer: "https://explorer.vite.net",
                           growth: "https://growth.vite.net",
                           x: "https://vitex.vite.net",
                           genesisPageUrl: "https://x.vite.net/balance?address=%@",
                           gateway: "https://wallet.vite.net",
                           exchange: "https://buycoin.vitewallet.com",
                           viteXUrl: "https://x.vite.net/mobiledex",
                           pushReportConfig: "https://wallet.vite.net",
                           pushReportBussness: "https://wallet.vite.net",
                           snapshotChainHeightPerDay: 60 * 60 * 24),
                eth: Eth(nodeHttp: "https://api.vitewallet.com/eth",
                         chainType: .Mainnet,
                         explorer: "https://etherscan.io",
                         api: "https://api.vitewallet.com/etherscan"),
                grin: Grin(nodeHttp: "http://grin-v3.vite.net/fullnode",
                           apiSecret: "Pbwnf9nJDEVcVPR8B42u",
                           chainType: GrinChainType.mainnet.rawValue,
                           x: "https://grinx.vite.net"),
                crossChain: CrossChain(eth: CrossChain.ETH(gateway: "http://132.232.60.116:8083",
                                                tokenId: "tti_4d3a69b12962332e8df52701")),
                 market: Market.init(baseWebUrl: "https://x.vite.net/mobiledex", vitexHost: "https://vitex.vite.net", vitexWS: "wss://vitex.vite.net/websocket")
        )

        public static let testEnv =
            Env(type: .test,
                cos: Cos(config: "https://testnet-vite-test-1257137467.cos.ap-beijing.myqcloud.com",
                         discover: "https://testnet-vite-test-1257137467.cos.ap-beijing.myqcloud.com",
                         strapi: "http://129.226.74.210:1337"),
                vite: Vite(nodeHttp: "http://148.70.30.139:48132",
                           explorer: "http://132.232.134.168:8080",
                           growth: "https://growth.vite.net/test",
                           x: "https://vitex.vite.net/test",
                           genesisPageUrl: "https://x.vite.net/balance?address=%@",
                           gateway: "http://132.232.60.116:8001",
                           exchange: "http://150.109.40.169:7070/test", viteXUrl: "https://vite-wallet-test2.netlify.com/mobiledex",
                           pushReportConfig: "http://150.109.40.169:8086/test",
                           pushReportBussness: "http://150.109.40.169:8079",
                           snapshotChainHeightPerDay: 200),
                eth: Eth(nodeHttp: "https://ropsten.infura.io/v3/44210a42716641f6a7c729313322929e",
                         chainType: .Ropsten,
                         explorer: "https://ropsten.etherscan.io",
                         api: "https://api.vitewallet.com/beta/etherscan"),
                grin: Grin(nodeHttp: "http://grin-v3.vite.net/fullnode",
                           apiSecret: "Pbwnf9nJDEVcVPR8B42u",
                           chainType: GrinChainType.usernet.rawValue,
                           x: "http://129.28.98.62:8080"),
                crossChain: CrossChain(eth: CrossChain.ETH(gateway: "http://132.232.60.116:8083",
                                                           tokenId: "tti_4d3a69b12962332e8df52701")),
                 market: Market.init(baseWebUrl: "https://vite-wallet-test2.netlify.com/mobiledex", vitexHost: "https://vitex.vite.net/test", vitexWS: "wss://vitex.vite.net/test/websocket")
        )

        public static let stageEnv =
            Env(type: .stage,
                cos: Cos(config: "https://testnet-vite-stage-1257137467.cos.ap-beijing.myqcloud.com", // stage
                         discover: "https://testnet-vite-stage-1257137467.cos.ap-beijing.myqcloud.com",// stage
                         strapi: "https://wallet-config.vitewallet.com"),
                vite: Vite(nodeHttp: "https://api.vitewallet.com/ios",
                           explorer: "https://explorer.vite.net",
                           growth: "https://growth.vite.net",
                           x: "https://vitex.vite.net",
                           genesisPageUrl: "https://x.vite.net/balance?address=%@",
                           gateway: "https://wallet.vite.net",
                           exchange: "https://buycoin.vitewallet.com",
                           viteXUrl: "https://x.vite.net/mobiledex",
                           pushReportConfig: "https://wallet.vite.net",
                           pushReportBussness: "https://wallet.vite.net",
                           snapshotChainHeightPerDay: 60 * 60 * 24),
                eth: Eth(nodeHttp: "https://api.vitewallet.com/eth",
                         chainType: .Mainnet,
                         explorer: "https://etherscan.io",
                         api: "https://api.vitewallet.com/etherscan"),
                grin: Grin(nodeHttp: "http://grin-v3.vite.net/fullnode",
                           apiSecret: "Pbwnf9nJDEVcVPR8B42u",
                           chainType: GrinChainType.mainnet.rawValue,
                           x: "https://grinx.vite.net"),
                crossChain: CrossChain(eth: CrossChain.ETH(gateway: "http://132.232.60.116:8083",
                                                           tokenId: "tti_4d3a69b12962332e8df52701")),
               market: Market.init(baseWebUrl: "https://x.vite.net/mobiledex", vitexHost: "https://vitex.vite.net", vitexWS: "wss://vitex.vite.net/websocket")
        )
    }
}
