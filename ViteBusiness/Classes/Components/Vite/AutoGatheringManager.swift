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
    fileprivate var service: NewReceiveTransactionService?

    func start() {
        Driver.combineLatest(HDWalletManager.instance.accountDriver,
                             HDWalletManager.instance.walletDriver.map({ wallet in wallet?.isAutoReceive ?? false })
        ).drive(onNext: { (account, isAutoReceive) in
            if let account = account, isAutoReceive {
                // stop old if has
                self.service?.stop()
                
                plog(level: .debug, log: "start receive for \(account.address)", tag: .onroad)
                let service = NewReceiveTransactionService(account: account)
                service.startIfNeeded()
                self.service = service
            } else {
                plog(level: .debug, log: "stop receive", tag: .onroad)
                self.service?.stop()
                self.service = nil
            }
        }).disposed(by: disposeBag)
    }
}

extension AutoGatheringManager {
    
    class NewReceiveTransactionService {
        
        public let account: Wallet.Account
        fileprivate var isRun = false
        init(account: Wallet.Account) {
            self.account = account
        }
        
        func startIfNeeded() {
            guard isRun == false else { return }
            isRun = true
            startGetOnroad()
        }
        
        func stop() {
            isRun = false
        }
        
        func hasQuotas() -> Bool {
            return (ViteBalanceInfoManager.instance.balanceInfo(forViteTokenId: TokenInfo.BuildIn.vite.value.viteTokenId)?.viteStakeForPledge ?? Amount()) > 0
        }
        
        func startGetOnroad() {
            guard isRun else { return }
            
            getOnroad()
                .done { accountBlocks in
                    plog(level: .debug, log: "find \(accountBlocks.count) onroad blocks for \(self.account.address)", tag: .onroad)
                    if accountBlocks.isEmpty {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: { self.startGetOnroad() })
                    } else {
                        self.startReceive(accountBlocks: accountBlocks)
                    }
                }.catch { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: { self.startGetOnroad() })
                }
        }
        
        func startReceive(accountBlocks: [AccountBlock]) {
            guard isRun else { return }
            plog(level: .debug, log: "receive current, \(accountBlocks.count - 1) onroad blocks left for \(self.account.address)", tag: .onroad)
            self.receive(accountBlocks: accountBlocks).done { accountBlocks in
                let delay: TimeInterval = self.hasQuotas() ? 0 : 5
                if accountBlocks.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: { self.startGetOnroad() })
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: { self.startReceive(accountBlocks: accountBlocks) })
                }
            }
        }
        
        func getOnroad() -> Promise<[AccountBlock]> {
            return GetOnroadBlocksRequest(address: self.account.address, index: 0, count: 100).defaultProviderPromise.map { accountBlocks in
                accountBlocks.sorted { b1, b2 in
                    if b1.amount == b2.amount {
                        return (b1.timestamp ?? 0) < (b2.timestamp ?? 0)
                    } else {
                        return (b1.amount ?? Amount()) > (b2.amount ?? Amount())
                    }
                }
            }
        }
        
        func receive(accountBlocks: [AccountBlock]) -> Promise<[AccountBlock]> {
            guard let onroadBlock = accountBlocks.first else {
                return .value([])
            }
            
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
                .map({ (block) -> [AccountBlock] in
                    return Array(accountBlocks.dropFirst())
                })
                // ignore error, and return all accountBlocks
                .recover({ (error) -> Promise<[AccountBlock]> in
                    return .value(accountBlocks)
                })
        }
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
