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

    enum LoadingStatus {
        case no
        case refresh
        case more
    }

    lazy var transactionsDriver: Driver<[Tx]> = self.transactions.asDriver()
    let hasMore: BehaviorRelay<Bool>

    fileprivate let transactions: BehaviorRelay<[Tx]>

    fileprivate let disposeBag = DisposeBag()

    fileprivate let viewModels = NSMutableArray()
    fileprivate var index = 0
    fileprivate var hash: String?
    fileprivate var loadingStatus = LoadingStatus.no

    init(symbol:String) {
        transactions = BehaviorRelay<[Tx]>(value: viewModels as! [Tx])
        hasMore = BehaviorRelay<Bool>(value: false)
    }

    func update(address: ViteAddress) {
        viewModels.removeAllObjects()
        transactions.accept(viewModels as! [Tx])
        hasMore.accept(false)
        index = 0
        hash = nil
        loadingStatus = .no
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

        BnbWallet.shared.fetchTransactions(limit: .five, offset: 0, txAsset: "BNB",completion: {[weak self] transactions in
            guard let `self` = self else{
                return
            }
            self.viewModels.addObjects(from: transactions.tx)
            self.transactions.accept(self.viewModels as! [Tx])
            self.loadingStatus = .no
            completion(nil)
        })
    }
}

