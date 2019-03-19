//
//  GrinWalletInfoVM.swift
//  Action
//
//  Created by haoshenyang on 2019/3/8.
//

import UIKit
import RxSwift
import RxCocoa
import Vite_GrinWallet
import ReactorKit

final class GrinWalletInfoVM {

    enum Action {
        case getBalance(manually: Bool)
        case getTxs(manually: Bool)
        case checkWallet
        case cancel(TxLogEntry)
        case repost(TxLogEntry)
    }

    let action = PublishSubject<GrinWalletInfoVM.Action>()
    
    lazy var txsDriver: Driver<[TxLogEntry]> = self.txs.asDriver()
    lazy var balanceDriver: Driver<GrinBalance> = self.balance.asDriver()
    lazy var errorMessageDriver: Driver<String?> = self.errorMessage.asDriver()

    let txs = BehaviorRelay<[TxLogEntry]>(value: [])
    let balance = BehaviorRelay<GrinBalance>(value: GrinBalance())
    let errorMessage: BehaviorRelay<String?> = BehaviorRelay(value: nil)

    private let bag = DisposeBag()

    private var grinBridge: GrinManager {
        return GrinManager.default
    }

    init() {

        action.asObservable()
            .subscribe(onNext: { [weak self] (action) in
                switch action {
                case .checkWallet:
                    self?.checkWallet()
                case .getBalance(let manually):
                    self?.getBalance(manually)
                case .getTxs(let manually):
                    self?.getTxs(manually)
                case .cancel(let tx):
                    self?.cancel(tx)
                case .repost(let tx):
                    self?.repost(tx)
                }

        })
        .disposed(by: bag)

         Observable<Int>.interval(30, scheduler: MainScheduler.asyncInstance)
            .map { _ in Action.getBalance(manually: false) }
            .bind(to: self.action)
            .disposed(by: bag)
        balance.asObservable()
            .skip(1)
            .distinctUntilChanged { $0.amountCurrentlySpendable == $1.amountCurrentlySpendable }
            .map { _ in  Action.getTxs(manually: false) }
            .bind(to: self.action)
            .disposed(by: bag)

        self.action.onNext(.getBalance(manually: true))
        self.action.onNext(.getTxs(manually: true))
    }


    func checkWallet() {
        let result = self.grinBridge.walletCheck()
        switch result {
        case .success:
            break
        case .failure(let error):
            errorMessage.accept(error.message)
        }
    }

    func getBalance(_ manually: Bool) {
        let result = self.grinBridge.walletInfo(refreshFromNode: true)
            switch result {
            case .success(let info):
                self.balance.accept(GrinBalance(info))
            case .failure(let error):
                if manually { self.errorMessage.accept(error.message) }
        }

    }

    func getTxs(_ manually: Bool) {
        let result = self.grinBridge.txsGet(refreshFromNode: false)
            switch result {
            case .success((_, let txs)):
                self.txs.accept(txs)
            case .failure(let error):
                if manually { self.errorMessage.accept(error.message) }
            }
    }

    func cancel(_ tx: TxLogEntry) {
        let cancleResult = grinBridge.txCancel(id: UInt32(tx.id))
        switch cancleResult {
        case .success(_):
            self.action.onNext(.getBalance(manually: false))
            self.action.onNext(.getBalance(manually: false))
        case .failure(let error):
            errorMessage.accept(error.message)
        }
    }

    func repost(_ tx: TxLogEntry) {
        let repostResult = grinBridge.txRepost(txId: UInt32(tx.id))
        switch repostResult {
        case .success(_):
            self.action.onNext(.getBalance(manually: false))
            self.action.onNext(.getBalance(manually: false))
        case .failure(let error):
            errorMessage.accept(error.message)
        }
    }
}

