//
//  GatewayServer.swift
//  ViteBusiness
//
//  Created by Stone on 2018/12/24.
//

import Foundation

public struct GatewayServer {
    public static var baseURL: URL {
        #if DEBUG || TEST
        if DebugService.instance.config.rpcUseOnlineUrl {
            return URL(string: "https://wallet.vite.net")!
        } else {
            return URL(string: "http://132.232.60.116:8000")!
        }
        #else
        return URL(string: "https://wallet.vite.net")!
        #endif
    }
}
