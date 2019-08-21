//
//  ETHBalanceInfoManager.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/4.
//

import ViteWallet
import PromiseKit

import BigInt
import enum Alamofire.Result
import RxSwift
import RxCocoa

public typealias ETHBalanceInfoMap = [TokenCode: ETHBalanceInfo]

public class ETHBalanceInfoManager {
    static let instance = ETHBalanceInfoManager()
    private init() {}

    fileprivate let disposeBag = DisposeBag()
    fileprivate var fileHelper: FileHelper! = nil
    fileprivate static let saveKey = "ETHBalanceInfos"

    lazy var  balanceInfosDriver: Driver<ETHBalanceInfoMap> = self.balanceInfos.asDriver()
    fileprivate var balanceInfos: BehaviorRelay<ETHBalanceInfoMap>! = nil

    fileprivate var serviceMap: [TokenCode: ETHBalanceInfoService] = [:]

    fileprivate var address: String?
    fileprivate var tokenInfos: [TokenInfo] = []

    func registerFetch(tokenInfos: [TokenInfo]) {
        DispatchQueue.main.async {
            self.tokenInfos.append(contentsOf: tokenInfos)
            self.triggerService()
        }
    }

    func unregisterFetch(tokenInfos: [TokenInfo]) {
        DispatchQueue.main.async {
            tokenInfos.forEach({ tokenInfo in
                if let index = self.tokenInfos.firstIndex(of: tokenInfo) {
                    self.tokenInfos.remove(at: index)
                }
            })
            self.triggerService()
        }
    }

    func start() {
        HDWalletManager.instance.ethAddressDriver.drive(onNext: { [weak self] a in
            guard let `self` = self else { return }

            var map = ETHBalanceInfoMap()
            if let address = a {
                map = self.read(address: address)
            }

            if self.balanceInfos == nil {
                self.balanceInfos = BehaviorRelay<ETHBalanceInfoMap>(value: map)
            } else {
                self.balanceInfos.accept(map)
            }

            self.address = a
            self.triggerService()
        }).disposed(by: disposeBag)
    }

    private func triggerService() {

        if let address = self.address, !tokenInfos.isEmpty {

            if address != EtherWallet.shared.address {
                plog(level: .debug, log: "stop fetch balanceInfo", tag: .transaction)
                self.serviceMap = [:]
            }

            tokenInfos.filter { (tokenInfo) -> Bool in
                if let _ = serviceMap[tokenInfo.tokenCode] {
                    return false
                } else {
                    return true
                }
            }.forEach { (tokenInfo) in
                plog(level: .debug, log: address + ": " + "start fetch \(tokenInfo.uniqueSymbol)", tag: .transaction)
                let service = ETHBalanceInfoService(tokenInfo: tokenInfo, interval: 5, completion: { [weak self] (r) in
                    guard let `self` = self else { return }

                    switch r {
                    case .success(let balanceInfo):

                        plog(level: .debug, log: "\(address) \(tokenInfo.uniqueSymbol): \(balanceInfo.balance.description)", tag: .transaction)
                        
                        var map = self.balanceInfos.value ?? ETHBalanceInfoMap()
                        map[balanceInfo.tokenCode] = balanceInfo

                        self.save(balanceInfos: Array(map.values))
                        self.balanceInfos.accept(map)
                    case .failure(let error):
                        plog(level: .warning, log: address + ": " + error.viteErrorMessage, tag: .transaction)
                    }
                })
                service.startPoll()
                serviceMap[tokenInfo.tokenCode] = service
            }

            serviceMap.forEach { (tokenCode, service) in
                if !tokenInfos.contains(where: { $0.tokenCode == tokenCode }) {
                    plog(level: .debug, log: address + ": " + "stop fetch \(MyTokenInfosService.instance.tokenInfo(for: tokenCode)!.uniqueSymbol)", tag: .transaction)
                    serviceMap[tokenCode] = nil
                }
            }

        } else {
            plog(level: .debug, log: "stop All fetch", tag: .transaction)
            self.serviceMap = [:]
        }
    }

    private func read(address: String) -> ETHBalanceInfoMap {

        self.fileHelper = FileHelper.createForWallet(appending: address)
        var map = ETHBalanceInfoMap()

        if let data = self.fileHelper.contentsAtRelativePath(type(of: self).saveKey),
            let jsonString = String(data: data, encoding: .utf8),
            let balanceInfos = [ETHBalanceInfo](JSONString: jsonString) {

            // filter deleted balanceInfo
            for balanceInfo in balanceInfos where MyTokenInfosService.instance.containsTokenInfo(for: balanceInfo.tokenCode) {
                map[balanceInfo.tokenCode] = balanceInfo
            }
        }

        return map
    }

    private func save(balanceInfos: [ETHBalanceInfo]) {
        if let data = balanceInfos.toJSONString()?.data(using: .utf8) {
            if let error = self.fileHelper.writeData(data, relativePath: type(of: self).saveKey) {
                assert(false, error.localizedDescription)
            }
        }
    }
}

extension ETHBalanceInfoManager {

    func balanceInfoDriver(for tokenCode: TokenCode) -> Driver<ETHBalanceInfo?> {
        return balanceInfosDriver.map({ [weak self] map -> ETHBalanceInfo? in
            return map[tokenCode]
        })
    }
}
