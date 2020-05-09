//
//  WebHandler.swift
//  Vite
//
//  Created by Stone on 2018/9/11.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import ViteWallet

public struct WebHandler {

    fileprivate static let browserUrlString = ViteConst.instance.vite.explorer

    static func open(_ url: URL) {
        let webvc = WKWebViewController(url: url)
        UIViewController.current?.navigationController?.pushViewController(webvc, animated: true)
    }

    static func open(_ urlString: String) {
        guard let url = URL.init(string: urlString) else {
            return
        }
        self.open(url)
    }

    static func openMarketMining() {
        var url = ViteConst.instance.market.baseWebUrl + "#/mining?activeTab=mining&hideSelectTab=true"
        url = url  + "&address=" + (HDWalletManager.instance.account?.address ?? "")
        url = url   + "&currency=" + AppSettingsService.instance.appSettings.currency.rawValue
        url = url   + "&lang=" + LocalizationService.sharedInstance.currentLanguage.rawValue
        NavigatorManager.instance.route(url: URL(string: url)!)
    }

    static func openMarketDividend() {
        var url = ViteConst.instance.market.baseWebUrl + "#/mining?activeTab=dividend&hideSelectTab=true"
        url = url  + "&address=" + (HDWalletManager.instance.account?.address ?? "")
        url = url   + "&currency=" + AppSettingsService.instance.appSettings.currency.rawValue
        url = url   + "&lang=" + LocalizationService.sharedInstance.currentLanguage.rawValue
        NavigatorManager.instance.route(url: URL(string: url)!)
    }

    static func openMarketHistoryOrders() {
        var url = ViteConst.instance.market.baseWebUrl + "#/order?activeTab=historyOrders&hideSelectTab=true"
        url = url  + "&address=" + (HDWalletManager.instance.account?.address ?? "")
        url = url   + "&currency=" + AppSettingsService.instance.appSettings.currency.rawValue
        url = url   + "&lang=" + LocalizationService.sharedInstance.currentLanguage.rawValue
        NavigatorManager.instance.route(url: URL(string: url)!)
    }

    static func openAddressDetailPage(address: ViteAddress) {
        let host = appendLanguagePath(urlString: browserUrlString)
        guard let string = address.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else { return }
        guard let url = URL(string: "\(host)/account/\(string)") else { return }
        open(url)
    }

    static func openTranscationDetailPage(hash: String) {
        let host = appendLanguagePath(urlString: browserUrlString)
        guard let string = hash.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else { return }
        guard let url = URL(string: "\(host)/transaction/\(string)") else { return }
        open(url)
    }

    static func openTranscationGenesisPage(address: String) {
        let urlString = NSString(format: ViteConst.instance.vite.genesisPageUrl as NSString, address)
        guard let url = URL(string: urlString as String) else { return }
        open(url)
    }

    static func openSBPDetailPage(name: String) {
        let host = appendLanguagePath(urlString: browserUrlString)
        guard let string = name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else { return }
        guard let url = URL(string: "\(host)/SBPDetail/\(string)") else { return }
        open(url)
    }

    fileprivate static func appendLanguagePath(urlString: String) -> String {
        if LocalizationService.sharedInstance.currentLanguage == .chinese {
            return "\(urlString)/zh"
        } else {
            return urlString
        }
    }

    fileprivate static func appendQuery(urlString: String) -> String {
        let querys = ["version": Bundle.main.versionNumber,
                      "channel": Constants.appDownloadChannel.rawValue,
                      "address": HDWalletManager.instance.account?.address ?? "",
                      "language": LocalizationService.sharedInstance.currentLanguage.code]

        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

        let array = urlString.split(separator: "#")
        guard array.isEmpty == false else { return urlString }
        var string = String(array[0])

        for (key, value) in querys {
            let separator = string.contains("?") ? "&" : "?"
            string = string.appending(separator)
            string = string.appending(key.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? "")
            string = string.appending("=")
            string = string.appending(value.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? "")
        }

        if array.count > 1 {
            let fragment = String(array[1])
            string.append("#")
            string.append(fragment)
        }
        return string
    }

    public static func appendQuery(url: URL) -> URL {
        if let new = URL(string: appendQuery(urlString: url.absoluteString)) {
            return new
        } else {
            return url
        }
    }
}
