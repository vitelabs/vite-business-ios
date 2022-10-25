//
//  HDWalletManager.swift
//  Vite
//
//  Created by Stone on 2018/9/16.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import ViteWallet
import Vite_HDWalletKit
import ObjectMapper
import RxSwift
import RxCocoa
import CryptoSwift


public final class HDWalletManager {
    public static let instance = HDWalletManager()

    private let disposeBag = DisposeBag()
    private init() {

        walletBehaviorRelay.asDriver().drive(onNext: { [weak self] w in
            guard let `self` = self else { return }
            if let wallet = w {
                let accounts = (0..<wallet.addressCount).map { try? wallet.account(at: $0, encryptedKey: self.encryptedKey ?? "") }.compactMap { $0 }
                guard self.accountsBehaviorRelay.value.count != accounts.count else { return }
                self.accountsBehaviorRelay.accept(accounts)
            } else {
                guard self.accountsBehaviorRelay.value.count != 0 else { return }
                self.accountsBehaviorRelay.accept([Wallet.Account]())
            }
        }).disposed(by: disposeBag)

        walletBehaviorRelay.asDriver().map {
            $0?.addressIndex
        }.drive(onNext: { [weak self] addressIndex in
            guard let `self` = self else { return }
            if let index = addressIndex {
                let account = self.accountsBehaviorRelay.value[index]
                guard self.accountBehaviorRelay.value?.address != account.address else { return }
                self.accountBehaviorRelay.accept(account)
            } else {
                guard self.accountBehaviorRelay.value != nil else { return }
                self.accountBehaviorRelay.accept(nil)
            }
        }).disposed(by: disposeBag)
    }

    public lazy var walletDriver: Driver<HDWalletStorage.Wallet?> = self.walletBehaviorRelay.asDriver()
    public lazy var accountsDriver: Driver<[Wallet.Account]> = self.accountsBehaviorRelay.asDriver()
    public lazy var accountDriver: Driver<Wallet.Account?> = self.accountBehaviorRelay.asDriver()

    public var walletBehaviorRelay: BehaviorRelay<HDWalletStorage.Wallet?> = BehaviorRelay(value: nil)
    public var accountsBehaviorRelay = BehaviorRelay(value: [Wallet.Account]())
    public var accountBehaviorRelay: BehaviorRelay<Wallet.Account?> = BehaviorRelay(value: nil)

    fileprivate let storage = HDWalletStorage()
    fileprivate(set) var mnemonic: String?
    fileprivate(set) var language: MnemonicCodeBook?
    public fileprivate(set) var encryptedKey: String?

    public internal(set) var locked = false

    fileprivate static let maxAddressCount = 100
    
    func changePassword(old: String, new: String, completion: @escaping (Bool) -> ()) {
        DispatchQueue.main.async {
            HUD.show()
            DispatchQueue.global().async {
                guard let uuid = self.storage.currentWallet?.uuid else { fatalError() }
                let oldEncryptKey = old.toEncryptKey(salt: uuid)
                let newEncryptKey = new.toEncryptKey(salt: uuid)
                
                do {
                    let wallet = try self.storage.updateCurrentWalletPassword(oldEncryptKey: oldEncryptKey, newEncryptKey: newEncryptKey)
                    self.encryptedKey = newEncryptKey
                    KeychainService.instance.setCurrentWallet(uuid: uuid, encryptKey: newEncryptKey)
                    DispatchQueue.main.async {
                        HUD.hide()
                        completion(true)
                    }
                } catch {
                    DispatchQueue.main.async {
                        HUD.hide()
                        completion(false)
                    }
                }
            }
        }
    }

    func updateName(name: String) {
        guard let wallet = storage.updateCurrentWalletName(name) else { return }
        walletBehaviorRelay.accept(wallet)
        plog(level: .info, log: "wallet change name to \(name)", tag: .wallet)
    }

    func generateAccount(count: Int) -> Bool {
        guard let wallet = walletBehaviorRelay.value else { return false }
        guard wallet.addressCount < count else { return false }
        guard count <= type(of: self).maxAddressCount else { return false }
        pri_update(addressIndex: wallet.addressIndex, addressCount: count)
        plog(level: .info, log: "generate addresses total: \(self.accounts.count)", tag: .wallet)
        return true
    }

