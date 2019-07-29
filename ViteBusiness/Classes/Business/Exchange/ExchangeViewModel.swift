//
//  ExchangeViewModel.swift
//  Action
//
//  Created by haoshenyang on 2019/7/26.
//

import Foundation
import RxSwift
import RxCocoa

class ExchangeViewModel {

    enum Action {
        case getRate
        case getHistory(pageSize: Int, pageNumber: Int)
        case report(hash: String)
    }

    let action = PublishSubject<ExchangeViewModel.Action>()

    
    let txs = BehaviorRelay<[Exchangeprovider.HistoryInfo]>(value: [])
    let rateInfo = BehaviorRelay<Exchangeprovider.RateInfo>(value: Exchangeprovider.RateInfo())
    let exchangeResult = PublishSubject<Exchangeprovider.ExchangeResult>()
    let message: PublishSubject<String> = PublishSubject<String>()
    let showLoading: BehaviorRelay<Bool> = BehaviorRelay(value: false)


    fileprivate let exProvider = Exchangeprovider()

    private let bag = DisposeBag()


    init() {
        action.asObservable()
            .subscribe(onNext: { [weak self] (action) in
                switch action {
                case .getRate:
                    self?.getRate()
                case .getHistory(let pageSize, let pageNum):
                    self?.getHistory(pageSize: 10, pageNumber: 1)
                case .report(let hash):
                    self?.report(hash: hash)
                }
            })
            .disposed(by: bag)
    }


    func getRate() {
        guard let address = HDWalletManager.instance.account?.address else {
            return
        }
        exProvider
            .getRate(for: address) { [weak self] result in
                guard let `self` = self else { return }
                switch result {
                case .success(let r):
                    self.rateInfo.accept(r)
                case .failure(let e):
                    self.message.onNext(e.localizedDescription)
                }
        }
    }

    func getHistory(pageSize: Int, pageNumber: Int) {
        guard let address = HDWalletManager.instance.account?.address else {
            return
        }
        exProvider
            .getHistory(address: address, market: "eth_vite", pageSize: pageSize, pageNumber: pageNumber) { [weak self]  (result) in
                guard let `self` = self else { return }
                switch result {
                case .success(let r):
                    self.txs.accept(r)
                case .failure(let e):
                    self.message.onNext(e.localizedDescription)
                }
        }
    }

    func report(hash: String)  {
        guard let address = HDWalletManager.instance.account?.address else {
            return
        }
        exProvider
            .exchange(address: address, market:  "eth_vite", hash: hash) {  [weak self] (result) in
                guard let `self` = self else { return }
                switch result {
                case .success(let r):
                    self.exchangeResult.onNext(r)
                case .failure(let e):
                    self.message.onNext(e.localizedDescription)
                }
        }
    }

}
