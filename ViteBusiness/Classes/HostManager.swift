//
//  HostManager.swift
//  Action
//
//  Created by haoshenyang on 2019/11/4.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

class HostManager {

    static var success = false
    static var failed0 = false
    static var failed1 = false

    static func fetchAndConfigHostInfo() {

        func tryAgain() {
            if HostManager.failed0 && HostManager.failed1 {
                HostManager.failed0 = false
                HostManager.failed1 = false
                GCD.delay(8) { HostManager.fetchAndConfigHostInfo() }
            }
        }

        Alamofire.request("https://config.zaokaidian.com/dns/hostips")
            .responseJSON()
            .done { (json, resp) in
                if HostManager.success { return }
                HostManager.success = true
                HostManager.handleData(json)
            }
            .catch { (error) in
                HostManager.failed0 = true
                if HostManager.success { return }
                tryAgain()
            }

        Alamofire.request("https://config.vitewallet.com/dns/hostips")
            .responseJSON()
            .done { (json, resp) in
                if HostManager.success { return }
                HostManager.success = true
                HostManager.handleData(json)
            }
            .catch { (error) in
                HostManager.failed1 = true
                if HostManager.success { return }
                tryAgain()
            }
    }

    static func handleData(_ json: Any) {
        let data = JSON(json)["data"]

        do {
            if let ethNode = data["ETH_NODE"]["hostNameList"].array?.first?.string,
                let _ = URL.init(string:ethNode) {
                ViteConst.Env.premainnet.eth.nodeHttp = ethNode
            }
            if let walletApi = data["WALLETAPI"]["hostNameList"].array?.first?.string,
                let _ = URL.init(string:walletApi) {
                ViteConst.Env.premainnet.vite.nodeHttp = walletApi
            }
            ViteBusinessLanucher.instance.configProvider()
        }

        if let dexApi = data["VITEX_API"]["hostNameList"].array?.first?.string,
            let _ = URL.init(string:dexApi) {
            ViteConst.Env.premainnet.vite.x = dexApi
        }

        if let wss = data["DEXPUSHSERVER"]["hostNameList"].array?.first?.string,
            let _ = URL.init(string:wss) {
            ViteConst.Env.premainnet.market.vitexWS = wss
            MarketInfoService.shared.marketSocket.reStart()
        }

        if let discover = data["DISCOVERYPAGE"]["hostNameList"].array?.first?.string,
            let _ = URL.init(string:discover) {
            ViteConst.Env.premainnet.cos.discover = discover
        }

        if let walletConfig = data["WALLETCONFIG"]["hostNameList"].array?.first?.string,
            let _ = URL.init(string:walletConfig) {
            ViteConst.Env.premainnet.cos.config = walletConfig
        }

        if let wallet_config = data["WALLET_CONFIG_NEW"]["hostNameList"].array?.first?.string,
            let _ = URL.init(string:wallet_config) {
            ViteConst.Env.premainnet.cos.strapi = wallet_config
        }

        if let grinWalletAPI = data["GRIN_WALLET_HTTP"]["hostNameList"].array?.first?.string,
            let _ = URL.init(string:grinWalletAPI) {
            ViteConst.Env.premainnet.grin.x = grinWalletAPI
        }

        if let viteGateWay = data["GATEWAY"]["hostNameList"].array?.first?.string,
            let _ = URL.init(string:viteGateWay) {
            ViteConst.Env.premainnet.vite.gateway = viteGateWay
        }

        if let ethExplorer = data["ETH_EXPLORER"]["hostNameList"].array?.first?.string,
            let _ = URL.init(string:ethExplorer) {
            ViteConst.Env.premainnet.eth.explorer = ethExplorer
        }

        if let mVitex = data["MVITEX"]["hostNameList"].array?.first?.string,
            let _ = URL.init(string:mVitex) {
            ViteConst.Env.premainnet.vite.viteXUrl = mVitex
            ViteConst.Env.premainnet.market.baseWebUrl = mVitex
        }

        if let explorer = data["EXPLORER"]["hostNameList"].array?.first?.string,
            let _ = URL.init(string:explorer) {
            ViteConst.Env.premainnet.vite.explorer = explorer
        }

        if let growth = data["GROWTH"]["hostNameList"].array?.first?.string,
            let _ = URL.init(string:growth) {
            ViteConst.Env.premainnet.vite.growth = growth
        }

        if let buyCoin = data["BUYCOIN"]["hostNameList"].array?.first?.string,
            let _ = URL.init(string:buyCoin) {
            ViteConst.Env.premainnet.vite.exchange = buyCoin
        }

        let urlStrings = data.dictionaryObject?.values.reduce([String](), { (result, value) -> [String] in
            var r = result
            if JSON(value)["inWhite"].bool == true {
                r.append(contentsOf: JSON(value)["hostNameList"].arrayObject as? [String] ?? [])
            }
            return r
        }) ?? []

        let whiteList = urlStrings.compactMap { URL(string: $0)?.host }

        AppConfigService.instance.addToWhiteList(list: whiteList)
    }

}


