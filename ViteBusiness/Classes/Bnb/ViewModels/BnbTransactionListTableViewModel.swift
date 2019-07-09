//
//  BnbTransactionListTableViewModel.swift
//  ViteBusiness
//
//  Created by Water on 2019/7/3.
//

import Foundation
import ViteWallet
import RxSwift
import RxCocoa
import BinanceChain

final class BnbTransactionListTableViewModel {
    fileprivate var symbol : String
    enum LoadingStatus {
        case no
        case refresh
        case more
    }

    lazy var transactionsDriver: Driver<[Tx]> = self.transactions.asDriver()
    fileprivate let transactions: BehaviorRelay<[Tx]>

    fileprivate let disposeBag = DisposeBag()

    fileprivate let viewModels = NSMutableArray()
    fileprivate var index = 0
    let hasMore: BehaviorRelay<Bool>
    fileprivate var loadingStatus = LoadingStatus.no


    init(symbol:String) {
        self.symbol = symbol
        transactions = BehaviorRelay<[Tx]>(value: viewModels as! [Tx])
        hasMore = BehaviorRelay<Bool>(value: false)
    }

    func update() {
        viewModels.removeAllObjects()
        transactions.accept(viewModels as! [Tx])
        hasMore.accept(false)
        index = 0
        loadingStatus = .no
    }

    func refreshList(_ completion: @escaping (Error?) -> Void) {
        guard loadingStatus == .no else { return }
        loadingStatus = .refresh
        index = 0
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

        BnbWallet.shared.fetchTransactions(limit: .ten, offset: index * Limit.ten.rawValue, txAsset: self.symbol ,completion: {[weak self] transactions , e in
            guard let `self` = self else{
                return
            }
            if let error = e {
                completion(error)
                return
            }
            self.viewModels.addObjects(from: transactions.tx)
            self.transactions.accept(self.viewModels as! [Tx])

            if self.viewModels.count >= transactions.total{
               self.hasMore.accept(false)
            }else {
               self.hasMore.accept(true)
            }
            self.loadingStatus = .no
            completion(nil)
        })
    }
}

