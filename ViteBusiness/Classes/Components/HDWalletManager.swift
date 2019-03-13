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
import ViteUtils
import ViteEthereum

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
                guard self.accountBehaviorRelay.value?.address.description != account.address.description else { return }
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

    // ETH
    public lazy var ethAddressDriver: Driver<String?> = self.ethAddressBehaviorRelay.asDriver()
    private var ethAddressBehaviorRelay: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    public var ethAddress: String? { return self.ethAddressBehaviorRelay.value }

    fileprivate let storage = HDWalletStorage()
    fileprivate(set) var mnemonic: String?
    public fileprivate(set) var encryptedKey: String?

    public internal(set) var locked = false

    fileprivate static let maxAddressCount = 10

    func updateName(name: String) {
        guard let wallet = storage.updateCurrentWalletName(name) else { return }
        walletBehaviorRelay.accept(wallet)
    }

    func generateNextAccount() -> Bool {
        guard let wallet = walletBehaviorRelay.value else { return false }
        guard wallet.addressCount < type(of: self).maxAddressCount else { return false }
        pri_update(addressIndex: wallet.addressIndex, addressCount: wallet.addressCount + 1)
        return true
    }

    func selectAccount(index: Int) -> Bool {
        guard let wallet = walletBehaviorRelay.value else { return false }
        guard index < wallet.addressCount else { return false }
        guard index != wallet.addressIndex else { return true }
        pri_update(addressIndex: index, addressCount: wallet.addressCount)
        return true
    }

    var wallets: [HDWalletStorage.Wallet] {
        return storage.wallets
    }

    public var wallet: HDWalletStorage.Wallet? {
        return storage.currentWallet
    }

    var account: Wallet.Account? {
        return accountBehaviorRelay.value
    }

    var selectBagIndex: Int {
        return walletBehaviorRelay.value?.addressIndex ?? 0
    }

    var canGenerateNextAccount: Bool {
        guard let wallet = walletBehaviorRelay.value else { return false }
        return wallet.addressCount < type(of: self).maxAddressCount
    }
}

// MARK: - Settings
extension HDWalletManager {
    func setIsRequireAuthentication(_ isRequireAuthentication: Bool) {
        guard let wallet = storage.updateCurrentWallet(isRequireAuthentication: isRequireAuthentication) else { return }
        walletBehaviorRelay.accept(wallet)
    }

    func setIsAuthenticatedByBiometry(_ isAuthenticatedByBiometry: Bool) {
        guard let wallet = storage.updateCurrentWallet(isAuthenticatedByBiometry: isAuthenticatedByBiometry) else { return }
        walletBehaviorRelay.accept(wallet)
    }

    func setIsTransferByBiometry(_ isTransferByBiometry: Bool) {
        guard let wallet = storage.updateCurrentWallet(isTransferByBiometry: isTransferByBiometry) else { return }
        walletBehaviorRelay.accept(wallet)
    }

    var isRequireAuthentication: Bool {
        return storage.currentWallet?.isRequireAuthentication ?? false
    }

    var isAuthenticatedByBiometry: Bool {
        return storage.currentWallet?.isAuthenticatedByBiometry ?? false
    }

    var isTransferByBiometry: Bool {
        return storage.currentWallet?.isTransferByBiometry ?? false
    }
}

// MARK: - login & logout
extension HDWalletManager {

    func isExist(mnemonic: String) -> String? {
        let hash = Wallet.mnemonicHash(mnemonic: mnemonic)
        for wallet in storage.wallets where hash == wallet.hash {
            return wallet.name
        }
        return nil
    }

    func addAndLoginWallet(uuid: String, name: String, mnemonic: String, encryptKey: String) {
        let hash = Wallet.mnemonicHash(mnemonic: mnemonic)
        let wallet = storage.addAddLoginWallet(uuid: uuid, name: name, mnemonic: mnemonic, hash: hash, encryptKey: encryptKey, needRecoverAddresses: false)
        self.mnemonic = mnemonic
        self.encryptedKey = encryptKey
        pri_updateWallet(wallet)
        pri_LoginEthWallet()
    }

