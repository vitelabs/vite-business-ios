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
            return URL(string: "http://192.168.31.219:8082/dev")!
        } else {
            return URL(string: "http://192.168.31.219:8082/dev")!
        }
        #else
        return URL(string: "http://192.168.31.219:8082/dev")!
        #endif
    }
}
