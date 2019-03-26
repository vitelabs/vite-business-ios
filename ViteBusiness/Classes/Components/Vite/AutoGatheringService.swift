//
//  AutoGatheringService.swift
//  Vite
//
//  Created by Stone on 2018/9/14.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import ViteWallet
import PromiseKit
import RxSwift
import RxCocoa

final class AutoGatheringService {
    static let instance = AutoGatheringService()
    private init() {}

    fileprivate let disposeBag = DisposeBag()
    fileprivate var service: ReceiveTransactionService?

    func start() {
        HDWalletManager.instance.accountDriver.drive(onNext: { [weak self] account in
            guard let `self` = self else { return }
            if let account = account {
                plog(level: .debug, log: account.address.description + ": " + "start receive", tag: .transaction)
                let service = ReceiveTransactionService(account: account, interval: 2) { r in
                    switch r {
                    case .success(let a):
                        if let accountBlock = a {
                            plog(level: .debug, log: account.address.description + ": " + "receive block hash: \(accountBlock.hash!)", tag: .transaction)
                        } else {
                            plog(level: .debug, log: account.address.description + ": " + "no need to receive", tag: .transaction)
                        }
                    case .failure(let error):
                        plog(level: .warning, log: account.address.description + ": " + error.viteErrorMessage, tag: .transaction)
                    }
                }
                service.startPoll()
                self.service = service
            } else {
                plog(level: .debug, log: "stop receive", tag: .transaction)
                self.service = nil
            }
        }).disposed(by: disposeBag)
    }
}
