//
//  WKWebViewJSBridgeEngine+App.swift
//  Vite
//
//  Created by Water on 2018/10/24.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation

public extension  WKWebViewJSBridgeEngine {
    //bridgeVersion
    @objc func jsapi_bridgeVersion(parameters: [String: String], callbackID: String) {
        var response = Response(code:.success,msg: "ok",data: ["versionName":"1.0.0","versionCode":1])

        let responseData = response.toJSONString(prettyPrint: true)
        let message = ["responseID": callbackID, "responseData": responseData]
        self.sendResponds(message)
    }
    //share
    @objc func jsapi_goToshare(parameters: [String: String], callbackID: String) {
        guard let handler =  WKWebViewConfig.instance.share else {
            return
        }
        handler(parameters)
    }

    //fetch app info
    @objc func jsapi_fetchAppInfo(parameters: [String: String], callbackID: String) {
        guard let handler =  WKWebViewConfig.instance.fetchAppInfo else {
            return
        }
        let responseData = handler(parameters)?.toJSONString(prettyPrint: true)
        let message = ["responseID": callbackID, "responseData": responseData]
        self.sendResponds(message)
    }

    //fetch Language
    @objc func jsapi_fetchLanguage(parameters: [String: String], callbackID: String) {
        guard let handler =  WKWebViewConfig.instance.fetchLanguage else {
            return
        }
        let responseData = handler(parameters)?.toJSONString(prettyPrint: true)
        let message = ["responseID": callbackID, "responseData": responseData]
        self.sendResponds(message)
    }

    //setWebTitle
    @objc func jsapi_setWebTitle(parameters: [String: String], callbackID: String) {
        if let title = parameters["title"] as? String {
            self.delegate?.changeWebVCTitle(title: title)
            let responseData = WKWebViewJSBridgeEngine.parseOutputParameters(Response(code:.success,msg: "ok",data: ["title":title]))
            let message = ["responseID": callbackID, "responseData": responseData]
            self.sendResponds(message)
        }
    }
    //setRRButton
    @objc func jsapi_setRRButton(parameters: [String: String], callbackID: String) {
        if let title = parameters["title"] as? String {
            self.delegate?.changeWebRRBtn(itemTitle: title, itemImg: nil)
        }
        
        if var imgBase64Str = parameters["img"] as? String {
            if imgBase64Str.hasPrefix("data:image") {
                guard let newBase64String = imgBase64Str.components(separatedBy: ",").last else {
                    return
                }
                imgBase64Str = newBase64String
            }
            guard let imgNSData = Data(base64Encoded: imgBase64Str) else {
                return
            }
            guard let codeImage = UIImage(data: imgNSData) else {
                return
            }
            self.delegate?.changeWebRRBtn(itemTitle: nil, itemImg: codeImage)
        }

        let responseData = WKWebViewJSBridgeEngine.parseOutputParameters(Response(code:.success,msg: "ok",data: parameters))
        let message = ["responseID": callbackID, "responseData": responseData]
        self.sendResponds(message)
    }
}
