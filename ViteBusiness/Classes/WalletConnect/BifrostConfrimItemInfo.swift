//
//  BifrostConfrimItemInfo.swift
//  ViteBusiness
//
//  Created by Stone on 2019/6/13.
//

import Foundation

struct BifrostConfrimItemInfo {

    let title: String
    let value: String
    let valueColor: UIColor?
    let backgroundColor: UIColor?

    var isUnderscored: Bool {
        return backgroundColor != nil
    }

    init(title: String, value: String, valueColor: UIColor?, backgroundColor: UIColor?) {
        self.title = title
        self.value = value
        self.valueColor = valueColor
        self.backgroundColor = backgroundColor
    }
}
