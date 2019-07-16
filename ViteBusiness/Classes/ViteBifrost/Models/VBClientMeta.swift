//
//  VBClientMeta.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/10.
//

import Foundation

public struct VBClientMeta: Codable {
    public let name: String
    public let version: String
    public let versionCode: String
    public let bundleId: String
    public let platform: String
    public let language: String
}
