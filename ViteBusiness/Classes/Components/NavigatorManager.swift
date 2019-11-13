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
        guard let vc = parse(url: url) else { return nil }
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
        if url.absoluteString.hasPrefix("https://app.view.net/") ||
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
