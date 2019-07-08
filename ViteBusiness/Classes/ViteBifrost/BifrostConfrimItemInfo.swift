//
//  BifrostConfrimItemInfo.swift
//  ViteBusiness
//
//  Created by Stone on 2019/6/13.
//

import Foundation

public struct BifrostConfrimItemInfo {

    public let title: String
    public let text: String
    public let textColor: UIColor?
    public let backgroundColor: UIColor?

    public var isUnderscored: Bool {
        return backgroundColor != nil
    }

    public init(title: String, text: String, textColor: UIColor? = nil, backgroundColor: UIColor? = nil) {
        self.title = title
        self.text = text
        self.textColor = textColor
        self.backgroundColor = backgroundColor
    }
}
