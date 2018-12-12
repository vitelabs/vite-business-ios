//
//  WordList.swift
//  Vite-keystore_Example
//
//  Created by Water on 2018/8/29.
//  Copyright © 2018年 Water. All rights reserved.
//

//https://github.com/trezor/python-mnemonic/tree/master/mnemonic/wordlist
//助记词密码本，2048个单词的字典做对应

public enum MnemonicCodeBook {
    case english
    case simplifiedChinese
    case traditionalChinese
    case japanese
    case korean
    case spanish
    case french
    case italian

    public var words: [String] {
        switch self {
            case .english:
                return englishWords
            case .japanese:
                return japaneseWords
            case .korean:
                return koreanWords
            case .spanish:
                return spanishWords
            case .simplifiedChinese:
                return simplifiedChineseWords
            case .traditionalChinese:
                return traditionalChineseWords
            case .french:
                return frenchWords
            case .italian:
                return italianWords
        }
    }
}
