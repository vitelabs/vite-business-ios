//
//  ETHAccount.swift
//  ViteBusiness
//
//  Created by Stone on 2020/2/25.
//

import Foundation
import PromiseKit
import BigInt
import web3swift

// MARK: ETHAccount
public struct ETHAccount {
    public let ethereumAddress: EthereumAddress
    public let privateKey: Data
    public let accountIndex: Int

    var address: String {
        return ethereumAddress.address
    }
}

// MARK: ETHAccount - Balance
extension ETHAccount {

    public func etherBalance() -> Promise<BigInt> {
        return Promise { seal in
            DispatchQueue.global().async {
                do {
                    let balance = try ETHWalletManager.instance.web3.eth.getBalance(address: self.ethereumAddress)
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
                    guard let erc20ContractAddress = EthereumAddress(contractAddress), erc20ContractAddress.isValid else { throw  WalletError.invalidAddress }
                    guard let contract = ETHWalletManager.instance.web3.contract(Web3.Utils.erc20ABI, at: erc20ContractAddress) else { fatalError() }

                    var options = TransactionOptions.defaultOptions
                    options.from = self.ethereumAddress
                    options.callOnBlock = .latest

                    guard let tx = contract.read("balanceOf",
                                                 parameters: [self.ethereumAddress] as [AnyObject],
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

// MARK: ETHAccount - Transaction
extension ETHAccount {
    public func getSendTokenTransaction(to address: String, amount: BigInt, gasPrice: BigInt?, contractAddress: String) -> Promise<WriteTransaction> {

        return tokenBalance(contractAddress: contractAddress)
            .then(on: DispatchQueue.global(), { (balance) -> Promise<WriteTransaction> in

                guard balance >= amount else { throw WalletError.notEnoughBalance }

                let web3 = ETHWalletManager.instance.web3!
                let walletAddress = self.ethereumAddress
                let toAddress = EthereumAddress(address)
                let erc20ContractAddress = EthereumAddress(contractAddress)!
                guard let contract = web3.contract(Web3.Utils.erc20ABI, at: erc20ContractAddress, abiVersion: 2) else { fatalError() }

                var options = TransactionOptions.defaultOptions
                options.from = walletAddress
                options.callOnBlock = .latest
                if let g = gasPrice {
                    options.gasPrice = .manual(BigUInt(g))
                } else {
                    let gasPrice = try web3.eth.getGasPrice()
                    options.gasPrice = .manual(gasPrice)
                }
                options.gasLimit = .manual(BigUInt(ETHWalletManager.defaultGasLimitForTokenTransfer))

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
                    guard let password = ETHWalletManager.instance.password else { throw WalletError.accountDoesNotExist}
                    let result = try transaction.send(password: password)
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
                    try Web3Signer.EIP155Signer.sign(transaction: &t, privateKey: self.privateKey)
                    guard let encoded  = t.encode() else { throw WalletError.unexpectedResult }
                    let hash = encoded.sha3(.keccak256)
                    DispatchQueue.main.async { seal.fulfill("0x" + hash.toHexString()) }
                } catch {
                    DispatchQueue.main.async { seal.reject(error) }
                }
            }
        }
    }

    static public func fetchGasPrice() -> Promise<BigInt> {
        return Promise { seal in
            DispatchQueue.global().async {
                do {
                    let result = try ETHWalletManager.instance.web3.eth.getGasPrice()
                    DispatchQueue.main.async { seal.fulfill(BigInt(result)) }
                } catch {
                    DispatchQueue.main.async { seal.reject(error) }
                }
            }
        }
    }

    public func sendEther(to address: String, amount: BigInt, gasPrice: BigInt?, note: String) -> Promise<TransactionSendingResult> {
        return etherBalance()
            .then(on: DispatchQueue.global(), { (balance) -> Promise<TransactionSendingResult> in
                guard balance >= amount else { throw WalletError.notEnoughBalance }
                guard let password = ETHWalletManager.instance.password else { throw WalletError.accountDoesNotExist}
                let walletAddress = self.ethereumAddress
                let web3 = ETHWalletManager.instance.web3!
                let toAddress = EthereumAddress(address)
                guard let contract = web3.contract(Web3.Utils.coldWalletABI, at: toAddress, abiVersion: 2) else { fatalError() }

                var options = TransactionOptions.defaultOptions
                options.value = BigUInt(amount)
                options.from = walletAddress
                options.callOnBlock = .latest

                if let g = gasPrice {
                    options.gasPrice = .manual(BigUInt(g))
                } else {
                    let gasPrice = try web3.eth.getGasPrice()
                    options.gasPrice = .manual(gasPrice)
                }

                let extraData: Data
                if note.isEmpty {
                    extraData = Data()
                } else {
                    extraData = note.data(using: .utf8) ?? Data()
                }

                options.gasLimit = .manual(BigUInt(ETHWalletManager.defaultGasLimitForEthTransfer))
                guard let tx = contract.write("fallback",
                                              parameters: [AnyObject](),
                                              extraData: extraData,
                                              transactionOptions: options) else { fatalError() }

                let result = try tx.send(password: password)
                return .value(result)
            })
    }

    public func sendToken(to address: String, amount: BigInt, gasPrice: BigInt?, contractAddress: String) -> Promise<TransactionSendingResult> {
        return getSendTokenTransaction(to: address, amount: amount, gasPrice: gasPrice, contractAddress: contractAddress)
            .then({ (wt) -> Promise<TransactionSendingResult> in
                return self.sendTransaction(wt)
            })
    }
}