    func importAddLoginWallet(uuid: String, name: String, mnemonic: String, encryptKey: String) {
        let hash = Wallet.mnemonicHash(mnemonic: mnemonic)
        let wallet = storage.addAddLoginWallet(uuid: uuid, name: name, mnemonic: mnemonic, hash: hash, encryptKey: encryptKey, needRecoverAddresses: true)
        self.mnemonic = mnemonic
        self.encryptedKey = encryptKey
        pri_updateWallet(wallet)
        pri_LoginEthWallet()
    }

    func loginWithUuid(_ uuid: String, encryptKey: String) -> Bool {
        guard let (wallet, mnemonic) = storage.login(encryptKey: encryptKey, uuid: uuid) else { return false }
        self.mnemonic = mnemonic
        self.encryptedKey = encryptKey
        pri_updateWallet(wallet)
        pri_LoginEthWallet()
        return true
    }

    func loginCurrent(encryptKey: String) -> Bool {
        guard let (wallet, mnemonic) = storage.login(encryptKey: encryptKey) else { return false }
        self.mnemonic = mnemonic
        self.encryptedKey = encryptKey
        pri_updateWallet(wallet)
        pri_LoginEthWallet()
        return true
    }

    func logout() {
        storage.logout()
        mnemonic = nil
        encryptedKey = nil
        walletBehaviorRelay.accept(nil)

        pri_LogoutEthWallet()
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
        pri_recoverAddressesIfNeeded(wallet.uuid)
    }

    fileprivate func pri_LoginEthWallet() {
        guard let mnemonic = self.mnemonic  else {
            return
        }
        _ = try? EtherWallet.account.importAccount(mnemonics: mnemonic, password: "")
        self.ethAddressBehaviorRelay.accept(EtherWallet.account.address)
    }
    fileprivate func pri_LogoutEthWallet() {
        _ = try? EtherWallet.account.logout()
    }

    fileprivate func pri_recoverAddressesIfNeeded(_ uuid: String) {
        guard let wallet = self.walletBehaviorRelay.value else { return }
        guard uuid == wallet.uuid else { return }
        guard wallet.needRecoverAddresses else { return }
        let accounts = (0..<type(of: self).maxAddressCount).map { try? wallet.account(at: $0, encryptedKey: self.encryptedKey ?? "") }.compactMap { $0 }
        let addresses = accounts.map { $0.address }
        guard addresses.count == type(of: self).maxAddressCount else { return }
        Provider.default.recoverAddresses(addresses)
            .done { [weak self] (count) in
                guard let `self` = self else { return }
                guard let wallet = self.walletBehaviorRelay.value else { return }
                guard uuid == wallet.uuid else { return }
                let current = wallet.addressCount
                self.pri_update(addressIndex: wallet.addressIndex, addressCount: max(current, count), needRecoverAddresses: false)
            }
            .catch { [weak self] (error) in
                guard let `self` = self else { return }
                guard let wallet = self.walletBehaviorRelay.value else { return }
                guard uuid == wallet.uuid else { return }
                GCD.delay(3, task: { self.pri_recoverAddressesIfNeeded(uuid) })
        }
    }

    fileprivate func pri_update(addressIndex: Int, addressCount: Int, needRecoverAddresses: Bool? = nil) {
        guard let wallet = storage.updateCurrentWallet(addressIndex: addressIndex,
                                                       addressCount: addressCount,
                                                       needRecoverAddresses: needRecoverAddresses) else { return }
        walletBehaviorRelay.accept(wallet)
    }
}

// MARK: - DEBUG function
#if DEBUG || TEST
extension HDWalletManager {

    func deleteAllWallets() {
        storage.deleteAllWallets()
        mnemonic = nil
        encryptedKey = nil
        walletBehaviorRelay.accept(nil)
    }

    func resetBagCount() {
        pri_update(addressIndex: 0, addressCount: 1)
    }
}
#endif

extension FileHelper {
    static var appPathComponent = "app"
    static var walletPathComponent: String {
        return HDWalletManager.instance.walletBehaviorRelay.value?.uuid ?? "uuid"
    }
}
