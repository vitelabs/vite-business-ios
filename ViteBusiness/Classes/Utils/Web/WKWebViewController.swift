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

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.addSubview(webView)
        view.addSubview(webProgressView)

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

        self.webView.load(URLRequest.init(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 100))
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    fileprivate func handleNavBar() {
        let color = UIColor(netHex: 0x3E4A59).withAlphaComponent(0.45)
        self.navigationController?.navigationBar.tintColor = color
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.color(UIColor.white), for: .default)
        let textAttributes = [
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)
        ]

        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationItem.title = self.titleStr

        if #available(iOS 11.0, *) {
            let spaceItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
            spaceItem.width = -15
            self.navigationItem.leftBarButtonItems = [spaceItem,self.backItem, self.closeItem]
        } else {
              self.navigationItem.leftBarButtonItems = [self.backItem, self.closeItem]
        }
    }

    lazy var webProgressView: UIProgressView = {
        let webProgressView = UIProgressView()
        webProgressView.sizeToFit()
        webProgressView.tintColor = UIColor.init(netHex: 0x007AFF)
        webProgressView.trackTintColor = .white
        return webProgressView
    }()

    lazy var webView: WKWebView = {
        let webView =  WKWebView(frame: CGRect(), configuration: WKWebViewConfiguration())
        webView.navigationDelegate = self as WKNavigationDelegate
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: NSKeyValueObservingOptions.new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: NSKeyValueObservingOptions.new, context: nil)
        return webView
    }()

    lazy var backItem: UIBarButtonItem = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect.init(x: -15, y: -3, width: 40, height: 40)
        btn.setImage(WKWebViewConfig.instance.backImg, for: .normal)
        btn.addTarget(self, action: #selector(goBackBtnAction), for: .touchUpInside)
        btn.backgroundColor = .clear

        let btnView = UIView(frame: btn.bounds)
        btnView.addSubview(btn)
        let backItem =  UIBarButtonItem(customView: btnView)
        return backItem
    }()

    lazy var closeItem: UIBarButtonItem = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .clear
        btn.setTitle(WKWebViewConfig.instance.closeStr, for: .normal)
        btn.addTarget(self, action: #selector(closeVCAction), for: .touchUpInside)
        btn.setTitleColor(UIColor(netHex: 0x3E4A59).withAlphaComponent(0.45), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.sizeToFit()
        btn.frame.origin = CGPoint(x: -18, y: 0)

        let btnView = UIView(frame: btn.bounds)
        btnView.addSubview(btn)
        let closeItem =   UIBarButtonItem(customView: btnView)
        return closeItem
    }()
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

    @objc func reloadWebView() {
        webView.reload()
    }

    @objc func shareWebView() {
        guard let handler =  WKWebViewConfig.instance.share else {
            return
        }
        handler(["url": self.url.absoluteString])
    }
}

extension WKWebViewController {
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("webViewDidStartLoad: \(String(describing: webView.url?.absoluteString))")
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("webViewDidFinishLoad: \(String(describing: webView.url?.absoluteString))")
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        decisionHandler(.allow)
    }
}

extension WKWebViewController {
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPathValue = keyPath, let _ = change?[NSKeyValueChangeKey.kindKey],
            ((keyPathValue == "estimatedProgress") ) {
            let newProgress = change?[NSKeyValueChangeKey.newKey] as! NSNumber
            self.webProgressView.alpha = 1.0
            self.webProgressView.setProgress(newProgress.floatValue, animated: true)

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
