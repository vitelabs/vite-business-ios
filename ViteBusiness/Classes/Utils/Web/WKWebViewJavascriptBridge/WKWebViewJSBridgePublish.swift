//
//  WKWebViewJSBridgePublish.swift
//  Vite
//
//  Created by Water on 2018/10/24.
//  Copyright © 2018年 vite labs. All rights reserved.
//

public class WKWebViewJSBridgePublish {
    private weak var bridge: WKWebViewJSBridge?
    private weak var observerShakeGesture: NSObjectProtocol?

    init(bridge: WKWebViewJSBridge) {
        self.bridge = bridge
        self.initBinds()
    }

    fileprivate func initBinds() {
        observerShakeGesture = NotificationCenter.default.addObserver(forName: Notification.Name.shakeGesture, object: nil, queue: nil) { [weak self](_) in
            self?.bridge?.call(handlerName: "shakeGesture", data: "") {  (_) in
            }
        }
    }

    public func setRRBtnAction() {
        self.bridge?.call(handlerName: "nav.RRBtnClick", data: "") {  (_) in
        }
    }

    public func pageOnShowAction() {
        self.bridge?.call(handlerName: "page.onShow", data: "") {  (_) in
        }
    }

    public func appDidBecomeActive() {
         self.bridge?.call(handlerName: "page.onShow", data: ["reason": "appDidBecomeActive"]) {  (_) in
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(observerShakeGesture!)
    }
}

extension Notification.Name {
    public static let shakeGesture = NSNotification.Name(rawValue: "net.vite.shake.gesture")
}
