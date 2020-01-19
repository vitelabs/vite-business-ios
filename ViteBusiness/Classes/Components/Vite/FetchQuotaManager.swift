//
//  FetchQuotaManager.swift
//  Vite
//
//  Created by Stone on 2018/10/26.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import ViteWallet
import PromiseKit
import RxSwift
import RxCocoa
import RxOptional
import ObjectMapper

extension FetchQuotaManager: Storageable {
    public func getStorageConfig() -> StorageConfig {
        return StorageConfig(name: "PledgeQuota", path: .wallet, appending: self.currentAddress)
    }

    public struct Storage: Mappable {
        public fileprivate(set) var quota = Quota()
        public fileprivate(set) var pledgeAmount = Amount()

        public init?(map: Map) {}

        init(quota: Quota, pledgeAmount: Amount) {
            self.quota = quota
            self.pledgeAmount = pledgeAmount
        }

        public mutating func mapping(map: Map) {
            quota <- map["quota"]
            pledgeAmount <- (map["pledgeAmount"], JSONTransformer.bigint)
        }
    }
}

final class FetchQuotaManager {

    static let instance = FetchQuotaManager()
    private init() {}

    lazy var  quotaDriver: Driver<Quota> = self.quotaBehaviorRelay.asDriver()
    lazy var  pledgeAmountDriver: Driver<Amount> = self.pledgeAmountBehaviorRelay.asDriver()
    fileprivate var quotaBehaviorRelay: BehaviorRelay<Quota> = BehaviorRelay(value: Quota())
    fileprivate var pledgeAmountBehaviorRelay: BehaviorRelay<Amount> = BehaviorRelay(value: Amount())

    fileprivate let disposeBag = DisposeBag()
    fileprivate var currentAddress = "noAddress"

    fileprivate var service: FetchPledgeQuotaService?
    fileprivate var retainCount = 0

    fileprivate var balanceDisposable: Disposable?
    fileprivate var lastViteBalance: Amount?

    func start() {
        HDWalletManager.instance.accountDriver.drive(onNext: { [weak self] a in
            guard let `self` = self else { return }
            self.balanceDisposable?.dispose()

            if let account = a {
                self.currentAddress = account.address
                self.lastViteBalance = nil
                if let storage: Storage = self.readMappable() {
                    self.quotaBehaviorRelay.accept(storage.quota)
                    self.pledgeAmountBehaviorRelay.accept(storage.pledgeAmount)
                } else {
                    self.quotaBehaviorRelay.accept(Quota())
                    self.pledgeAmountBehaviorRelay.accept(Amount(0))
                }

                let address = account.address
                let service = FetchPledgeQuotaService(address: address, interval: 5, completion: { [weak self] (r) in
                    guard let `self` = self else { return }

                    switch r {
                    case .success(let quota):
                        //plog(level: .debug, log: address + ": " + "currentUt \(String(quota.currentUt))", tag: .transaction)

                        self.quotaBehaviorRelay.accept(quota)
                        self.save(mappable: Storage(quota: self.quotaBehaviorRelay.value, pledgeAmount: self.pledgeAmountBehaviorRelay.value))
                    case .failure(let error):
                        plog(level: .warning, log: address + ": " + error.viteErrorMessage, tag: .transaction)
                    }
                })

                if self.retainCount > 0 {
                    //plog(level: .debug, log: "start fetch quota", tag: .transaction)
                    service.startPoll()
                }

                self.service = service

                self.balanceDisposable = ViteBalanceInfoManager.instance.balanceInfoDriver(forViteTokenId: ViteWalletConst.viteToken.id).drive(onNext: { [weak self] (balanceInfo) in
                    let amount = balanceInfo?.balance ?? Amount(0)
                    guard let `self` = self else { return }
                    guard self.currentAddress == address else { return }
                    guard self.lastViteBalance != amount else { return }
                    GCD.delay(2, task: {
                        ViteNode.pledge.info.getPledgeDetail(address: address, index: 0, count: 0)
                            .done({ (detail) in
                                guard self.currentAddress == address else { return }
                                self.lastViteBalance = amount
                                self.pledgeAmountBehaviorRelay.accept(detail.totalPledgeAmount)
                                self.save(mappable: Storage(quota: self.quotaBehaviorRelay.value, pledgeAmount: self.pledgeAmountBehaviorRelay.value))
                            })
                            .catch({ (error) in
                                plog(level: .warning, log: address + ": " + error.viteErrorMessage, tag: .transaction)
                            })
                    })
                })

            } else {
                self.service = nil
            }

        }).disposed(by: disposeBag)
    }

    func retainQuota() {
        retainCount += 1
        //plog(level: .debug, log: "retainCount: \(self.retainCount)", tag: .transaction)

        guard let service = self.service else { return }

        if service.isPolling == false {
            //plog(level: .debug, log: "start fetch quota", tag: .transaction)
            service.startPoll()
        }
    }

    func releaseQuota() {
        retainCount = max(0, retainCount - 1)
        //plog(level: .debug, log: "retainCount: \(self.retainCount)", tag: .transaction)
        if retainCount == 0 {
            //plog(level: .debug, log: "stop fetch quota", tag: .transaction)
            self.service?.stopPoll()
        }
    }
}
