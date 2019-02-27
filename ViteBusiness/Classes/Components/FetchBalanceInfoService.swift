//
//  FetchBalanceInfoService.swift
//  Vite
//
//  Created by Stone on 2018/9/19.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import ViteWallet
import PromiseKit
import RxSwift
import RxCocoa
import RxOptional
import ViteUtils
import ViteEthereum

final class FetchBalanceInfoService {

    static let instance = FetchBalanceInfoService()
    private init() {}

    lazy var  balanceInfosDriver: Driver<[WalletHomeBalanceInfoViewModelType]> = self.balanceInfos.asDriver()
    fileprivate var balanceInfos: BehaviorRelay<[WalletHomeBalanceInfoViewModelType]>! = nil

    fileprivate let disposeBag = DisposeBag()
    fileprivate var fileHelper: FileHelper! = nil
    fileprivate static let saveKey = "BalanceInfos"

    fileprivate var service: ViteWallet.FetchBalanceInfoService?

    func start() {
        HDWalletManager.instance.accountDriver.drive(onNext: { [weak self] a in
            guard let `self` = self else { return }
            if let account = a {
                self.fileHelper = FileHelper(.library, appending: "\(FileHelper.accountPathComponent)/\(account.address.description)")
                var oldBalanceInfos: [BalanceInfo]!
                if let data = self.fileHelper.contentsAtRelativePath(type(of: self).saveKey),
                    let jsonString = String(data: data, encoding: .utf8),
                    let array = [BalanceInfo](JSONString: jsonString) {
                    oldBalanceInfos = array
                } else {
                    oldBalanceInfos = BalanceInfo.mergeDefaultBalanceInfos([])
                }

                let viewModels = oldBalanceInfos.map { WalletHomeBalanceInfoViewModel(balanceInfo: $0) }
                if self.balanceInfos == nil {
                    self.balanceInfos = BehaviorRelay<[WalletHomeBalanceInfoViewModelType]>(value: viewModels)
                } else {
                    self.balanceInfos.accept(viewModels)
                }

//                plog(level: .debug, log: account.address.description + ": " + "start fetch balanceInfo", tag: .transaction)
                let address = account.address
                let service = ViteWallet.FetchBalanceInfoService(address: address, interval: 5, completion: { [weak self] (r) in
                    guard let `self` = self else { return }
                    
                    switch r {
                    case .success(let balanceInfos):

//                        plog(level: .debug, log: address.description + ": " + "balanceInfo \(balanceInfos.reduce("", { (ret, balanceInfo) -> String in ret + " " + balanceInfo.balanceShortString }))", tag: .transaction)
                        let allBalanceInfos = BalanceInfo.mergeDefaultBalanceInfos(balanceInfos)
                        let tokens = allBalanceInfos.map { $0.token }
                        TokenCacheService.instance.updateTokensIfNeeded(tokens)

                        if let data = allBalanceInfos.toJSONString()?.data(using: .utf8) {
                            if let error = self.fileHelper.writeData(data, relativePath: type(of: self).saveKey) {
                                assert(false, error.localizedDescription)
                            }
                        }
                        self.balanceInfos.accept(allBalanceInfos.map { WalletHomeBalanceInfoViewModel(balanceInfo: $0) })
                    case .failure(let error):
                        plog(level: .warning, log: address.description + ": " + error.viteErrorMessage, tag: .transaction)
                    }
                })
                service.startPoll()
                self.service = service
            } else {
//                plog(level: .debug, log: "stop fetch balanceInfo", tag: .transaction)
                self.service = nil
            }
        }).disposed(by: disposeBag)
    }
}

extension FetchBalanceInfoService {
    func getBalanceInfo(tokenInfos: [TokenInfo], viteAddress: String) -> Promise<[CommonBalanceInfo]> {
        let viteTokenInfos = tokenInfos.filter { $0.chainType == .vite }
        let ethTokenInfos = tokenInfos.filter { $0.chainType == .eth }

        return when(fulfilled: ViteWallet.FetchBalanceInfoService.getBalanceInfo(tokenInfos: viteTokenInfos, address: viteAddress),
                    EtherWallet.shared.getBalanceInfo(tokenInfos: ethTokenInfos)).map { (viteBalanceInfos, ethBalanceInfos) -> [CommonBalanceInfo] in
                        var map: [String: CommonBalanceInfo] = [:]
                        for info in viteBalanceInfos {
                            map[info.tokenCode] = info
                        }
                        for info in ethBalanceInfos {
                            map[info.tokenCode] = info
                        }

                        var balanceInfos: [CommonBalanceInfo] = []
                        for tokenInfo in tokenInfos {
                            if let balanceInfo = map[tokenInfo.tokenCode] {
                                balanceInfos.append(balanceInfo)
                            }
                        }
                        return balanceInfos
        }
    }
}

