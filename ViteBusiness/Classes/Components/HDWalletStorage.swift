//
//  HDWalletStorage.swift
//  Vite
//
//  Created by Stone on 2018/10/8.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import Vite_HDWalletKit
import ObjectMapper
import CryptoSwift
import ViteWallet

extension HDWalletStorage: Storageable {
    public func getStorageConfig() -> StorageConfig {
        return StorageConfig(name: "HDWallet", path: .app)
    }
}

public final class HDWalletStorage: Mappable {
    fileprivate(set) var wallets = [Wallet]()
    fileprivate var currentWalletUuid: String?
    fileprivate var isLogin: Bool = false

    init() {
        if let storage: HDWalletStorage = readMappable() {
            self.wallets = storage.wallets
            self.currentWalletUuid = storage.currentWalletUuid
            self.isLogin = storage.isLogin
        }
    }

    public init?(map: Map) {}

    public func mapping(map: Map) {
        wallets <- map["wallets"]
        currentWalletUuid <- map["currentWalletUuid"]
        isLogin <- map["isLogin"]
    }

    var currentWallet: Wallet? {
        guard isLogin else { return nil }
        if let uuid = currentWalletUuid,
            let (_, wallet) = pri_walletAndIndexForUuid(uuid) {
            return wallet
        } else {
            return nil
        }
    }

    var currentWalletIndex: Int? {
        guard let uuid = currentWalletUuid else { return nil }
        for (index, wallet) in wallets.enumerated() where wallet.uuid == uuid {
            return index
        }

        return nil
    }
}

// MARK: - public function
extension HDWalletStorage {

    func addAddLoginWallet(uuid: String, name: String, mnemonic: String, hash: String, encryptKey: String, needRecoverAddresses: Bool, isBackedUp: Bool) -> Wallet {
        let wallet = Wallet(uuid: uuid, name: name, mnemonic: mnemonic, language: .english, encryptedKey: encryptKey, needRecoverAddresses: needRecoverAddresses, isBackedUp: isBackedUp)

        var index: Int?
        for (i, wallet) in wallets.enumerated() where wallet.hash == hash {
            index = i
        }

        if let index = index {
            wallets.remove(at: index)
            wallets.insert(wallet, at: index)
        } else {
            wallets.append(wallet)
        }

        currentWalletUuid = uuid
        isLogin = true
        pri_save()
        return wallet
    }

    func login(encryptKey: String, uuid: String? = nil) -> (Wallet, String)? {
        let uuid = uuid ?? self.currentWalletUuid ?? ""
        guard let (_, wallet) = pri_walletAndIndexForUuid(uuid) else { return nil }

        do {
            let mnemonic = try wallet.mnemonic(encryptKey: encryptKey)
            currentWalletUuid = wallet.uuid
            isLogin = true
            pri_save()
            return (wallet, mnemonic)
        } catch {
            return nil
        }
    }

    func logout() {
        isLogin = false
        pri_save()
    }

    func deleteAllWallets() {
        currentWalletUuid = nil
        isLogin = false
        wallets = [Wallet]()
        pri_save()
    }

    func updateCurrentWalletName(_ name: String) -> Wallet? {
        return pri_updateWalletForUuid(nil) { (wallet) in
            wallet.updateName(name)
        }
    }

    func updateCurrentWallet(addressIndex: Int, addressCount: Int, needRecoverAddresses: Bool? = nil) -> Wallet? {
        return pri_updateWalletForUuid(nil) { (wallet) in
            wallet.addressIndex = addressIndex
            wallet.addressCount = addressCount
            if let needRecoverAddresses = needRecoverAddresses {
                wallet.needRecoverAddresses = needRecoverAddresses
            }
        }
    }

    func updateCurrentWallet(isBackedUp: Bool? = nil, isRequireAuthentication: Bool? = nil, isAuthenticatedByBiometry: Bool? = nil, isTransferByBiometry: Bool? = nil) -> Wallet? {
        return pri_updateWalletForUuid(nil) { (wallet) in
            if let ret = isBackedUp {
                wallet.isBackedUp = ret
            }
            if let ret = isRequireAuthentication {
                wallet.isRequireAuthentication = ret
            }
            if let ret = isAuthenticatedByBiometry {
                wallet.isAuthenticatedByBiometry = ret
            }
            if let ret = isTransferByBiometry {
                wallet.isTransferByBiometry = ret
            }
        }
    }
}

// MARK: - private function
extension HDWalletStorage {

    fileprivate func pri_updateWalletForUuid(_ uuid: String? = nil, block: (inout Wallet) -> Void) -> Wallet? {
        let uuid = uuid ?? self.currentWalletUuid ?? ""
        guard let (index, w) = pri_walletAndIndexForUuid(uuid) else { return nil }
        var wallet = w
        block(&wallet)
        wallets.remove(at: index)
        wallets.insert(wallet, at: index)
        pri_save()
        return wallet
    }

    fileprivate func pri_walletAndIndexForUuid(_ uuid: String) -> (Int, Wallet)? {
        for (index, wallet) in wallets.enumerated() where wallet.uuid == uuid {
            return (index, wallet)
        }
        return nil
    }

    fileprivate func pri_save() {
        save(mappable: self)
    }
}

extension HDWalletStorage {

    public class Wallet: ViteWallet.Wallet{

        fileprivate(set) var addressIndex: Int = 0
        fileprivate(set) var addressCount: Int = 1
        fileprivate(set) var needRecoverAddresses: Bool = true

        fileprivate(set) var isBackedUp: Bool = true
        fileprivate(set) var isRequireAuthentication: Bool = false
        fileprivate(set) var isAuthenticatedByBiometry: Bool = false
        fileprivate(set) var isTransferByBiometry: Bool = false

        required init?(map: Map) {
            super.init(map: map)
        }

        public init(uuid: String,
                    name: String,
                    mnemonic: String,
                    language: MnemonicCodeBook,
                    encryptedKey: String,
                    addressIndex: Int = 0,
                    addressCount: Int = 1,
                    needRecoverAddresses: Bool = true,
                    isBackedUp: Bool,
                    isRequireAuthentication: Bool = false,
                    isAuthenticatedByBiometry: Bool = false,
                    isTransferByBiometry: Bool = false) {
            super.init(uuid: uuid, name: name, mnemonic: mnemonic, language: language, encryptedKey: encryptedKey)

            self.addressIndex = addressIndex
            self.addressCount = addressCount
            self.needRecoverAddresses = needRecoverAddresses

            self.isBackedUp = isBackedUp
            self.isRequireAuthentication = isRequireAuthentication
            self.isAuthenticatedByBiometry = isAuthenticatedByBiometry
            self.isTransferByBiometry = isTransferByBiometry
        }

        override public func mapping(map: Map) {
            super.mapping(map: map)

            addressIndex <- map["addressIndex"]
            addressCount <- map["addressCount"]
            needRecoverAddresses <- map["needRecoverAddresses"]

            isBackedUp <- map["isBackedUp"]
            isRequireAuthentication <- map["isRequireAuthentication"]
            isAuthenticatedByBiometry <- map["isAuthenticatedByBiometry"]
            isTransferByBiometry <- map["isTransferByBiometry"]
        }
    }
}
