//
//  HDBip.swift
//  Vite
//
//  Created by Stone on 2018/9/7.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import CryptoSwift
import BigInt

public struct HDBip {
    public struct Key {
        var key: [UInt8]
        var chainCode: [UInt8]

        public func derive(index: UInt32) -> Key? {
            guard index >= HDBip.virstHardenedIndex else { return nil }

            var bigEndian = index.bigEndian
            let data = Data(bytes: &bigEndian, count: MemoryLayout.size(ofValue: bigEndian))
            var bytes = [UInt8](data)
            bytes = [0] + key + bytes

            let hmac = HMAC(key: chainCode, variant: .sha512)
            guard let sum = try? hmac.authenticate(bytes) else { return nil }
            return Key(key: Array(sum[0..<32]), chainCode: Array(sum[32..<64]))
        }

        public func stringPair() -> (seed: String, address: String)? {

            let addressPrefix       = "vite_"
            let addressSize         = 20
            let addressChecksumSize = 5

            let seed = key.toHexString()
            let publicKey = Ed25519.publicKey(secretKey: key)
            guard let hash = Blake2b.hash(outLength: addressSize, in: publicKey) else { return nil }
            guard let checksum = Blake2b.hash(outLength: addressChecksumSize, in: hash) else { return nil }
            let address = "\(addressPrefix)\(hash.toHexString())\(checksum.toHexString())"
            return (seed, address)

        }
    }

    static let seedModifier = Array("ed25519 blake2b seed".utf8)

    static let viteAccountPrefix = "m/44'/666666'"
    static let vitePrimaryAccountPath = "m/44'/666666'/0'"
    static let viteAccountPathFormat  = "m/44'/666666'/%d'"
    static let virstHardenedIndex     = UInt32(1 << 31) // bip 44, hardened child key mast begin with 2^32

    public static func masterKey(seed: Bytes) -> Key? {
        let hmac = HMAC(key: HDBip.seedModifier, variant: .sha512)
        guard let sum = try? hmac.authenticate(seed) else { return nil}
        return Key(key: Array(sum[0..<32]), chainCode: Array(sum[32..<64]))
    }

    public static func isValidPath(path: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: "^m(\\/[0-9]+')+$", options: .caseInsensitive) else { fatalError() }
        let matches = regex.matches(in: path, options: [], range: NSRange(location: 0, length: path.count))
        return matches.count > 0
    }

    public static func deriveForPath(path: String, seed: Bytes) -> Key? {
        guard isValidPath(path: path) else { return nil }
        var key = masterKey(seed: seed)

        let segments = path.components(separatedBy: "/")

        for segment in segments[1...] {
            guard var i = UInt32(segment.replacingOccurrences(of: "'", with: "")) else { return nil}
            i = i + virstHardenedIndex
            guard let k = key else { return nil }
            key = k.derive(index: i)
        }

        return key
    }

    public static func accountsForIndex(_ index: Int, seed: String) -> (secretKey: String, publicKey: String, address: String)? {
        let path = "\(viteAccountPrefix)/\(index)'"
        guard let k = deriveForPath(path: path, seed: seed.hex2Bytes) else { return nil }
        guard let (secretKey, address) = k.stringPair() else { return nil }
        let publicKey = Ed25519.publicKey(secretKey: k.key).toHexString()
        return (secretKey, publicKey, address)
    }
}
