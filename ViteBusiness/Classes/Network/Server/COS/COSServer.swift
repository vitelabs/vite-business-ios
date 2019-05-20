//
//  COSServer.swift
//  ViteBusiness
//
//  Created by Stone on 2018/12/24.
//

import Foundation

public struct COSServer {
    public static var baseURL: URL {
        return URL(string: ViteConst.instance.cos.config)!
    }
}
