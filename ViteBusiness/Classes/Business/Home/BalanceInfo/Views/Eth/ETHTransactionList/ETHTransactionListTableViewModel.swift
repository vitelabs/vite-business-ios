//
//  ETHTransactionListTableViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2020/2/26.
//

import Foundation
import ViteWallet
import RxSwift
import RxCocoa
import PromiseKit
import BigInt

final class ETHTransactionListTableViewModel: TransactionListTableViewModelType {

    enum LoadingStatus {
        case no
        case refresh
        case more
    }

    lazy var transactionsDriver: Driver<[ETHTransactionViewModel]> = self.transactions.asDriver()
    let hasMore: BehaviorRelay<Bool>

    fileprivate var transactions: BehaviorRelay<[ETHTransactionViewModel]>
    fileprivate var account: ETHAccount
    fileprivate var address: String { account.address }
    fileprivate let tokenInfo: TokenInfo
    fileprivate let disposeBag = DisposeBag()

    fileprivate var txs = [ETHTransaction]()
    fileprivate var page = 1
    fileprivate var loadingStatus = LoadingStatus.no

    fileprivate let limit = 20
    fileprivate var transactionCount: BigInt = BigInt(0)

    init(account: ETHAccount, tokenInfo: TokenInfo) {
        self.account = account
        self.tokenInfo = tokenInfo
        self.transactions = BehaviorRelay<[ETHTransactionViewModel]>(value: [])
        self.hasMore = BehaviorRelay<Bool>(value: false)

        NotificationCenter.default.rx.notification(.EthChainSendSuccess).bind { [weak self] (n) in
            guard let `self` = self else { return }
            if tokenInfo.isEtherCoin {
                self.transactions.accept(self.genViewModels())
                self.hasMore.accept(self.hasMore.value)
            } else if let tx = n.object as? ETHUnconfirmedTransaction, self.tokenInfo.id == tx.erc20ContractAddress {
                self.transactions.accept(self.genViewModels())
                self.hasMore.accept(self.hasMore.value)
            }
        }.disposed(by: disposeBag)
        GCD.delay(5) { self.loopFetch() }
    }

    func update(account: ETHAccount) {
        self.account = account
        txs.removeAll()
        transactions.accept([])
        hasMore.accept(false)
        page = 1
        loadingStatus = .no
    }

    func refreshList(_ completion: @escaping (Error?) -> Void) {
        guard loadingStatus == .no else { return }
        loadingStatus = .refresh
        page = 1
        txs.removeAll()
        getTransactions(completion: completion)
    }

    func getMore(_ completion: @escaping (Error?) -> Void) {
        guard loadingStatus == .no else { return }
        loadingStatus = .more
        page += 1
        getTransactions(completion: completion)
    }

    func genViewModels() -> [ETHTransactionViewModel] {
        let all = self.tokenInfo.isEtherCoin ?
            ETHUnconfirmedManager.instance.ethUnconfirmedTransactions() :
            ETHUnconfirmedManager.instance.erc20UnconfirmedTransactions(for: self.tokenInfo.ethContractAddress)

        var unconfirmed = [ETHUnconfirmedTransaction]()
        var confirmed = [ETHUnconfirmedTransaction]()

        for tx in all {
            if tx.nonce < self.transactionCount {
                confirmed.append(tx)
            } else {
                unconfirmed.append(tx)
            }
        }
        ETHUnconfirmedManager.instance.remove(confirmed)
        return unconfirmed.map { ETHTransactionViewModel(unconfirmed: $0, isShowingInEthList: tokenInfo.isEtherCoin) } +
            self.txs.map { ETHTransactionViewModel(transaction: $0) }
    }

    private func loopFetch() {
        let address = self.address
        let getNonce = account.getTransactionCountPromise()
        when(fulfilled: fetch(page: page), getNonce).done { [weak self] (transactions, transactionCount) in
            guard let `self` = self else { return }
            guard address == self.address else { return }

            self.transactionCount = transactionCount
            var txs = [ETHTransaction]()
            var set: Set<String> = Set()
            transactions.forEach { (t) in
                if !set.contains(t.hash) {
                    txs.append(t)
                    set.insert(t.hash)
                }
            }

            if let minTx = transactions.last {
                var current = BigInt(minTx.blockNumber)! + BigInt(minTx.confirmations)!
                for var tx in self.txs where !set.contains(tx.hash) {
                    tx.update(confirmations: current - BigInt(tx.blockNumber)!)
                    txs.append(tx)
                    set.insert(tx.hash)
                }
            }

            self.txs = txs
            self.transactions.accept(self.genViewModels())
            self.hasMore.accept(self.hasMore.value)
        }.catch { _ in }.finally { [weak self] in
            GCD.delay(5) { [weak self] in
                self?.loopFetch()
            }
        }
    }

    private func fetch(page: Int) -> Promise<[ETHTransaction]> {
        let promise: Promise<[ETHTransaction]>
        if tokenInfo.isEtherCoin {
            promise = UnifyProvider.eth.getEtherTransactions(address: address, page: page, limit: limit)
        } else {
            promise = UnifyProvider.eth.getErc20Transactions(address: address, tokenInfo: tokenInfo, page: page, limit: limit)
        }
        return promise
    }

    private func getTransactions(completion: @escaping (Error?) -> Void) {
        let address = self.address
        let getNonce = page == 1 ? account.getTransactionCountPromise() : Promise.value(transactionCount)
        when(fulfilled: fetch(page: page), getNonce).done { [weak self] (transactions, transactionCount) in
            guard let `self` = self else { return }
            guard address == self.address else { return }
            self.transactionCount = transactionCount
            var set = Set(self.txs.map { $0.hash })
            transactions.forEach { (t) in
                if !set.contains(t.hash) {
                    self.txs.append(t)
                    set.insert(t.hash)
                }
            }
            self.transactions.accept(self.genViewModels())
            self.hasMore.accept(transactions.count == self.limit)
            self.loadingStatus = .no
            completion(nil)
        }
        .catch { [weak self] (error) in
            guard let `self` = self else { return }
            self.loadingStatus = .no
            completion(error)
        }
    }
}
