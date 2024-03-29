//
//  ViteConst.swift
//  ViteBusiness
//
//  Created by Stone on 2019/5/14.
//

import Foundation

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

    struct CrossChain {
        public struct ETH {
            public var gateway: String
            public var tokenId: String
        }
        var eth: CrossChain.ETH

    }

    struct Market {
        public var baseWebUrl: String
        public var vitexWS: String
    }


    class Env {

        public enum EnvType {
            case test
            case stage
            case premainnet
        }

        init(type: EnvType,cos:Cos,vite:Vite, crossChain: CrossChain,market: Market ) {
            self.type = type
            self.cos = cos
            self.vite = vite
            self.crossChain = crossChain
            self.market = market
        }

        public var type: EnvType
        public var cos: Cos
        public var vite: Vite
        public var crossChain: CrossChain
        public var market: Market

        public static var premainnet =
            Env(type: .premainnet,
                cos: Cos(config: "https://static.vite.net/testnet-vite-1257137467",
                         discover: "https://static.vite.net/testnet-vite-1257137467",
                         strapi: "https://config.vite.net"),
                vite: Vite(nodeHttp: "https://node.vite.net/gvite",
                           explorer: "https://vitescan.io",
                           growth: "https://growth.vite.net",
                           x: "https://api.vitex.net",
                           genesisPageUrl: "https://x.vite.net/balance?address=%@",
                           gateway: "https://gateway.vite.net",
                           exchange: "https://api.vite.net/x/sale",
                           viteXUrl: "https://x.vite.net/mobiledex",
                           pushReportConfig: "https://wallet.vite.net",
                           pushReportBussness: "https://api.vite.net",
                           snapshotChainHeightPerDay: 60 * 60 * 24),
                crossChain: CrossChain(eth: CrossChain.ETH(gateway: "http://132.232.60.116:8083",
                                                tokenId: "tti_4d3a69b12962332e8df52701")),
                 market: Market.init(baseWebUrl: "https://x.vite.net/mobiledex", vitexWS: "wss://vitex.vite.net/websocket")
        )

        public static let testEnv =
            Env(type: .test,
                cos: Cos(config: "https://static.vite.net/testnet-vite-test-1257137467",
                         discover: "https://static.vite.net/testnet-vite-test-1257137467",
                         strapi: "http://129.226.74.210:1337"),
                vite: Vite(nodeHttp: "http://148.70.30.139:48132",
                           explorer: "http://132.232.134.168:8080",
                           growth: "https://growth.vite.net/test",
                           x: "https://api.vitex.net/test",
                           genesisPageUrl: "https://x.vite.net/balance?address=%@",
                           gateway: "http://150.109.51.146:9900",
                           exchange: "http://150.109.40.169:7070/test", viteXUrl: "https://vite-wallet-test2.netlify.com/mobiledex",
                           pushReportConfig: "http://150.109.40.169:8086/test",
                           pushReportBussness: "http://150.109.40.169:8079",
                           snapshotChainHeightPerDay: 200),
                crossChain: CrossChain(eth: CrossChain.ETH(gateway: "http://132.232.60.116:8083",
                                                           tokenId: "tti_4d3a69b12962332e8df52701")),
                 market: Market.init(baseWebUrl: "https://vite-wallet-test2.netlify.com/mobiledex", vitexWS: "wss://vitex.vite.net/test/websocket")
        )

        public static let stageEnv =
            Env(type: .stage,
                cos: Cos(config: "https://static.vite.net/testnet-vite-stage-1257137467", // stage
                         discover: "https://static.vite.net/testnet-vite-stage-1257137467",// stage
                         strapi: "https://config.vite.net"),
                vite: Vite(nodeHttp: "https://node.vite.net/gvite",
                           explorer: "https://vitescan.io",
                           growth: "https://growth.vite.net",
                           x: "https://api.vitex.net",
                           genesisPageUrl: "https://x.vite.net/balance?address=%@",
                           gateway: "https://gateway.vite.net",
                           exchange: "https://api.vite.net/x/sale",
                           viteXUrl: "https://x.vite.net/mobiledex",
                           pushReportConfig: "https://wallet.vite.net",
                           pushReportBussness: "https://api.vite.net",
                           snapshotChainHeightPerDay: 60 * 60 * 24),
                crossChain: CrossChain(eth: CrossChain.ETH(gateway: "http://132.232.60.116:8083",
                                                tokenId: "tti_4d3a69b12962332e8df52701")),
                 market: Market.init(baseWebUrl: "https://x.vite.net/mobiledex", vitexWS: "wss://vitex.vite.net/websocket")
        )
    }
}
