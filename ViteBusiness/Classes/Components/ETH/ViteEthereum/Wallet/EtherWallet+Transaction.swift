import web3swift
import BigInt
//import secp256k1_swift
import PromiseKit

public protocol TransactionService {

    // for exchange
    func getSendTokenTransaction(to address: String, amount: BigInt, gasPrice: BigInt?, contractAddress: String) -> Promise<WriteTransaction>
    func sendTransaction(_ transaction: WriteTransaction) -> Promise<TransactionSendingResult>
    func getTransactionHash(_ transaction: WriteTransaction) -> Promise<String>

    func fetchGasPrice() -> Promise<BigInt>
    func sendEther(to address: String, amount: BigInt, gasPrice: BigInt?) -> Promise<String>
    func sendToken(to address: String, amount: BigInt, gasPrice: BigInt?, contractAddress: String) -> Promise<String>
}

extension EtherWallet: TransactionService {

    public func getSendTokenTransaction(to address: String, amount: BigInt, gasPrice: BigInt?, contractAddress: String) -> Promise<WriteTransaction> {

        return tokenBalance(contractAddress: contractAddress)
            .then(on: DispatchQueue.global(), { (balance) -> Promise<WriteTransaction> in

                guard balance >= amount else { throw WalletError.notEnoughBalance }

                guard let walletAddress =  self.ethereumAddress else { throw  WalletError.invalidAddress }
                let toAddress = EthereumAddress(address)
                let erc20ContractAddress = EthereumAddress(contractAddress)!
                guard let contract = self.web3.contract(Web3.Utils.erc20ABI, at: erc20ContractAddress, abiVersion: 2) else { fatalError() }

                var options = TransactionOptions.defaultOptions
                options.from = walletAddress
                if let g = gasPrice {
                    options.gasPrice = .manual(BigUInt(g))
                } else {
                    let gasPrice = try self.web3.eth.getGasPrice()
                    options.gasPrice = .manual(gasPrice)
                }
                options.gasLimit = .manual(BigUInt(type(of: self).defaultGasLimitForTokenTransfer))

                guard let tx = contract.write("transfer",
                                              parameters: [toAddress, BigUInt(amount)] as [AnyObject],
                                              extraData: Data(),
                                              transactionOptions: options) else { fatalError() }
                return .value(tx)
            })
    }

    public func sendTransaction(_ transaction: WriteTransaction) -> Promise<TransactionSendingResult> {
        return Promise { seal in
            DispatchQueue.global().async {
                do {
                    let result = try transaction.send(password: self.password)
                    DispatchQueue.main.async { seal.fulfill(result) }
                } catch {
                    DispatchQueue.main.async { seal.reject(error) }
                }
            }
        }
    }
    
    public func getTransactionHash(_ transaction: WriteTransaction) -> Promise<String> {
        return Promise { seal in
            DispatchQueue.global().async {
                do {
                    var t = try transaction.assemble()
                    guard let privateKey = self.privateKey else { throw WalletError.accountDoesNotExist }
                    try Web3Signer.EIP155Signer.sign(transaction: &t, privateKey: privateKey)
                    guard let encoded  = t.encode() else { throw WalletError.unexpectedResult }
                    let hash = encoded.sha3(.keccak256)
                    DispatchQueue.main.async { seal.fulfill("0x" + hash.toHexString()) }
                } catch {
                    DispatchQueue.main.async { seal.reject(error) }
                }
            }
        }
    }

    public func fetchGasPrice() -> Promise<BigInt> {
        return Promise { seal in
            DispatchQueue.global().async {
                do {
                    let result = try self.web3.eth.getGasPrice()
                    DispatchQueue.main.async { seal.fulfill(BigInt(result)) }
                } catch {
                    DispatchQueue.main.async { seal.reject(error) }
                }
            }
        }
    }

    public func sendEther(to address: String, amount: BigInt, gasPrice: BigInt?) -> Promise<String> {
        return etherBalance()
            .then(on: DispatchQueue.global(), { (balance) -> Promise<String> in
                guard balance >= amount else { throw WalletError.notEnoughBalance }
                guard let walletAddress =  self.ethereumAddress else { throw  WalletError.invalidAddress }

                let toAddress = EthereumAddress(address)
                guard let contract = self.web3.contract(Web3.Utils.coldWalletABI, at: toAddress, abiVersion: 2) else { fatalError() }

                var options = TransactionOptions.defaultOptions
                options.value = BigUInt(amount)
                options.from = walletAddress

                if let g = gasPrice {
                    options.gasPrice = .manual(BigUInt(g))
                } else {
                    let gasPrice = try self.web3.eth.getGasPrice()
                    options.gasPrice = .manual(gasPrice)
                }
                options.gasLimit = .manual(BigUInt(type(of: self).defaultGasLimitForEthTransfer))
                guard let tx = contract.write("fallback",
                                              parameters: [AnyObject](),
                                              extraData: Data(),
                                              transactionOptions: options) else { fatalError() }

                let result = try tx.send(password: self.password)
                return .value(result.hash)
            })
    }

    public func sendToken(to address: String, amount: BigInt, gasPrice: BigInt?, contractAddress: String) -> Promise<String> {
        return getSendTokenTransaction(to: address, amount: amount, gasPrice: gasPrice, contractAddress: contractAddress)
            .then({ [weak self] (wt) -> Promise<String> in
                guard let `self` = self else { throw WalletError.accountDoesNotExist }
                return self.sendTransaction(wt).map({ $0.hash })
            })
    }
}
