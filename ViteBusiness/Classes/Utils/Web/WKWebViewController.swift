//
//  WKWebViewController.swift
//  Vite
//
//  Created by Water on 2018/10/22.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

public class WKWebViewController: UIViewController, WKNavigationDelegate {
    private var bridge: WKWebViewJSBridge!
    private var url: URL!
    private var titleStr: String = ""

    public init(_ title:String="", url: URL) {
        self.url = url
        self.titleStr = title
        super.init(nibName: nil, bundle: nil)
    }

    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.removeObserver(self, forKeyPath: "title")
        webView.uiDelegate = nil
        webView.navigationDelegate = nil
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.addSubview(webView)
        view.addSubview(webProgressView)

        tipLabel.text = url.host.map { R.string.localizable.webPageHostTip($0) }
        webView.scrollView.insertSubview(tipLabel, at: 0)
        webView.scrollView.insertSubview(bgView, at: 0)
        tipLabel.snp.makeConstraints { (m) in
            m.top.equalTo(webView).offset(24)
            m.left.equalTo(webView).offset(16)
            m.right.equalTo(webView).offset(-16)
        }

        bgView.snp.makeConstraints { (m) in
            m.edges.equalTo(webView)
        }

        webProgressView.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(2)
            make.left.right.equalTo(view)
            make.top.equalTo(view.safeAreaLayoutGuideSnpTop)
        }
        webView.snp.makeConstraints { (make) -> Void in
            make.left.right.equalTo(view)
            make.top.equalTo(view.safeAreaLayoutGuideSnpTop)
            make.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom)
        }

        // setup bridge
        bridge = WKWebViewJSBridge(webView: webView,vc: self)

        self.handleNavBar()

        self.webView.load(URLRequest.init(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 100))

        NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification).bind {
            [weak self] _ in
            guard let current = UIViewController.current else { return }
            if self == current {
                self?.bridge.appDidBecomeActive()
            }
            }.disposed(by: rx.disposeBag)
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NavigationBarStyle.configStyle(.forH5, viewController: self)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tipLabel.isHidden = false
        bridge.pageOnShowAction()
    }

    fileprivate func handleNavBar() {
        NavigationBarStyle.configStyle(.forH5, viewController: self)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationItem.title = self.titleStr

        self.navigationItem.leftBarButtonItems = [self.backItem, self.closeItem]
        self.navigationItem.rightBarButtonItems = [self.shareItem, self.refreshItem]
    }

    lazy var webProgressView: UIProgressView = {
        let webProgressView = UIProgressView()
        webProgressView.sizeToFit()
        webProgressView.tintColor = UIColor.init(netHex: 0x007AFF)
        webProgressView.trackTintColor = .white
        return webProgressView
    }()

    let tipLabel = UILabel().then {
        $0.isHidden = true
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textAlignment = .center
    }

    let bgView = UIView().then {
        $0.backgroundColor = UIColor(netHex: 0xF8F8F8)
    }

    lazy var webView: WKWebView = {
        let webView =  WKWebView(frame: CGRect(), configuration: WKWebViewConfiguration())
        webView.isOpaque = false
        webView.backgroundColor = .white
        webView.scrollView.backgroundColor = .clear
        webView.navigationDelegate = self as WKNavigationDelegate
        webView.uiDelegate = self as WKUIDelegate
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: NSKeyValueObservingOptions.new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: NSKeyValueObservingOptions.new, context: nil)
        if let defalutUserAgent = UIWebView().stringByEvaluatingJavaScript(from: "navigator.userAgent") {
            webView.customUserAgent = "\(defalutUserAgent) Vite/\(String(WKWebViewJSBridge.versionCode))/Wallet/\(Bundle.main.buildNumber)/\(LocalizationService.sharedInstance.currentLanguage.rawValue)"
        }
        return webView
    }()

    lazy var shareItem: UIBarButtonItem = UIBarButtonItem(image: WKWebViewConfig.instance.shareImg, landscapeImagePhone: nil, style: .plain, target: self, action: #selector(shareWebView))


    lazy var backItem = UIBarButtonItem(image: WKWebViewConfig.instance.backImg, landscapeImagePhone: nil, style: .plain, target: self, action: #selector(goBackBtnAction))

    lazy var refreshItem = UIBarButtonItem(image: R.image.icon_nav_refresh(), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(refreshVCAction))

    lazy var closeItem = UIBarButtonItem(title: WKWebViewConfig.instance.closeStr, style: .plain, target: self, action: #selector(closeVCAction))
}

extension WKWebViewController : UIGestureRecognizerDelegate{

}

extension WKWebViewController {
    @objc func closeVCAction() {
        if let presentingViewController = presentingViewController {
            presentingViewController.dismiss(animated: true, completion: nil)
        } else {
            _ = navigationController?.popViewController(animated: true)
        }
    }

    @objc func refreshVCAction() {
        if let url = webView.url {
            webView.reload()
        } else {
            webView.load((URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 100)))
        }
    }

    @objc func goNextBtnAction() {
        webView.goForward()
    }

    @objc func goBackBtnAction() {
        if webView.canGoBack {
            webView.goBack()
        }else{
            self.closeVCAction()
        }
    }

    @objc func shareWebView() {
        guard let handler =  WKWebViewConfig.instance.share else {
            return
        }
        handler(["url": self.url.absoluteString])
    }
}

extension WKWebViewController: WKUIDelegate {
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            webView.load(navigationAction.request)
        }
        return nil
    }
}

extension WKWebViewController {
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("webViewDidStartLoad: \(String(describing: webView.url?.absoluteString))")
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("webViewDidFinishLoad: \(String(describing: webView.url?.absoluteString))")
        self.tipLabel.text = webView.url?.host.map { R.string.localizable.webPageHostTip($0) }
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
            decisionHandler(.cancel)
        } else if let url = navigationAction.request.url, let scheme = url.scheme {
            if scheme != "http" && scheme != "https" {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
}

extension WKWebViewController {
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPathValue = keyPath, let _ = change?[NSKeyValueChangeKey.kindKey],
            ((keyPathValue == "estimatedProgress") ) {
            let newProgress = change?[NSKeyValueChangeKey.newKey] as! NSNumber
            self.webProgressView.alpha = 1.0
            if newProgress.floatValue > self.webProgressView.progress {
                self.webProgressView.setProgress(newProgress.floatValue, animated: true)
            } else {
                self.webProgressView.setProgress(newProgress.floatValue, animated: false)
            }

            if newProgress.floatValue >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 1.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                    self.webProgressView.alpha = 0.0
                }, completion: {_ in
                    self.webProgressView.setProgress(0, animated: false)
                })
            }
        }else if let keyPathValue = keyPath, let _ = change?[NSKeyValueChangeKey.kindKey],
            ((keyPathValue == "title") ) {
            let title = change?[NSKeyValueChangeKey.newKey] as! String
            if self.titleStr == "" {
                self.title = title
            }
        }
    }
}

extension String {
    func vite_urlQueryDict() -> [String: String] {
        var dict = [String:String]()
        guard let queryItems = URLComponents(string: self)?.queryItems else {
            return dict
        }
        for qi in queryItems {
            let key = qi.name
            let value = qi.value
            dict[key] = value
        }
        return dict
    }
}
