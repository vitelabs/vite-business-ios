//
//  AutoGatheringManager.swift
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
import JSONRPCKit

import enum Alamofire.Result

final class AutoGatheringManager {
    static let instance = AutoGatheringManager()
    private init() {}

    fileprivate let disposeBag = DisposeBag()
    fileprivate var service: ReceiveAllTransactionService?

    func start() {
        HDWalletManager.instance.accountDriver.drive(onNext: { (account) in
            if let account = account {

                plog(level: .debug, log: "start receive for \(account.address)", tag: .transaction)
                let service = ReceiveAllTransactionService(accounts: [account], interval: 5, completion: { (r) in
                    switch r {
                    case .success(let ret):
                        plog(level: .debug, log: "success for receive \(ret.count) blocks", tag: .transaction)
                    case .failure(let error):
                        plog(level: .warning, log: "getOnroad for \(account.address) error: \(error.viteErrorMessage)", tag: .transaction)
                    }
                })
                service.startPoll()
                self.service = service
            } else {
                self.service?.stopPoll()
                self.service = nil
//                plog(level: .debug, log: "stop receive", tag: .transaction)
            }
        }).disposed(by: disposeBag)
    }
}

extension AutoGatheringManager {

    class ReceiveAllTransactionService: PollService {
        typealias Ret = Result<[(AccountBlock, AccountBlock, Wallet.Account)]>

        public let accounts: [Wallet.Account]
        public init(accounts: [Wallet.Account], interval: TimeInterval, completion: ((Ret) -> ())? = nil) {
            self.accounts = accounts
            self.interval = interval
            self.completion = completion
        }

        public var taskId: String = ""
        public var isPolling: Bool = false
        public var interval: TimeInterval = 0
        public var completion: ((Ret) -> ())?

        public func handle(completion: @escaping (Ret) -> ()) {
            let accounts = self.accounts

            type(of: self).getFirstOnroadIfHas(for: accounts)
                .map({ accountBlocks -> [(AccountBlock, Wallet.Account)] in
                    var ret: [(AccountBlock, Wallet.Account)] = []
                    let array = accountBlocks.compactMap { $0 }
                    for accountBlock in array {
                        for account in accounts where accountBlock.toAddress == account.address {
                            ret.append((accountBlock, account))
                        }
                    }
                    return ret
                }).then({ pairs -> Promise<[(AccountBlock, AccountBlock, Wallet.Account)]> in
                    let promises = pairs.map { ret -> Promise<(AccountBlock, AccountBlock, Wallet.Account)?> in
                        return type(of: self).receive(onroadBlock: ret.0, account: ret.1)
                            .map({ (ret) -> (AccountBlock, AccountBlock, Wallet.Account)? in
                                return (ret.0, ret.1, ret.2)
                            })
                            // ignore error, and return nil
                            .recover({ (error) -> Promise<(AccountBlock, AccountBlock, Wallet.Account)?> in
                                plog(level: .warning, log: ret.1.address + " receive error: " + error.viteErrorMessage, tag: .transaction)
                                return .value(nil)
                            })
                    }
                    return when(fulfilled: promises)
                        // filter nil，make sure when promise success
                        .map({ (ret) -> [(AccountBlock, AccountBlock, Wallet.Account)] in
                            return ret.compactMap { $0 }
                        })
                }).done({ (ret) in
                    completion(Result.success(ret))
                }).catch({ (error) in
                    completion(Result.failure(error))
                })
        }

        static func receive(onroadBlock: AccountBlock, account: Wallet.Account) -> Promise<(AccountBlock, AccountBlock, Wallet.Account)> {
            return ViteNode.rawTx.receive.prepare(account: account, onroadBlock: onroadBlock)
                .then({ (context) -> Promise<ReceiveBlockContext> in
                    if context.isNeedToCalcPoW {
                        return ViteNode.rawTx.receive.getPow(context: context)
                    } else {
                        return Promise.value(context)
                    }
                })
                .then({ (context) -> Promise<AccountBlock> in
                    return ViteNode.rawTx.receive.context(context)
                })
                .map({ (block) -> (AccountBlock, AccountBlock, Wallet.Account) in
                    return (onroadBlock, block, account)
                })
        }

        static func getFirstOnroadIfHas(for accounts: [Wallet.Account]) -> Promise<[AccountBlock?]> {
            let requests = accounts.map { GetOnroadBlocksRequest(address: $0.address, index: 0, count: 1) }
            return RPCRequest(for: Provider.default.server, batch: BatchFactory().create(requests)).promise
                .map { accountBlocksArray -> [AccountBlock?] in
                    return accountBlocksArray.map { $0.first }
            }
        }
    }
}
