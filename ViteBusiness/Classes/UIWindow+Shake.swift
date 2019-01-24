//
//  UIWindow+Shake.swift
//  Pods
//
//  Created by Stone on 2019/1/24.
//

import UIKit
import ViteUtils

extension UIWindow {

    open override var canBecomeFocused: Bool {
        return true
    }

    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        NotificationCenter.default.post(name: .shakeGesture, object: nil, userInfo: nil)

        #if DEBUG || TEST

        guard let top = UIViewController.current else { return }

        if top is DebugViewController {
            top.dismiss(animated: true, completion: nil)
        } else if top is WKWebViewController {
            // do nothing
        } else {
            let vc = DebugViewController()
            let nav = BaseNavigationController(rootViewController: vc)
            top.present(nav, animated: true, completion: nil)
        }

        #endif
    }
}
