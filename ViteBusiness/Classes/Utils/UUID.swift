//
//  UUID.swift
//  Action
//
//  Created by haoshenyang on 2019/1/2.
//

import Foundation
import KeychainSwift

private let key = "vite_uuid_key"
private let keychain = KeychainSwift.init(keyPrefix: "vite")

extension UUID {

    public static let stored: String = UUID.keychainStored

    public static let keychainStored: String = {
        if let uuid = keychain.get(key) {
            return uuid
        } else {
            let uuid = UUID.userDefaultStored
            keychain.set(uuid, forKey: key, withAccess: .accessibleAlways)
            return uuid
        }
    }()

    public static let userDefaultStored: String = {
        if let uuid = UserDefaults.standard.string(forKey: key) {
            return uuid
        } else {
            let uuid = NSUUID().uuidString
            UserDefaults.standard.set(uuid, forKey: key)
            UserDefaults.standard.synchronize()
            return uuid
        }
    }()
}
