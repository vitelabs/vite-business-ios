//
//  FetchBalanceInfoManager.swift
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
import enum ViteWallet.Result

final class FetchBalanceInfoManager {

    static let instance = FetchBalanceInfoManager()
    private init() {}

    lazy var  balanceInfosDriver: Driver<[ETHBalanceInfo]> = self.balanceInfos.asDriver()
    fileprivate var balanceInfos: BehaviorRelay<[ETHBalanceInfo]>! = BehaviorRelay(value: [ETHBalanceInfo]())

    fileprivate let disposeBag = DisposeBag()
    fileprivate var fileHelper: FileHelper! = nil
    fileprivate static let saveKey = "AllBalanceInfos"

//    fileprivate var service: FetchAllBalanceInfoService?

    func start() {
//        HDWalletManager.instance.accountDriver.drive(onNext: { [weak self] a in
//            guard let `self` = self else { return }
//            if let account = a {
//                self.fileHelper = FileHelper(.library, appending: "\(FileHelper.walletPathComponent)/\(account.address.description)")
//                var array: [ETHBalanceInfo]!
//                if let data = self.fileHelper.contentsAtRelativePath(type(of: self).saveKey),
//                    let jsonString = String(data: data, encoding: .utf8),
//                    let a = [ETHBalanceInfo](JSONString: jsonString) {
//                    array = a
//                } else  {
//                    array = MyTokenInfosService.instance.tokenInfos.map { ETHBalanceInfo(tokenCode: $0.tokenCode, balance: Balance()) }
//                }
//
//                if self.balanceInfos == nil {
//                    self.balanceInfos = BehaviorRelay<[ETHBalanceInfo]>(value: array)
//                } else {
//                    self.balanceInfos.accept(array)
//                }
//
//                plog(level: .debug, log: account.address.description + ": " + "start fetch balanceInfo", tag: .transaction)
//                let address = account.address
//                
//                let service = FetchAllBalanceInfoService(address: address, interval: 5, completion: { [weak self] (r) in
//                    guard let `self` = self else { return }
//
//                    switch r {
//                    case .success(let balanceInfos):
//
//                        plog(level: .debug, log: address.description + ": " + "balanceInfo \(balanceInfos.reduce("", { (ret, balanceInfo) -> String in ret + " " + balanceInfo.balance.value.description }))", tag: .transaction)
//
//                        if let data = balanceInfos.toJSONString()?.data(using: .utf8) {
//                            if let error = self.fileHelper.writeData(data, relativePath: type(of: self).saveKey) {
//                                assert(false, error.localizedDescription)
//                            }
//                        }
//                        self.balanceInfos.accept(balanceInfos)
//                    case .failure(let error):
//                        plog(level: .warning, log: address.description + ": " + error.viteErrorMessage, tag: .transaction)
//                    }
//                })
//                service.startPoll()
//                self.service = service
//            } else {
//                plog(level: .debug, log: "stop fetch balanceInfo", tag: .transaction)
//                self.service = nil
//            }
//        }).disposed(by: disposeBag)
    }
}

extension FetchBalanceInfoManager {

    func balanceInfoDriver(for tokenCode: TokenCode) -> Driver<ETHBalanceInfo?> {
        return balanceInfosDriver.map { balanceInfos -> ETHBalanceInfo? in
            for balanceInfo in balanceInfos {
                if balanceInfo.tokenCode == tokenCode {
                    return balanceInfo
                }
            }
            return nil
        }
    }

    func balanceInfoDriver(forViteTokenId id: String) -> Driver<(ETHBalanceInfo, Token)?> {
        return balanceInfosDriver.map { balanceInfos -> (ETHBalanceInfo, Token)? in
            for balanceInfo in balanceInfos {
                if let token = balanceInfo.tokenInfo.toViteToken(), token.id == id {
                    return (balanceInfo, token)
                }
            }
            return nil
        }
    }

    func balanceInfoDriver(forETHContractAddress address: String) -> Driver<(ETHBalanceInfo, ETHToken)?> {
        return balanceInfosDriver.map { balanceInfos -> (ETHBalanceInfo, ETHToken)? in
            for balanceInfo in balanceInfos {
                if let token = balanceInfo.tokenInfo.toETHToken(), token.contractAddress == address {
                    return (balanceInfo, token)
                }
            }
            return nil
        }
    }
}
