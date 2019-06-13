//
//  BifrostConfrimInfo.swift
//  ViteBusiness
//
//  Created by Stone on 2019/6/13.
//

import Foundation

struct BifrostConfrimInfo {

    let title: String
    let items: [BifrostConfrimItemInfo]

    init(title: String, items: [BifrostConfrimItemInfo]) {
        self.title = title
        self.items = items
    }
}
