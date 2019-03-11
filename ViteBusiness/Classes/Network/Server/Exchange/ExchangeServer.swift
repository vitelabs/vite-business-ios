//
//  COSServer.swift
//  ViteBusiness
//
//  Created by Stone on 2018/12/24.
//

import Foundation

public struct ExchangeServer {
    public static var baseURL: URL {
        #if DEBUG || TEST
        if DebugService.instance.config.rpcUseOnlineUrl {
            return URL(string: "http://132.232.65.121:8080/test")!
        } else {
            return URL(string: "http://132.232.65.121:8080/test")!
        }
        #else
        return URL(string: "http://132.232.65.121:8080/test")!
        #endif
    }
}
