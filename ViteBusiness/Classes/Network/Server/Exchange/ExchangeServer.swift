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
            return URL(string: "https://vitex.vite.net")!
        } else {
            return URL(string: "https://vitex.vite.net/test")!
        }
        #else
        return URL(string: "https://vitex.vite.net")!
        #endif
    }
}
