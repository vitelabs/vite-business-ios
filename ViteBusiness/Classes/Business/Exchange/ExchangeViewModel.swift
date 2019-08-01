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
        case report(hash: String)
        
        case refreshHistory
        case getMoreHistory
    }

    let action = PublishSubject<ExchangeViewModel.Action>()
    
    let rateInfo = BehaviorRelay<Exchangeprovider.RateInfo>(value: Exchangeprovider.RateInfo())
    let exchangeResult = PublishSubject<Exchangeprovider.ExchangeResult>()
    let message: PublishSubject<String> = PublishSubject<String>()
    let showLoading: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    let txs = BehaviorRelay<[Exchangeprovider.HistoryInfo]>(value: [])
    let noMoreHistoryData: BehaviorRelay<Bool> = BehaviorRelay(value: false)


    fileprivate let exProvider = Exchangeprovider()

    private let bag = DisposeBag()

    let pageSize = 20
    var pageNum = 1


    init() {
        action.asObservable()
            .subscribe(onNext: { [weak self] (action) in
                switch action {
                case .getRate:
                    self?.getRate()
                case .report(let hash):
                    self?.report(hash: hash)
                case .refreshHistory:
                    self?.getHistory(isRefresh: true)
                case .getMoreHistory:
                    self?.getHistory(isRefresh: false)
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

    func getHistory(isRefresh: Bool) {
        guard let address = HDWalletManager.instance.account?.address else {
            return
        }
        if isRefresh {
            pageNum = 1
        } else {
            pageNum = pageNum + 1
        }
        exProvider
            .getHistory(address: address, market: "eth_vite", pageSize: pageSize, pageNumber: pageNum) { [weak self]  (result) in
                guard let `self` = self else { return }
                switch result {
                case .success(let r):
                    if isRefresh {
                        self.txs.accept(r)
                    } else {
                        var value = self.txs.value
                        value = value + r
                        self.txs.accept(value)
                    }
                    if r.isEmpty {
                        self.noMoreHistoryData.accept(true)
                    } else {
                        self.noMoreHistoryData.accept(false)
                    }
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
