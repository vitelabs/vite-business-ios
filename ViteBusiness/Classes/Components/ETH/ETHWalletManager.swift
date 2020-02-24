//
//  ETHWalletManager.swift
//  ViteBusiness
//
//  Created by Stone on 2020/2/24.
//

import Foundation
import ViteWallet
import Vite_HDWalletKit
import web3swift
import RxSwift
import RxCocoa



public class ETHWalletManager {
    static let instance = ETHWalletManager()
    private init() {}


    private var keystore: BIP32Keystore? = nil
    private var password: String? = nil

    public var totalAccountCount: Int = 1
    public var currentAccountIndex: Int = 0

    public lazy var accountsDriver: Driver<[Account]> = self.accountsBehaviorRelay.asDriver()
    public lazy var accountDriver: Driver<Account?> = self.accountBehaviorRelay.asDriver()

    public var account:Account? { return accountBehaviorRelay.value}


    private var accountsBehaviorRelay = BehaviorRelay(value: [Account]())
    private var accountBehaviorRelay: BehaviorRelay<Account?> = BehaviorRelay(value: nil)

    func unregister() {
        keystore = nil
        password = nil
        totalAccountCount = 1
        currentAccountIndex = 0
        accountsBehaviorRelay.accept([])
        accountBehaviorRelay.accept(nil)
    }

    func register(mnemonic: String, language: MnemonicCodeBook, password: String) {
        guard let eth = WalletManager.instance.storager?.eth else { fatalError() }

        let l: BIP39Language
        switch language {
        case .english:
            l = BIP39Language.english
        case .simplifiedChinese:
            l = BIP39Language.chinese_simplified
        case .traditionalChinese:
            l = BIP39Language.chinese_traditional
        case .japanese:
            l = BIP39Language.japanese
        case .korean:
            l = BIP39Language.korean
        case .spanish:
            l = BIP39Language.spanish
        case .french:
            l = BIP39Language.french
        case .italian:
            l = BIP39Language.italian
        }

        self.totalAccountCount = eth.totalAccountCount
        self.currentAccountIndex = eth.currentAccountIndex

        let keystore = try! BIP32Keystore(mnemonics: mnemonic, password: password, mnemonicsPassword: "", language: l)!
        self.keystore = keystore
        self.password = password
        for _ in 1..<totalAccountCount { try! keystore.createNewChildAccount(password: password) }
        let addresses = keystore.sortedAddresses

        var accounts = [Account]()
        for index in 0..<totalAccountCount {
            let ethAddress = addresses[index]
            guard let privateKey = try? keystore.UNSAFE_getPrivateKeyData(password: password, account: ethAddress) else { fatalError() }
            let address = ethAddress.address
            let account = Account(address: address, privateKey: privateKey, accountIndex: index)
            accounts.append(account)
        }

        accountsBehaviorRelay.accept(accounts)
        accountBehaviorRelay.accept(accounts[currentAccountIndex])
    }

    func generateNextAccount() {
        guard let keystore = keystore, let password = password else { return }
        try! keystore.createNewChildAccount(password: password)
        guard let lastEthAddress = keystore.sortedAddresses.last else { fatalError() }

        var accounts = accountsBehaviorRelay.value
        guard let privateKey = try? keystore.UNSAFE_getPrivateKeyData(password: password, account: lastEthAddress) else { fatalError() }
        let address = lastEthAddress.address
        let account = Account(address: address, privateKey: privateKey, accountIndex: accounts.count)
        accounts.append(account)
        accountsBehaviorRelay.accept(accounts)

        totalAccountCount += 1
        WalletManager.eth.update(totalAccountCount: totalAccountCount)
    }

    func selectAccount(index: Int) -> Bool {
        guard index < accountsBehaviorRelay.value.count else { return false }
        guard let accountIndex = account?.accountIndex else { return false}
        guard index != accountIndex else { return true}
        accountBehaviorRelay.accept(accountsBehaviorRelay.value[index])

        currentAccountIndex = index
        WalletManager.eth.update(currentAccountIndex: index)
        return true
    }
}

extension ETHWalletManager {

    public struct Account {
        public let address: String
        public let privateKey: Data
        public let accountIndex: Int
    }
}


extension BIP32Keystore {
    var sortedAddresses: [EthereumAddress] {
        return self.paths.map { ($0.key, $0.value) }.sorted { $0.0 < $1.0 }.map { $0.1 }
    }
}
