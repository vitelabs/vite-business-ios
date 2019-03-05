//
//  TransactionListTableViewModel.swift
//  Vite
//
//  Created by Stone on 2018/9/11.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import ViteWallet
import RxSwift
import RxCocoa

final class TransactionListTableViewModel: TransactionListTableViewModelType {

    enum LoadingStatus {
        case no
        case refresh
        case more
    }

    lazy var transactionsDriver: Driver<[TransactionViewModelType]> = self.transactions.asDriver()
    let hasMore: BehaviorRelay<Bool>

    fileprivate let transactions: BehaviorRelay<[TransactionViewModelType]>
    fileprivate let address: Address
    fileprivate let token: Token
    fileprivate let disposeBag = DisposeBag()

    fileprivate let viewModels = NSMutableArray()
    fileprivate var index = 0
    fileprivate var hash: String?
    fileprivate var loadingStatus = LoadingStatus.no

    init(address: Address, token: Token) {
        self.address = address
        self.token = token
        transactions = BehaviorRelay<[TransactionViewModelType]>(value: viewModels as! [TransactionViewModelType])
        hasMore = BehaviorRelay<Bool>(value: false)
    }

    func refreshList(_ completion: @escaping (Error?) -> Void) {
        guard loadingStatus == .no else { return }
        loadingStatus = .refresh
        index = 0
        hash = nil
        viewModels.removeAllObjects()
        getTransactions(completion: completion)
    }

    func getMore(_ completion: @escaping (Error?) -> Void) {
        guard loadingStatus == .no else { return }
        loadingStatus = .more
        index += 1
        getTransactions(completion: completion)
    }

    private func getTransactions(completion: @escaping (Error?) -> Void) {

        Provider.default.getTokenTransactions(address: address, hash: hash, tokenId: token.id, count: 10)
            .done { [weak self] (transactions, nextHash) in
                guard let `self` = self else { return }
                self.hash = nextHash
                self.viewModels.addObjects(from: transactions.map {
                    TransactionViewModel(transaction: $0)
                })
                self.transactions.accept(self.viewModels as! [TransactionViewModelType])
                self.hasMore.accept(nextHash != nil)
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
