//
//  ViteLanguage.swift
//  
//
//  Created by Stone on 2018/12/6.
//

import Foundation

public enum ViteLanguage: String {
    case base = "en"
    case chinese = "zh"

    // only used for local file
    public var resourceName: String {
        switch self {
        case .base:
            return "en"
        case .chinese:
            return "zh-Hans"
        }
    }

    public var name: String {
        switch self {
        case .base:
            return "English"
        case .chinese:
            return "中文"
        }
    }

    public var code: String {
        return rawValue
    }

    public static var allLanguages: [ViteLanguage] {
        return [.base, .chinese]
    }
}
