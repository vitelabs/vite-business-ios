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
    case russia = "ru"
    case turkey = "tr"
    case korea = "ko"
    case vietnam = "vi"
    case spanish = "es"

    // only used for local file
    public var resourceName: String {
        switch self {
        case .base:
            return "en"
        case .chinese:
            return "zh-Hans"
        case .russia:
            return "ru-RU"
        case .turkey:
            return "tr-TR"
        case .korea:
            return "ko-KR"
        case .vietnam:
            return "vi-VN"
        case .spanish:
            return "es-ES"
        }
    }

    public var name: String {
        switch self {
        case .base:
            return "English"
        case .chinese:
            return "中文"
        case .russia:
            return "русский"
        case .turkey:
            return "Türk"
        case .korea:
            return "한국어"
        case .vietnam:
            return "Tiếng Việt"
        case .spanish:
            return "Español"
        }
    }

    public var code: String {
        return rawValue
    }

    public static var allLanguages: [ViteLanguage] {
        return [.base, .chinese, .russia, .turkey, .korea, .vietnam, .spanish]
    }
}
