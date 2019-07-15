//
//  BifrostConfirmInfo.swift
//  ViteBusiness
//
//  Created by Stone on 2019/6/13.
//

import Foundation

public struct BifrostConfirmInfo {

    public let title: String
    public let items: [BifrostConfirmItemInfo]

    public init(title: String, items: [BifrostConfirmItemInfo]) {
        self.title = title
        self.items = items
    }
}
