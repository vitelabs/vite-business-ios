//
//  ViteLanguage.swift
//  
//
//  Created by Stone on 2018/12/6.
//

import Foundation

public enum ViteLanguage: String {
    case base = "en"
    case chinese = "zh-Hans"

    public var name: String {
        switch self {
        case .base:
            return "English"
        case .chinese:
            return "中文"
        }
    }

    public var languageCode: String {
        switch self {
        case .base:
            return "en"
        case .chinese:
            return "zh"
        }
    }

    public static var allLanguages: [ViteLanguage] {
        return [.base, .chinese]
    }
}
