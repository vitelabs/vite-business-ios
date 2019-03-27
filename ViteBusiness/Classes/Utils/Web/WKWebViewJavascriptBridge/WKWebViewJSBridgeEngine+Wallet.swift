//
//  WKWebViewJSBridgeEngine+Transaction.swift
//  Vite
//
//  Created by Water on 2018/10/23.
//  Copyright © 2018年 vite labs. All rights reserved.
//

public extension WKWebViewJSBridgeEngine {
    @objc func jsapi_invokeUri(parameters: [String: String]?, callbackID: String) {
        guard let handler =  WKWebViewConfig.instance.invokeUri else {
            return
        }
        let callback = { (_ response: Response, _ callbackId: String) -> Void in
            let responseData = response.toJSONString(prettyPrint: true)
            let message = ["responseID": callbackId, "responseData": responseData]
            self.sendResponds(message)
        }
        handler(parameters,callbackID, callback)
    }

    @objc func jsapi_fetchViteAddress(parameters: [String: String], callbackID: String) {
        guard let handler =  WKWebViewConfig.instance.fetchViteAddress else {
            return
        }
        let callback = { (_ response: Response, _ callbackId: String) -> Void in
            let responseData = response.toJSONString(prettyPrint: true)
            let message = ["responseID": callbackId, "responseData": responseData]
            self.sendResponds(message)
        }
        handler(parameters,callbackID, callback)
    }
}
