import web3swift
import BigInt

public class EtherWallet {
    public static let shared = EtherWallet()
    public static let account: AccountService = EtherWallet.shared
    public static let balance: BalanceService = EtherWallet.shared
    public static let transaction: TransactionService = EtherWallet.shared

    static public let defaultGasLimitForTokenTransfer = 60000
    static public let defaultGasLimitForEthTransfer = 60000

    var web3: web3swift.web3!
    var password = ""
    var keystore: EthereumKeystoreV3?

    // Must be called first
    public func setProviderURL(_ providerURL: URL, net:Networks) {
        let infura = InfuraProvider(net)!
        infura.url = providerURL
        self.web3 = web3swift.web3(provider: infura)
        if let keystore = keystore {
            self.web3.addKeystoreManager(KeystoreManager([keystore]))
        }
    }
     
    private init() { }
}

