//
//  Mnemonic.swift
//  Vite-keystore_Example
//
//  Created by Water on 2018/8/29.
//  Copyright © 2018年 Water. All rights reserved.
//

import Foundation


// https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki   Mnemonic prd
//https://iancoleman.io/bip39/  check Mnemonic by this link
public final class Mnemonic {
    //pwd strength
    public enum Strength: Int {
        case weak = 128    //12 words
        case strong = 256  //24 words
    }

    //random  create mnemonic  words
    public static func randomGenerator(strength: Strength = .weak, language: MnemonicCodeBook = .english) -> String {
        let byteCount = strength.rawValue  / 8
        let bytes = Data.randomBytes(length: byteCount)   //random create entropy
        return generator(entropy: bytes, language: language)
    }

    //create mnemonic  words  by data
    public static func generator(entropy: Data, language: MnemonicCodeBook = .english) -> String {
        precondition(entropy.count % 4 == 0 && entropy.count >= 16 && entropy.count <= 32)

        let entropybits = String(entropy.flatMap { ("00000000" + String($0, radix: 2)).suffix(8) })
        let hashBits = String(entropy.sha256().flatMap { ("00000000" + String($0, radix: 2)).suffix(8) })
        let checkSum = String(hashBits.prefix((entropy.count * 8) / 32))

        let words = language.words
        let concatenatedBits = entropybits + checkSum

        var mnemonic: [String] = []
        for index in 0..<(concatenatedBits.count / 11) {
            let startIndex = concatenatedBits.index(concatenatedBits.startIndex, offsetBy: index * 11)
            let endIndex = concatenatedBits.index(startIndex, offsetBy: 11)
            let wordIndex = Int(strtoul(String(concatenatedBits[startIndex..<endIndex]), nil, 2))

            mnemonic.append(String(words[wordIndex]))
        }

        return mnemonic.joined(separator: " ")
    }

    //mnemonic to entropy
    public static func mnemonicsToEntropy(_ mnemonics: String, language: MnemonicCodeBook = .english) -> Data? {
        let mnemonicWordsList = mnemonics.components(separatedBy: " ")
        return Bit.entropy(fromWords: mnemonicWordsList, wordLists: language.words)
    }

    //BIP39 Seed
    public static func createBIP39Seed(mnemonic: String, withPassphrase passphrase: String = "") -> Data {
        precondition(passphrase.count <= 256, "Password too long")

        //handle mnemonic
        guard let password = mnemonic.decomposedStringWithCompatibilityMapping.data(using: .utf8) else {
            fatalError("Nomalizing password failed in \(self)")
        }
        //handle password add salt
        guard let salt = ("mnemonic" + passphrase).decomposedStringWithCompatibilityMapping.data(using: .utf8) else {
            fatalError("Nomalizing salt failed in \(self)")
        }

        return Crypto.PBKDF2SHA512(password: password.bytes, salt: salt.bytes)
    }

    /// Determines if a mnemonic string is valid.
    ///
    /// - Parameter string: mnemonic string
    /// - Returns: `true` if the string is valid; `false` otherwise.
    public static func mnemonic_check(_ mnemonicStr: String) -> Bool {
        if mnemonicStr.isEmpty {
            return false
        }
        let mnemonicWordsList = mnemonicStr.components(separatedBy: " ")

        let data = Bit.entropy(fromWords: mnemonicWordsList, wordLists: MnemonicCodeBook.english.words)

        return data != nil
    }
}


