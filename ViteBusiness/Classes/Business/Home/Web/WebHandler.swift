//
//  WebHandler.swift
//  Vite
//
//  Created by Stone on 2018/9/11.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit

public struct WebHandler {

    fileprivate static let browserUrlString = ViteConst.instance.vite.explorer

    static func open(_ url: URL) {
        let webvc = WKWebViewController(url: url)
        UIViewController.current?.navigationController?.pushViewController(webvc, animated: true)
    }

    static func openTranscationDetailPage(hash: String) {
        let host = appendLanguagePath(urlString: browserUrlString)
        guard let string = hash.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else { return }
        guard let url = URL(string: "\(host)/transaction/\(string)") else { return }
        open(url)
    }

    static func openTranscationGenesisPage(hash: String) {
        let host = appendLanguagePath(urlString: browserUrlString)
        guard let string = hash.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else { return }
        guard let url = URL(string: "\(host)/transaction/\(string)") else { return }
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
                      "language": LocalizationService.sharedInstance.currentLanguage.rawValue]

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
