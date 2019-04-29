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

extension FetchQuotaManager: Storageable {
    public func getStorageConfig() -> StorageConfig {
        return StorageConfig(name: "PledgeQuota", path: .wallet, appending: self.appending)
    }
}

final class FetchQuotaManager {

    static let instance = FetchQuotaManager()
    private init() {}

    lazy var  quotaDriver: Driver<Quota> = self.quotaBehaviorRelay.asDriver()
    fileprivate var quotaBehaviorRelay: BehaviorRelay<Quota> = BehaviorRelay(value: Quota())

    fileprivate let disposeBag = DisposeBag()
    fileprivate var appending = "noAddress"

    fileprivate var service: FetchPledgeQuotaService?
    fileprivate var retainCount = 0

    func start() {
        HDWalletManager.instance.accountDriver.drive(onNext: { [weak self] a in
            guard let `self` = self else { return }

            if let account = a {
                self.appending = account.address
                if let quota: Quota = self.readMappable() {
                    self.quotaBehaviorRelay.accept(quota)
                }

                let address = account.address
                let service = FetchPledgeQuotaService(address: address, interval: 5, completion: { [weak self] (r) in
                    guard let `self` = self else { return }

                    switch r {
                    case .success(let quota):
                        plog(level: .debug, log: address + ": " + "utps \(String(quota.utps))", tag: .transaction)

                        self.quotaBehaviorRelay.accept(quota)
                        self.save(mappable: quota)
                    case .failure(let error):
                        plog(level: .warning, log: address + ": " + error.viteErrorMessage, tag: .transaction)
                    }
                })

                if self.retainCount > 0 {
                    plog(level: .debug, log: "start fetch quota", tag: .transaction)
                    service.startPoll()
                }

                self.service = service
            } else {
                self.service = nil
            }

        }).disposed(by: disposeBag)
    }

    func retainQuota() {
        retainCount += 1
        plog(level: .debug, log: "retainCount: \(self.retainCount)", tag: .transaction)

        guard let service = self.service else { return }

        if service.isPolling == false {
            plog(level: .debug, log: "start fetch quota", tag: .transaction)
            service.startPoll()
        }
    }

    func releaseQuota() {
        retainCount = max(0, retainCount - 1)
        plog(level: .debug, log: "retainCount: \(self.retainCount)", tag: .transaction)
        if retainCount == 0 {
            plog(level: .debug, log: "stop fetch quota", tag: .transaction)
            self.service?.stopPoll()
        }
    }
}
