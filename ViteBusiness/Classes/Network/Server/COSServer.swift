//
//  COSServer.swift
//  ViteBusiness
//
//  Created by Stone on 2018/12/24.
//

import Foundation

public struct COSServer {
    public static var baseURL: URL {
        #if DEBUG || TEST
        return DebugService.instance.config.configEnvironment.url
        #else
        return URL(string: "https://testnet-vite-1257137467.cos.ap-hongkong.myqcloud.com")!
        #endif
    }
}
