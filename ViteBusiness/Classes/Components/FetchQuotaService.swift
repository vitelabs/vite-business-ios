//
//  FetchQuotaService.swift
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
import ViteUtils

final class FetchQuotaService {

    static let instance = FetchQuotaService()
    private init() {}

    lazy var  quotaDriver: Driver<String> = self.quotaBehaviorRelay.asDriver()
    lazy var  maxTxCountDriver: Driver<String> = self.maxTxCountBehaviorRelay.asDriver()
    fileprivate var quotaBehaviorRelay: BehaviorRelay<String> = BehaviorRelay(value: "0")
    fileprivate var maxTxCountBehaviorRelay: BehaviorRelay<String> = BehaviorRelay(value: "0")

    fileprivate let disposeBag = DisposeBag()
    fileprivate var fileHelper: FileHelper! = nil

    fileprivate var service: ViteWallet.FetchPledgeQuotaService?
    fileprivate var retainCount = 0

    fileprivate enum Key: String {
        case fileName = "PledgeQuota"
        case quota
        case maxTxCount
    }

    func start() {
        HDWalletManager.instance.bagDriver.drive(onNext: { [weak self] a in
            guard let `self` = self else { return }

            if let account = a {
                self.fileHelper = FileHelper(.library, appending: "\(FileHelper.accountPathComponent)/\(account.address.description)")
                if let data = self.fileHelper.contentsAtRelativePath(Key.fileName.rawValue),
                    let dic = try? JSONSerialization.jsonObject(with: data) as? [String: String],
                    let quota = dic?[Key.quota.rawValue],
                    let maxTxCount = dic?[Key.maxTxCount.rawValue] {
                    self.quotaBehaviorRelay.accept(quota)
                    self.maxTxCountBehaviorRelay.accept(maxTxCount)
                }

                let address = account.address
                let service = ViteWallet.FetchPledgeQuotaService(address: address, interval: 5, completion: { [weak self] (r) in
                    guard let `self` = self else { return }

                    switch r {
                    case .success(let (quota, maxTxCount)):
                        plog(level: .debug, log: address.description + ": " + "quota \(String(quota)) \(String(maxTxCount))", tag: .transaction)

                        self.quotaBehaviorRelay.accept(String(quota))
                        self.maxTxCountBehaviorRelay.accept(String(maxTxCount))

                        let dic = [Key.quota.rawValue: String(quota), Key.maxTxCount.rawValue: String(maxTxCount)]
                        if let data = try? JSONSerialization.data(withJSONObject: dic) {
                            if let error = self.fileHelper.writeData(data, relativePath: Key.fileName.rawValue) {
                                assert(false, error.localizedDescription)
                            }
                        }
                    case .failure(let error):
                        plog(level: .warning, log: address.description + ": " + error.message, tag: .transaction)
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
