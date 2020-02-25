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
    public var password: String? = nil

    public var totalAccountCount: Int = 1
    public var currentAccountIndex: Int = 0

    public lazy var accountsDriver: Driver<[ETHAccount]> = self.accountsBehaviorRelay.asDriver()
    public lazy var accountDriver: Driver<ETHAccount?> = self.accountBehaviorRelay.asDriver()

    public var account:ETHAccount? { return accountBehaviorRelay.value}


    private var accountsBehaviorRelay = BehaviorRelay(value: [ETHAccount]())
    private var accountBehaviorRelay: BehaviorRelay<ETHAccount?> = BehaviorRelay(value: nil)

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

        if let web3 = self.web3 {
            self.web3.addKeystoreManager(KeystoreManager([keystore]))
        }

        self.keystore = keystore
        self.password = password
        for _ in 1..<totalAccountCount { try! keystore.createNewChildAccount(password: password) }
        let addresses = keystore.sortedAddresses

        var accounts = [ETHAccount]()
        for index in 0..<totalAccountCount {
            let ethAddress = addresses[index]
            guard let privateKey = try? keystore.UNSAFE_getPrivateKeyData(password: password, account: ethAddress) else { fatalError() }
            let account = ETHAccount(ethereumAddress: ethAddress, privateKey: privateKey, accountIndex: index)
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
        let account = ETHAccount(ethereumAddress: lastEthAddress, privateKey: privateKey, accountIndex: accounts.count)
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

    public var web3: web3swift.web3!
    static public let defaultGasLimitForTokenTransfer = 60000
    static public let defaultGasLimitForEthTransfer = 60000

    // Must be called first
    public func setProviderURL(_ providerURL: URL, net:Networks) {
        let infura = InfuraProvider(net)!
        infura.url = providerURL
        self.web3 = web3swift.web3(provider: infura)
        if let keystore = keystore {
            self.web3.addKeystoreManager(KeystoreManager([keystore]))
        }
    }
}

extension BIP32Keystore {
    var sortedAddresses: [EthereumAddress] {
        return self.paths.map { ($0.key, $0.value) }.sorted { $0.0 < $1.0 }.map { $0.1 }
    }
}


