//
//  WKWebViewJavascriptBridge.swift
//  Vite
//
//  Created by Water on 2018/10/22.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import WebKit

@available(iOS 9.0, *)
public class WKWebViewJSBridge: NSObject {
    private let iOS_Native_InjectJavascript = "iOS_Native_InjectJavascript"
    private let iOS_Native_FlushMessageQueue = "iOS_Native_FlushMessageQueue"

    private weak var webView: WKWebView?
    public weak var vc: WKWebViewController?
    private var base: WKWebViewJSBridgeEngine!
    private var publish: WKWebViewJSBridgePublish!

    public init(webView: WKWebView,vc:WKWebViewController) {
        super.init()
        self.webView = webView
        self.vc = vc
        base = WKWebViewJSBridgeEngine()
        base.delegate = self
        publish = WKWebViewJSBridgePublish(bridge: self)
        addScriptMessageHandlers()
    }

    deinit {
        removeScriptMessageHandlers()
    }

    // MARK: - Public Funcs
    public func pageOnShowAction() {
        publish.pageOnShowAction()
    }

    public func appDidBecomeActive() {
        publish.appDidBecomeActive()
    }

    public func reset() {
        base.reset()
    }

    public func register(handlerName: String, handler: @escaping WKWebViewJSBridgeEngine.Handler) {
        base.messageHandlers[handlerName] = handler
    }

    public func remove(handlerName: String) -> WKWebViewJSBridgeEngine.Handler? {
        return base.messageHandlers.removeValue(forKey: handlerName)
    }

    public func call(handlerName: String, data: Any? = nil, callback: WKWebViewJSBridgeEngine.Callback? = nil) {
        base.send(handlerName: handlerName, data: data, callback: callback)
    }

    // MARK: - Private Funcs
    private func flushMessageQueue() {
        DispatchQueue.main.async {
            self.webView?.evaluateJavaScript("WKWebViewJavascriptBridge._fetchQueue();") { (result, error) in
                if error != nil {
                    print("WKWebViewJavascriptBridge: WARNING: Error when trying to fetch data from WKWebView: \(String(describing: error))")
                }

                guard let resultStr = result as? String else { return }

                print("======= resultStr ",resultStr)


                self.base.flush(messageQueueString: resultStr, url:self.webView?.url?.absoluteString ?? "")
            }
        }
    }

    private func addScriptMessageHandlers() {
        webView?.configuration.userContentController.add(LeakAvoider(delegate: self), name: iOS_Native_InjectJavascript)
        webView?.configuration.userContentController.add(LeakAvoider(delegate: self), name: iOS_Native_FlushMessageQueue)
    }

    private func removeScriptMessageHandlers() {
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: iOS_Native_InjectJavascript)
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: iOS_Native_FlushMessageQueue)
    }
}

extension WKWebViewJSBridge: WKWebViewJSBridgeEngineDelegate {
    func evaluateJavascript(javascript: String) {
        webView?.evaluateJavaScript(javascript, completionHandler: nil)
    }

    func changeWebVCTitle(title: String) {
        self.vc?.title = title
    }

    @objc func webRRBtnClicked() {
        self.publish.setRRBtnAction()
    }

    func changeWebRRBtn(itemTitle: String?,itemImg:UIImage?){
        guard let vc = self.vc else { return }
        if let image = itemImg {
            let item = UIBarButtonItem(image: image, landscapeImagePhone: nil, style: .plain, target: self, action: #selector(webRRBtnClicked))
            vc.navigationItem.rightBarButtonItems = [item, vc.refreshItem]
        } else {
            vc.navigationItem.rightBarButtonItems = [vc.refreshItem]
        }
//
//        let btn = UIButton(type: .custom)
//        if let title = itemTitle {
//            btn.setTitleColor(UIColor(netHex: 0x3E4A59).withAlphaComponent(0.45), for: .normal)
//            btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
//            btn.titleLabel?.textAlignment = .right
//            btn.sizeToFit()
//            btn.setTitle(title, for: .normal)
//            btn.setTitle(title, for: .highlighted)
//            btn.frame = CGRect.init(x: 0, y: 0, width: 70, height: 40)
//        }
//        if let img = itemImg {
//            btn.setImage(img, for: .normal)
//            btn.setImage(img, for: .highlighted)
//            btn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
//        }
//        btn.rx.tap.asObservable().bind { [weak self] in
//            self?.publish.setRRBtnAction()
//        }
//        let btnView = UIView(frame: btn.bounds)
//        btnView.addSubview(btn)
//        let item =  UIBarButtonItem(customView: btnView)
//        self.vc?.navigationItem.rightBarButtonItem = item
    }
}

extension WKWebViewJSBridge: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == iOS_Native_InjectJavascript {
            base.injectJavascriptFile()
        }

        if message.name == iOS_Native_FlushMessageQueue {
            flushMessageQueue()
        }
    }
}

class LeakAvoider: NSObject {
    weak var delegate: WKScriptMessageHandler?

    init(delegate: WKScriptMessageHandler) {
        super.init()
        self.delegate = delegate
    }
}

extension LeakAvoider: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}
