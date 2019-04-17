//
//  ViteBalanceInfoManager.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/4.
//

import ViteWallet
import PromiseKit
import ViteEthereum
import BigInt
import enum ViteWallet.Result
import RxSwift
import RxCocoa

public typealias ViteBalanceInfoMap = [String: BalanceInfo]

public class ViteBalanceInfoManager {
    static let instance = ViteBalanceInfoManager()
    private init() {}

    fileprivate let disposeBag = DisposeBag()
    fileprivate var fileHelper: FileHelper! = nil
    fileprivate static let saveKey = "ViteBalanceInfos"

    lazy var  balanceInfosDriver: Driver<ViteBalanceInfoMap> = self.balanceInfos.asDriver()
    fileprivate var balanceInfos: BehaviorRelay<ViteBalanceInfoMap>! = nil

    fileprivate var service: FetchBalanceInfoService?

    fileprivate var address: Address?
    fileprivate var tokenInfos: [TokenInfo] = []

    func registerFetch(tokenInfos: [TokenInfo]) {
        DispatchQueue.main.async {
            self.tokenInfos.append(contentsOf: tokenInfos)
            self.triggerService()
        }
    }

    func unregisterFetch(tokenInfos: [TokenInfo]) {
        DispatchQueue.main.async {
            tokenInfos.forEach({ id in
                if let index = self.tokenInfos.firstIndex(of: id) {
                    self.tokenInfos.remove(at: index)
                }
            })
            self.triggerService()
        }
    }

    func start() {
        HDWalletManager.instance.accountDriver.drive(onNext: { [weak self] a in
            guard let `self` = self else { return }

            var map = ViteBalanceInfoMap()
            if let account = a {
                map = self.read(address: account.address)
            }

            if self.balanceInfos == nil {
                self.balanceInfos = BehaviorRelay<ViteBalanceInfoMap>(value: map)
            } else {
                self.balanceInfos.accept(map)
            }

            self.address = a?.address
            self.triggerService()
        }).disposed(by: disposeBag)
    }

    private func triggerService() {

        if let address = self.address,
            !tokenInfos.isEmpty {

            guard address.description != self.service?.address.description else { return }

            plog(level: .debug, log: address.description + ": " + "start fetch balanceInfo", tag: .transaction)
            let service = FetchBalanceInfoService(address: address, interval: 5, completion: { [weak self] (r) in
                guard let `self` = self else { return }

                switch r {
                case .success(let balanceInfos):

                    plog(level: .debug, log: address.description + ": " + "balanceInfo \(balanceInfos.reduce("", { (ret, balanceInfo) -> String in ret + " " + balanceInfo.balance.value.description }))", tag: .transaction)

                    let map = balanceInfos.reduce(ViteBalanceInfoMap(), { (m, balanceInfo) -> ViteBalanceInfoMap in
                        var map = m
                        map[balanceInfo.token.id] = balanceInfo
                        return map
                    })

                    let tokenInfos = MyTokenInfosService.instance.tokenInfos.filter({ $0.coinType == .vite })
                    let ret = tokenInfos.reduce(ViteBalanceInfoMap(), { (m, tokenInfo) -> ViteBalanceInfoMap in
                        var ret = m
                        if let balanceInfo = map[tokenInfo.viteTokenId] {
                            ret[tokenInfo.viteTokenId] = balanceInfo
                        } else {
                            ret[tokenInfo.viteTokenId] = BalanceInfo(token: tokenInfo.toViteToken()!, balance: Balance(), unconfirmedBalance: Balance(), unconfirmedCount: 0)
                        }
                        return ret
                    })

                    self.save(balanceInfos: balanceInfos)
                    self.balanceInfos.accept(ret)
                case .failure(let error):
                    plog(level: .warning, log: address.description + ": " + error.viteErrorMessage, tag: .transaction)
                }
            })
            self.service?.stopPoll()
            self.service = service
            self.service?.startPoll()
        } else {
            plog(level: .debug, log: "stop fetch balanceInfo", tag: .transaction)
            self.service?.stopPoll()
            self.service = nil
        }
    }

    private func read(address: Address) -> ViteBalanceInfoMap {

        self.fileHelper = FileHelper.createForWallet(appending: address.description)
        var map = ViteBalanceInfoMap()

        if let data = self.fileHelper.contentsAtRelativePath(type(of: self).saveKey),
            let jsonString = String(data: data, encoding: .utf8),
            let balanceInfos = [BalanceInfo](JSONString: jsonString) {
            balanceInfos.forEach { balanceInfo in map[balanceInfo.token.id] = balanceInfo }
        }

        return map
    }

    private func save(balanceInfos: [BalanceInfo]) {
        if let data = balanceInfos.toJSONString()?.data(using: .utf8) {
            if let error = self.fileHelper.writeData(data, relativePath: type(of: self).saveKey) {
                assert(false, error.localizedDescription)
            }
        }
    }
}

extension ViteBalanceInfoManager {

    func balanceInfoDriver(forViteTokenId id: String) -> Driver<BalanceInfo?> {
        return balanceInfosDriver.map { map -> BalanceInfo? in
            return map[id]
        }
    }
}
