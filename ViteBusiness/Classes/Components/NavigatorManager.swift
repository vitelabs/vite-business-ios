//
//  NavigatorManager.swift
//  ViteBusiness
//
//  Created by Stone on 2019/6/18.
//

import URLNavigator

public final class NavigatorManager: Navigator {
    public static let instance = NavigatorManager()

    private override init() {
        super.init()
        NavigationMap.initialize(navigator: self)
    }
}

private enum NavigationMap {

    enum Page: String {
        case pledge = "/walletQuota"
    }

    static let host = "x.vite.net"

    static func initialize(navigator: NavigatorType) {
        navigator.register("https://<path:_>") { url, values, context in
            guard let url = url.urlValue else { return nil }
            if url.host == host {
                if let page = Page(rawValue: url.path) {
                    switch page {
                    case .pledge:
                        return QuotaManageViewController()
                    }
                } else {
                    return WKWebViewController(url: url)
                }
            } else {
                return WKWebViewController(url: url)
            }
        }

        navigator.register("http://<path:_>") { url, values, context in
            guard let url = url.urlValue else { return nil }
            return WKWebViewController(url: url)
        }
    }
}


