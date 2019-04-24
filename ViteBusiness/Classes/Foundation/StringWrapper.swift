//
//  StringWrapper.swift
//  Vite
//
//  Created by Stone on 2018/11/6.
//  Copyright © 2018 vite labs. All rights reserved.
//

import Foundation
import ObjectMapper

public struct StringWrapper: Mappable {

    fileprivate var base: String = ""
    fileprivate var localized: [String: String] = [:]

    public init(string: String) {
        self.base = string
    }

    public init?(map: Map) { }

    mutating public func mapping(map: Map) {
        base <- map["base"]
        localized <- map["localized"]
    }

    public var string: String {
        return localized[LocalizationService.sharedInstance.currentLanguage.rawValue] ?? base
    }
}
