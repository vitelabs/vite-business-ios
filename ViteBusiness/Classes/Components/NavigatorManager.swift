//
//  NavigatorManager.swift
//  ViteBusiness
//
//  Created by Stone on 2019/6/18.
//

import URLNavigator

public final class NavigatorManager {
    public static let instance = NavigatorManager()

    private init() {}

    @discardableResult
    public func route(url: URL) -> UIViewController? {
        #if DEBUG || TEST
        guard let vc = parse(url: testUrl(for: url)) else { return nil }
        #else
        guard let vc = parse(url: url) else { return nil }
        #endif
        UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        return vc
    }

    private func parse(url: URL) -> UIViewController? {
        // compatibility old version
        if url.absoluteString == "https://x.vite.net/walletQuota" {
            return QuotaManageViewController()
        }

        guard matchDomain(url: url) else {
            return WKWebViewController(url: url)
        }

        if url.path.hasPrefix(RouterType.webview.rawValue) {
            return WKWebViewController(url: url)
        } else if url.path.hasPrefix(RouterType.native.rawValue) {
            return NativePageType.parse(url: url)
        } else {
            return WKWebViewController(url: url)
        }
    }

    private func matchDomain(url: URL) -> Bool {
        if url.absoluteString.hasPrefix("https://app.vite.net/") ||
            url.absoluteString.hasPrefix("https://vite-wallet-test.netlify.com/") {
            return true
        } else {
            return false
        }
    }

    enum RouterType: String {
        case webview = "/webview/"
        case native = "/native_app/"
    }

    enum NativePageType: String {
        case balanceInfoDetail = "token_balance_info"

        static func parse(url: URL) -> UIViewController? {
            if url.path == RouterType.native.rawValue+NativePageType.balanceInfoDetail.rawValue {
                if let tokenCode = url.queryParameters["token_code"],
                    let address = url.queryParameters["address"],
                    HDWalletManager.instance.account?.address == address {
                    return BalanceInfoDetailViewController(tokenCode: tokenCode)
                }
            }

            return nil
        }
    }
}

#if DEBUG || TEST
extension NavigatorManager {

    struct HostPair {
        let source: String
        let target: String
    }

    func testUrl(for url: URL) -> URL {

        let hostPairs = [
            HostPair(source: "https://app.vite.net/webview/vitex_invite_inner/index.html",
                     target: "https://vite-wallet-test.netlify.com/webview/vitex_invite_inner/index.html"),
            HostPair(source: "https://app.vite.net/webview/defi_usage/index.html",
                     target: "http://192.168.31.46:8080"),
        ]

        if DebugService.instance.config.appEnvironment == .test {
            for pair in hostPairs {
                if url.absoluteString.hasPrefix(pair.source) {
                    let string = url.absoluteString.replacingOccurrences(of: pair.source, with: pair.target)
                    return URL(string: string)!
                }
            }
            return url
        } else {
            return url
        }
    }
}
#endif