    func selectAccount(index: Int) -> Bool {
        guard let wallet = walletBehaviorRelay.value else { return false }
        guard index < wallet.addressCount else { return false }
        guard index != wallet.addressIndex else { return true }
        pri_update(addressIndex: index, addressCount: wallet.addressCount)
        plog(level: .info, log: "select \(self.account?.address ?? ""), index: \(index)", tag: .wallet)
        return true
    }

    var wallets: [HDWalletStorage.Wallet] {
        return storage.wallets
    }

    public var wallet: HDWalletStorage.Wallet? {
        return storage.currentWallet
    }

    public var account: Wallet.Account? {
        return accountBehaviorRelay.value
    }

    var accounts: [Wallet.Account] {
        return accountsBehaviorRelay.value
    }

    var selectBagIndex: Int {
        return walletBehaviorRelay.value?.addressIndex ?? 0
    }

    var canGenerateNextAccount: Bool {
        guard let wallet = walletBehaviorRelay.value else { return false }
        return wallet.addressCount < type(of: self).maxAddressCount
    }
}

// MARK: - Grin {
extension HDWalletManager {
    var mnemonicForGrin: String? {
        guard let l = language, let m = mnemonic else { return nil }
        if l == MnemonicCodeBook.english {
            return m
        } else {
            guard let entropy = Mnemonic.mnemonicsToEntropy(m, language: l) else { return nil }
            let ret = Mnemonic.generator(entropy: entropy, language: .english)
            return ret
        }
    }
}

// MARK: - Settings
extension HDWalletManager {
    func setIsRequireAuthentication(_ isRequireAuthentication: Bool) {
        guard let wallet = storage.updateCurrentWallet(isRequireAuthentication: isRequireAuthentication) else { return }
        walletBehaviorRelay.accept(wallet)
    }

    func setIsTransferByBiometry(_ isTransferByBiometry: Bool) {
        guard let wallet = storage.updateCurrentWallet(isTransferByBiometry: isTransferByBiometry) else { return }
        walletBehaviorRelay.accept(wallet)
    }

    func setIsAutoReceive(_ isAutoReceive: Bool) {
        guard let wallet = storage.updateCurrentWallet(isAutoReceive: isAutoReceive) else { return }
        walletBehaviorRelay.accept(wallet)
    }
    
    func setBackedUp() {
        guard let wallet = storage.updateCurrentWallet(isBackedUp: true) else { return }
        walletBehaviorRelay.accept(wallet)
    }

    var isBackedUp: Bool {
        return storage.currentWallet?.isBackedUp ?? true
    }

    var isRequireAuthentication: Bool {
        return storage.currentWallet?.isRequireAuthentication ?? false
    }

    var isTransferByBiometry: Bool {
        return storage.currentWallet?.getTransferByBiometry ?? false
    }
}

// MARK: - login & logout
extension HDWalletManager {

    func importAndLoginWallet(name: String, mnemonic: String, language: MnemonicCodeBook, password: String, completion: @escaping (Bool) -> ()) {
        let uuid = UUID().uuidString
        let encryptKey = password.toEncryptKey(salt: uuid)
        let importBlock = {
            DispatchQueue.global().async {
                KeychainService.instance.setCurrentWallet(uuid: uuid, encryptKey: encryptKey)
                HDWalletManager.instance.importAddLoginWallet(uuid: uuid, name: name, mnemonic: mnemonic, language: language, encryptKey: encryptKey)
                DispatchQueue.main.async {
                    HUD.hide()
                    completion(true)
                    NotificationCenter.default.post(name: .createAccountSuccess, object: nil)
                    DispatchQueue.main.async {
                        Toast.show(R.string.localizable.importPageSubmitSuccess())
                    }
                }
            }
        }

        HUD.show(R.string.localizable.importPageSubmitLoading())
        DispatchQueue.global().async {
            if let wallet = HDWalletManager.instance.isExist(mnemonic: mnemonic) {
                DispatchQueue.main.async {
                    HUD.hide()
                    Alert.show(title: R.string.localizable.importPageAlertExistTitle(wallet.name), message: nil, actions: [
                        (.default(title: R.string.localizable.importPageAlertExistOk()), { alertController in
                            HUD.show(R.string.localizable.importPageSubmitLoading())
                            importBlock()
                            DispatchQueue.global().async {
                                FileHelper.deleteWalletDirectory(uuid: wallet.uuid)
                            }
                        }),
                        (.default(title: R.string.localizable.importPageAlertExistCancel()), { _ in
                            completion(false)
                        })])
                }
            } else {
                importBlock()
            }

        }
    }

