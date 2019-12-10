import web3swift
import BigInt
import PromiseKit

public protocol BalanceService {
    func etherBalance() -> Promise<BigInt>
    func tokenBalance(contractAddress: String) -> Promise<BigInt>
}

extension EtherWallet: BalanceService {

    public func etherBalance() -> Promise<BigInt> {
        return Promise { seal in
            DispatchQueue.global().async {
                do {
                    guard let myEthAddress =  self.ethereumAddress, myEthAddress.isValid else { throw  WalletError.invalidAddress }
                    let balance = try self.web3.eth.getBalance(address: myEthAddress)
                    DispatchQueue.main.async { seal.fulfill(BigInt(balance)) }
                } catch {
                    DispatchQueue.main.async { seal.reject(error) }
                }
            }
        }
    }

    public func tokenBalance(contractAddress: String) -> Promise<BigInt> {
        return Promise { seal in
            DispatchQueue.global().async {
                do {
                    guard let myEthAddress = self.ethereumAddress, myEthAddress.isValid else { throw  WalletError.invalidAddress }
                    guard let erc20ContractAddress = EthereumAddress(contractAddress), erc20ContractAddress.isValid else { throw  WalletError.invalidAddress }
                    guard let contract = self.web3.contract(Web3.Utils.erc20ABI, at: erc20ContractAddress) else { fatalError() }

                    var options = TransactionOptions.defaultOptions
                    options.from = myEthAddress
                    options.callOnBlock = .latest

                    guard let tx = contract.read("balanceOf",
                                                 parameters: [myEthAddress] as [AnyObject],
                                                 extraData: Data(),
                                                 transactionOptions: options) else { fatalError() }

                    let tokenBalance = try tx.call()
                    guard let balance = tokenBalance["0"] as? BigUInt else { throw WalletError.conversionFailure }
                    DispatchQueue.main.async { seal.fulfill(BigInt(balance)) }
                } catch {
                    DispatchQueue.main.async { seal.reject(error) }
                }
            }
        }
    }
}
