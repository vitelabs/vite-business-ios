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

final class ETHTransactionListTableViewModel: TransactionListTableViewModelType {

    enum LoadingStatus {
        case no
        case refresh
        case more
    }

    lazy var transactionsDriver: Driver<[ETHTransactionViewModel]> = self.transactions.asDriver()
    let hasMore: BehaviorRelay<Bool>

    fileprivate let transactions: BehaviorRelay<[ETHTransactionViewModel]>
    fileprivate var address: String
    fileprivate let tokenInfo: TokenInfo
    fileprivate let disposeBag = DisposeBag()

    fileprivate let viewModels = NSMutableArray()
    fileprivate var page = 1
    fileprivate var loadingStatus = LoadingStatus.no

    fileprivate let limit = 20

    init(address: String, tokenInfo: TokenInfo) {
        self.address = address
        self.tokenInfo = tokenInfo
        transactions = BehaviorRelay<[ETHTransactionViewModel]>(value: viewModels as! [ETHTransactionViewModel])
        hasMore = BehaviorRelay<Bool>(value: false)
    }

    func update(address: String) {
        self.address = address
        viewModels.removeAllObjects()
        transactions.accept(viewModels as! [ETHTransactionViewModel])
        hasMore.accept(false)
        page = 1
        loadingStatus = .no
    }

    func refreshList(_ completion: @escaping (Error?) -> Void) {
        guard loadingStatus == .no else { return }
        loadingStatus = .refresh
        page = 1
        viewModels.removeAllObjects()
        getTransactions(completion: completion)
    }

    func getMore(_ completion: @escaping (Error?) -> Void) {
        guard loadingStatus == .no else { return }
        loadingStatus = .more
        page += 1
        getTransactions(completion: completion)
    }

    private func getTransactions(completion: @escaping (Error?) -> Void) {

        let address = self.address
        let promise: Promise<[ETHTransaction]>
        if tokenInfo.isEtherCoin {
            promise = UnifyProvider.eth.getEtherTransactions(address: address, page: page, limit: limit)
        } else {
            promise = UnifyProvider.eth.getErc20Transactions(address: address, tokenInfo: tokenInfo, page: page, limit: limit)
        }

        promise.done { [weak self] (transactions) in
            guard let `self` = self else { return }
            guard address == self.address else { return }

            var set = Set(self.viewModels.map { ($0 as! ETHTransactionViewModel).hash })
            transactions.forEach { (t) in
                if !set.contains(t.hash) {
                    self.viewModels.add(ETHTransactionViewModel(transaction: t))
                    set.insert(t.hash)
                }
            }

            self.transactions.accept(self.viewModels as! [ETHTransactionViewModel])
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