    fileprivate func isExist(mnemonic: String) -> Wallet? {
        let hash = Wallet.mnemonicHash(mnemonic: mnemonic)
        for wallet in storage.wallets where hash == wallet.hash {
            return wallet
        }
        return nil
    }

    func addAndLoginWallet(uuid: String, name: String, mnemonic: String, language: MnemonicCodeBook, encryptKey: String, isBackedUp: Bool) {
        let hash = Wallet.mnemonicHash(mnemonic: mnemonic)
        let wallet = storage.addAddLoginWallet(uuid: uuid, name: name, mnemonic: mnemonic, language: language, hash: hash, encryptKey: encryptKey, isBackedUp: isBackedUp)
        self.mnemonic = mnemonic
        self.language = language
        self.encryptedKey = encryptKey
        pri_updateWallet(wallet)
        plog(level: .info, log: "\(wallet.name) wallet login", tag: .wallet)
    }

    fileprivate func importAddLoginWallet(uuid: String, name: String, mnemonic: String, language: MnemonicCodeBook, encryptKey: String) {
        let hash = Wallet.mnemonicHash(mnemonic: mnemonic)
        let wallet = storage.addAddLoginWallet(uuid: uuid, name: name, mnemonic: mnemonic, language: language, hash: hash, encryptKey: encryptKey, isBackedUp: true)
        self.mnemonic = mnemonic
        self.language = language
        self.encryptedKey = encryptKey
        pri_updateWallet(wallet)
        plog(level: .info, log: "\(wallet.name) wallet login", tag: .wallet)
    }

    func loginWithUuid(_ uuid: String, encryptKey: String) -> Bool {
        guard let (wallet, mnemonic) = storage.login(encryptKey: encryptKey, uuid: uuid) else { return false }
        self.mnemonic = mnemonic
        self.language = wallet.language
        self.encryptedKey = encryptKey
        pri_updateWallet(wallet)
        plog(level: .info, log: "\(wallet.name) wallet login", tag: .wallet)
        return true
    }

    func loginCurrent(encryptKey: String) -> Bool {
        guard let (wallet, mnemonic) = storage.login(encryptKey: encryptKey) else { return false }
        self.mnemonic = mnemonic
        self.language = wallet.language
        self.encryptedKey = encryptKey
        pri_updateWallet(wallet)
        plog(level: .info, log: "\(wallet.name) wallet login", tag: .wallet)

        return true
    }

    func logout() {
        storage.logout()
        mnemonic = nil
        language = nil
        encryptedKey = nil
        walletBehaviorRelay.accept(nil)
        plog(level: .info, log: "wallet logout", tag: .wallet)
    }

    func deleteWallet() {
        mnemonic = nil
        language = nil
        encryptedKey = nil
        walletBehaviorRelay.accept(nil)
        storage.deleteCurrentWallet()
        plog(level: .info, log: "wallet delete", tag: .wallet)
    }

    func verifyPassword(_ password: String) -> Bool {
        guard let uuid = storage.currentWallet?.uuid else { return false }
        let encryptKey = password.toEncryptKey(salt: uuid)
        return encryptKey == self.encryptedKey
    }

    var canUnLock: Bool {
        return storage.currentWallet != nil
    }

    var isEmpty: Bool {
        return storage.wallets.isEmpty
    }

    var currentWalletIndex: Int? {
        return storage.currentWalletIndex
    }
}

// MARK: - private function
extension HDWalletManager {

    fileprivate func pri_updateWallet(_ wallet: HDWalletStorage.Wallet) {
        walletBehaviorRelay.accept(wallet)
    }

    fileprivate func pri_update(addressIndex: Int, addressCount: Int) {
        guard let wallet = storage.updateCurrentWallet(addressIndex: addressIndex,
                                                       addressCount: addressCount) else { return }
        walletBehaviorRelay.accept(wallet)
    }
}

// MARK: - DEBUG function
#if DEBUG || TEST
extension HDWalletManager {

    func deleteAllWallets() {
        storage.deleteAllWallets()
        mnemonic = nil
        language = nil
        encryptedKey = nil
        walletBehaviorRelay.accept(nil)
    }

    func resetBagCount() {
        pri_update(addressIndex: 0, addressCount: 1)
    }
}
#endif
