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
            web3.addKeystoreManager(KeystoreManager([keystore]))
        }

        self.keystore = keystore
        self.password = password
        for _ in 1..<totalAccountCount { try! keystore.createNewChildAccount(password: password) }
        let addresses = keystore.sortedAddresses


//        keystore.paths.map { ($0.key, $0.value) }.sorted {
//            let l = Int($0.0.components(separatedBy: "/").last!)!
//            let r = Int($1.0.components(separatedBy: "/").last!)!
//            return l < r
//        }.forEach { (path, address) in
//            plog(level: .debug, log: "fsdf: \(path) \(address.address)")
//        }

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

    fileprivate static let maxAddressCount = 100

    func generateAccount(count: Int) -> Bool {
        guard let keystore = keystore, let password = password else { return false }
        guard count <= type(of: self).maxAddressCount else { return false }

        var accounts = accountsBehaviorRelay.value

        let num = count - accounts.count
        for _ in 0..<num {
            try! keystore.createNewChildAccount(password: password)
        }

        let addresses = keystore.sortedAddresses.dropFirst(accounts.count)

        for address in addresses {
            guard let privateKey = try? keystore.UNSAFE_getPrivateKeyData(password: password, account: address) else { fatalError() }
            let account = ETHAccount(ethereumAddress: address, privateKey: privateKey, accountIndex: accounts.count)
            accounts.append(account)
        }
        accountsBehaviorRelay.accept(accounts)
        totalAccountCount += num
        WalletManager.eth.update(totalAccountCount: totalAccountCount)
        return true
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
    static public let defaultGasLimitForTokenTransfer = 200000
    static public let defaultGasLimitForEthTransfer = 200000

    // Must be called first
    public func setProviderURL(_ providerURL: URL, net:Networks) {
        let infura = InfuraProvider(net)!
        infura.url = providerURL
        self.web3 = web3swift.web3(provider: infura)
        if let keystore = keystore {
            self.web3.addKeystoreManager(KeystoreManager([keystore]))
        }
    }

    public func isContractAddress(_ address: String) -> Promise<Bool> {
        return web3.eth.getCode(address: address).map { $0 != "0x" }
    }
}

// MARK: - DEBUG function
#if DEBUG || TEST
extension ETHWalletManager {

    func resetBagCount() {
        currentAccountIndex = 0
        totalAccountCount = 0
        accountBehaviorRelay.accept(accountsBehaviorRelay.value.first!)
        accountsBehaviorRelay.accept([accountBehaviorRelay.value!])
        WalletManager.eth.update(currentAccountIndex: currentAccountIndex)
        WalletManager.eth.update(totalAccountCount: totalAccountCount)
    }
}
#endif

extension BIP32Keystore {
    var sortedAddresses: [EthereumAddress] {
        return self.paths.map { ($0.key, $0.value) }.sorted {
            let l = Int($0.0.components(separatedBy: "/").last!)!
            let r = Int($1.0.components(separatedBy: "/").last!)!
            return l < r
        }.map { $0.1 }
    }
}

import PromiseKit

extension web3.Eth {
    public func getCode(address: String, onBlock: String = "latest") -> Promise<String> {
        let request = JSONRPCRequestFabric.prepareRequest(.getCode, parameters: [address.lowercased(), onBlock])
        let rp = ETHWalletManager.instance.web3.dispatch(request)
        let queue = ETHWalletManager.instance.web3.requestDispatcher.queue
        return rp.map(on: queue ) { response in
            guard let value: String = response.getValue() else {
                if response.error != nil {
                    throw Web3Error.nodeError(desc: response.error!.message)
                }
                throw Web3Error.nodeError(desc: "Invalid value from Ethereum node")
            }
            return value
        }
    }
}
