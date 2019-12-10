import web3swift
import CryptoSwift
import Vite_HDWalletKit

public protocol AccountService {
    var address: String? { get }
    var privateKey: Data? { get }
    func importAccount(mnemonics: String, password: String, language: MnemonicCodeBook) throws
    func logout()
}

extension EtherWallet: AccountService {
    public var address: String? {
        return ethereumAddress?.address
    }

    public var ethereumAddress: EthereumAddress? {
        return keystore?.getAddress()
    }

    public var privateKey: Data? {
        guard let keystore = self.keystore else { return nil }
        guard let account = self.ethereumAddress else { return nil }
        guard let privateKey = try? keystore.UNSAFE_getPrivateKeyData(password: password, account: account) else { return nil }
        return privateKey
    }
    
    public func importAccount(mnemonics: String, password: String, language: MnemonicCodeBook) throws {

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

        guard let keystore = (try? BIP32Keystore(mnemonics: mnemonics, password: password, mnemonicsPassword: "", language: l)) ?? nil else {
            throw WalletError.invalidMnemonics
        }
        
        guard let address = keystore.addresses?.first else {
            throw WalletError.malformedKeystore
        }
        
        guard let privateKey = try? keystore.UNSAFE_getPrivateKeyData(password: password, account: address).toHexString() else {
            throw WalletError.malformedKeystore
        }

        try importAccount(privateKey: privateKey, password: password)
    }

    public func logout() {
        self.password = ""
        self.keystore = nil
    }

    private func importAccount(privateKey: String, password: String) throws {

        self.password = password

        let privateKeyData = Data()
//        guard let privateKeyData = Data.fromHex(privateKey) else {
//            throw WalletError.invalidKey
//        }
        guard let keystore = try EthereumKeystoreV3(privateKey: privateKeyData, password: password) else {
            throw WalletError.malformedKeystore
        }

        web3.addKeystoreManager(KeystoreManager([keystore]))
        self.keystore = keystore
    }
}
