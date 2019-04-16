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
import Vite_HDWalletKit

final class AutoGatheringService {
    static let instance = AutoGatheringService()
    private init() {}

    fileprivate let disposeBag = DisposeBag()
    fileprivate var service: ReceiveTransactionService?

    fileprivate var services: [ReceiveTransactionService] = []

    func start() {

        Driver.combineLatest(HDWalletManager.instance.walletDriver.filterNil().map({ $0.addressIndex }).distinctUntilChanged(),
                             HDWalletManager.instance.accountsDriver).drive(onNext: { [weak self] (currectIndex ,accounts) in
            guard let `self` = self else { return }

            self.services.forEach {
                $0.stopPoll()
            }
            self.services = []

            if accounts.isEmpty {
                plog(level: .debug, log: "stop receive", tag: .transaction)
            } else {
                for (index, account) in accounts.enumerated() {
                    let interval = (index == currectIndex || index == 0) ? 5 : 10
                    plog(level: .debug, log: account.address.description + ": " + "start receive interval \(interval)", tag: .transaction)
                    let service = ReceiveTransactionService(account: account, interval: TimeInterval(interval)) { r in
                        switch r {
                        case .success(let tuple):
                            if let (receive, send) = tuple {
                                if let data = receive.data {
                                    let bytes = Bytes(data)
                                    if bytes.count >= 2 && Bytes(bytes[0...1]) == Bytes(arrayLiteral: 0x80, 0x01) {
                                        GrinManager.default.handle(viteData: Data(bytes.dropFirst(2)), fromAddress: receive.fromAddress?.description ?? "", account: account)
                                    }
                                }

                                plog(level: .debug, log: account.address.description + ": " + "receive block hash: \(receive.hash!)", tag: .transaction)
                            } else {
                                plog(level: .debug, log: account.address.description + ": " + "no need to receive", tag: .transaction)
                            }
                        case .failure(let error):
                            plog(level: .warning, log: account.address.description + ": " + error.viteErrorMessage, tag: .transaction)
                        }
                    }
                    service.startPoll()
                    self.services.append(service)
                }
            }
        }).disposed(by: disposeBag)
    }
}
