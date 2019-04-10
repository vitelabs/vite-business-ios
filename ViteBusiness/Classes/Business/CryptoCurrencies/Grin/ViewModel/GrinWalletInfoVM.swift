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

    let grinManager = GrinManager.default
    let action = PublishSubject<GrinWalletInfoVM.Action>()
    
    lazy var txsDriver: Driver<[TxLogEntry]> = self.txs.asDriver()
    lazy var balanceDriver: Driver<GrinBalance> = self.balance.asDriver()
    lazy var messageDriver: Driver<String?> = self.message.asDriver()
    let txs = BehaviorRelay<[TxLogEntry]>(value: [])
    let balance = BehaviorRelay<GrinBalance>(value: GrinBalance())
    let message: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let showLoading: BehaviorRelay<Bool> = BehaviorRelay(value: false)


    private let bag = DisposeBag()

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
    }


    func checkWallet() {
        self.showLoading.accept(true)
        grin_async({ () in
            self.grinManager.walletRestore()
        },  { (result) in
            self.showLoading.accept(false)
            switch result {
            case .success:
                self.action.onNext(.getBalance(manually: true))
            case .failure(let error):
                self.message.accept(error.message)
            }
        })
    }

    func getBalance(_ manually: Bool) {
        grin_async({ () in
            self.grinManager.walletInfo(refreshFromNode: true)
        },  { (result) in
            switch result {
            case .success(let info):
                self.balance.accept(GrinBalance(info))
            case .failure(let error):
                if manually { self.message.accept(error.message) }
            }
        })
    }

    func getTxs(_ manually: Bool) {
        grin_async({ () in
            self.grinManager.txsGet(refreshFromNode: true)
        },  { (result) in
            switch result {
            case .success((_, let txs)):
                self.txs.accept(txs.reversed())
            case .failure(let error):
                if manually { self.message.accept(error.message) }
            }
        })
    }

    func cancel(_ tx: TxLogEntry) {
        grin_async({ () in
            return self.grinManager.txCancel(id: UInt32(tx.id))
        },  { (result) in
            switch result {
            case .success(_):
                self.action.onNext(.getBalance(manually: false))
                GrinTxByViteService().reportFinalization(slateId: tx.txSlateId ?? "")
                    .done { }
            case .failure(let error):
                self.message.accept(error.message)
            }
        })
    }

    func repost(_ tx: TxLogEntry) {
        grin_async({ () in
            self.grinManager.txRepost(txId: UInt32(tx.id))
        },  { (result) in
            switch result {
            case .success(_):
                self.action.onNext(.getBalance(manually: false))
            case .failure(let error):
                self.message.accept(error.message)
            }
        })
    }
}