import enum ViteWallet.Result
public class FetchAllBalanceInfoService: PollService {

    public typealias Ret = Result<[CommonBalanceInfo]>

    deinit {
        printLog("")
    }

    public let address: Address
    public init(address: Address, interval: TimeInterval, completion: ((Result<[CommonBalanceInfo]>) -> ())? = nil) {
        self.address = address
        self.interval = interval
        self.completion = completion
    }

    public var taskId: String = ""
    public var isPolling: Bool = false
    public var interval: TimeInterval = 0
    public var completion: ((Result<[CommonBalanceInfo]>) -> ())?

    public func handle(completion: @escaping (Result<[CommonBalanceInfo]>) -> ()) {

        let tokenInfos = [
            TokenInfo.Const.viteCoin,
            TokenInfo.Const.etherCoin,
            TokenInfo.Const.viteERC20
        ]

        FetchBalanceInfoService.instance.getBalanceInfo(tokenInfos: tokenInfos, viteAddress: address.description)
            .done { (ret) in
                completion(Result(value: ret))
            }.catch { (e) in
                completion(Result(error: e))
        }
    }
}

final class FetchBalanceInfoManager {

    static let instance = FetchBalanceInfoManager()
    private init() {}

    lazy var  balanceInfosDriver: Driver<[CommonBalanceInfo]> = self.balanceInfos.asDriver()
    fileprivate var balanceInfos: BehaviorRelay<[CommonBalanceInfo]>! = nil

    fileprivate let disposeBag = DisposeBag()
    fileprivate var fileHelper: FileHelper! = nil
    fileprivate static let saveKey = "BalanceInfos"

    fileprivate var service: FetchAllBalanceInfoService?

    func start() {
        HDWalletManager.instance.accountDriver.drive(onNext: { [weak self] a in
            guard let `self` = self else { return }
            if let account = a {
//                self.fileHelper = FileHelper(.library, appending: "\(FileHelper.accountPathComponent)/\(account.address.description)")
//                var oldBalanceInfos: [BalanceInfo]!
//                if let data = self.fileHelper.contentsAtRelativePath(type(of: self).saveKey),
//                    let jsonString = String(data: data, encoding: .utf8),
//                    let array = [BalanceInfo](JSONString: jsonString) {
//                    oldBalanceInfos = array
//                } else {
//                    oldBalanceInfos = BalanceInfo.mergeDefaultBalanceInfos([])
//                }
//
//                let viewModels = oldBalanceInfos.map { WalletHomeBalanceInfoViewModel(balanceInfo: $0) }
//                if self.balanceInfos == nil {
//                    self.balanceInfos = BehaviorRelay<[WalletHomeBalanceInfoViewModelType]>(value: viewModels)
//                } else {
//                    self.balanceInfos.accept(viewModels)
//                }

                if self.balanceInfos == nil {
                    self.balanceInfos = BehaviorRelay<[CommonBalanceInfo]>(value: [CommonBalanceInfo]())
                }

                plog(level: .debug, log: account.address.description + ": " + "start fetch balanceInfo", tag: .transaction)
                let address = account.address
                
                let service = FetchAllBalanceInfoService(address: address, interval: 5, completion: { [weak self] (r) in
                    guard let `self` = self else { return }

                    switch r {
                    case .success(let balanceInfos):

                        plog(level: .debug, log: address.description + ": " + "balanceInfo \(balanceInfos.reduce("", { (ret, balanceInfo) -> String in ret + " " + balanceInfo.balance.value.description }))", tag: .transaction)

//                        if let data = allBalanceInfos.toJSONString()?.data(using: .utf8) {
//                            if let error = self.fileHelper.writeData(data, relativePath: type(of: self).saveKey) {
//                                assert(false, error.localizedDescription)
//                            }
//                        }
                        self.balanceInfos.accept(balanceInfos)
                    case .failure(let error):
                        plog(level: .warning, log: address.description + ": " + error.viteErrorMessage, tag: .transaction)
                    }
                })
                service.startPoll()
                self.service = service
            } else {
                plog(level: .debug, log: "stop fetch balanceInfo", tag: .transaction)
                self.service = nil
            }
        }).disposed(by: disposeBag)
    }
}
