//
//  BifrostConfrimInfo.swift
//  ViteBusiness
//
//  Created by Stone on 2019/6/13.
//

import Foundation

public struct BifrostConfrimInfo {

    public let title: String
    public let items: [BifrostConfrimItemInfo]

    public init(title: String, items: [BifrostConfrimItemInfo]) {
        self.title = title
        self.items = items
    }
}
