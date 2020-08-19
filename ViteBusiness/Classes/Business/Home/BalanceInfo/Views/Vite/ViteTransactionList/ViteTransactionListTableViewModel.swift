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

final class ViteTransactionListTableViewModel: TransactionListTableViewModelType {

    enum LoadingStatus {
        case no
        case refresh
        case more
    }

    lazy var transactionsDriver: Driver<[TransactionViewModelType]> = self.transactions.asDriver()
    let hasMore: BehaviorRelay<Bool>

    fileprivate let transactions: BehaviorRelay<[TransactionViewModelType]>
    fileprivate var address: ViteAddress
    fileprivate let token: Token
    fileprivate let disposeBag = DisposeBag()

    fileprivate let viewModels = NSMutableArray()
    fileprivate var index = 0
    fileprivate var hash: String?
    fileprivate var loadingStatus = LoadingStatus.no

    init(address: ViteAddress, token: Token) {
        self.address = address
        self.token = token
        transactions = BehaviorRelay<[TransactionViewModelType]>(value: viewModels as! [TransactionViewModelType])
        hasMore = BehaviorRelay<Bool>(value: false)

        NotificationCenter.default.rx.notification(.ViteChainSendSuccess).bind { [weak self] (n) in
            if let tokenId = n.object as? String, self?.token.id == tokenId {
                GCD.delay(2) { [weak self] in
                    self?.fetch(loop: false)
                }
            }
        }.disposed(by: disposeBag)
        GCD.delay(5) { self.fetch(loop: true) }
    }

    func update(address: ViteAddress) {
        self.address = address
        viewModels.removeAllObjects()
        transactions.accept(viewModels as! [TransactionViewModelType])
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

    private func fetch(loop: Bool) {
        let address = self.address
        ViteNode.ledger.getAccountBlocks(address: address, tokenId: token.id, hash: nil, count: 10)
            .done { [weak self] (accountBlocks, nextHash) in
                guard let `self` = self else { return }
                guard address == self.address else { return }

                var txs = [AccountBlock]()

                if let last = accountBlocks.last {
                    txs.append(contentsOf: accountBlocks)

                    if let first = self.transactions.value.first as? AccountBlock, last.height! - 1 <= first.height! {

                        for item in self.transactions.value {
                            if var i = item as? AccountBlock, i.height! < last.height! {
                                let current = last.height! + last.confirmations!
                                i.update(confirmations: current - i.height!)
                                txs.append(i)
                            }
                        }
                        // nextHash not changed
                    } else {
                        self.hash = nextHash
                    }

                } else {
                    self.hash = nextHash
                }

                self.viewModels.removeAllObjects()
                self.viewModels.addObjects(from: txs)
                self.transactions.accept(self.viewModels as! [TransactionViewModelType])
                self.hasMore.accept(nextHash != nil)

            }.catch { _ in }.finally { [weak self] in
                if loop {
                    GCD.delay(5) { [weak self] in
                        self?.fetch(loop: true)
                    }
                }
            }
    }

    private func getTransactions(completion: @escaping (Error?) -> Void) {

        let address = self.address
        ViteNode.ledger.getAccountBlocks(address: address, tokenId: token.id, hash: hash, count: 10)
            .done { [weak self] (accountBlocks, nextHash) in
                guard let `self` = self else { return }
                guard address == self.address else { return }

                self.hash = nextHash
                self.viewModels.addObjects(from: accountBlocks)
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
