import web3swift
import CryptoSwift

public protocol AccountService {
    var address: String? { get }
    var privateKey: Data? { get }
    func importAccount(mnemonics: String, password: String) throws
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
    
    public func importAccount(mnemonics: String, password: String) throws {

        guard let keystore = (try? BIP32Keystore(mnemonics: mnemonics, password: password)) ?? nil else {
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

        guard let privateKeyData = Data.fromHex(privateKey) else {
            throw WalletError.invalidKey
        }
        guard let keystore = try EthereumKeystoreV3(privateKey: privateKeyData, password: password) else {
            throw WalletError.malformedKeystore
        }

        web3.addKeystoreManager(KeystoreManager([keystore]))
        self.keystore = keystore
    }
}
