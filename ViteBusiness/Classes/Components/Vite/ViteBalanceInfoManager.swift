//
//  ViteBalanceInfoManager.swift
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

public typealias ViteBalanceInfoMap = [String: BalanceInfo]

extension ViteBalanceInfoManager: Storageable {
    public func getStorageConfig() -> StorageConfig {
        return StorageConfig(name: "ViteBalanceInfos", path: .wallet, appending: self.appending)
    }
}

public class ViteBalanceInfoManager {
    static let instance = ViteBalanceInfoManager()
    private init() {}

    fileprivate let disposeBag = DisposeBag()
    fileprivate var appending = "noAddress"

    lazy var  balanceInfosDriver: Driver<ViteBalanceInfoMap> = self.balanceInfos.asDriver()
    fileprivate var balanceInfos: BehaviorRelay<ViteBalanceInfoMap>! = nil

    lazy var unselectBalanceInfoVMsDriver: Driver<[WalletHomeBalanceInfoViewModel]> = self.unselectBalanceInfos.asDriver()
    fileprivate var unselectBalanceInfos: BehaviorRelay<[WalletHomeBalanceInfoViewModel]> = BehaviorRelay(value: [])
    fileprivate var unselectTokenInfoCache = [TokenInfo]()

    fileprivate var service: FetchBalanceInfoService?

    fileprivate var address: ViteAddress?
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

            self.unselectBalanceInfos = BehaviorRelay(value: [])
            self.unselectTokenInfoCache = [TokenInfo]()

            self.address = a?.address
            self.triggerService()
        }).disposed(by: disposeBag)
    }

    private func triggerService() {

        if let address = self.address,
            !tokenInfos.isEmpty {

            guard address != self.service?.address else { return }

            plog(level: .debug, log: address + ": " + "start fetch balanceInfo", tag: .transaction)
            let service = FetchBalanceInfoService(address: address, interval: 5, completion: { [weak self] (r) in
                guard let `self` = self else { return }

                switch r {
                case .success(let balanceInfos):

                    plog(level: .debug, log: address + ": " + "balanceInfo \(balanceInfos.reduce("", { (ret, balanceInfo) -> String in ret + " " + "\(balanceInfo.token.symbol):" + balanceInfo.balance.description }))", tag: .transaction)

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
                            ret[tokenInfo.viteTokenId] = BalanceInfo(token: tokenInfo.toViteToken()!, balance: Amount(), unconfirmedBalance: Amount(), unconfirmedCount: 0)
                        }
                        return ret
                    })

                    let viteTokenIdSet = Set(tokenInfos.map { $0.viteTokenId })
                    let unselectBalanceInfos = balanceInfos
                        .filter { !viteTokenIdSet.contains($0.token.id)}
                        .filter { $0.balance > 0 }

                    self.save(mappable: balanceInfos)
                    self.balanceInfos.accept(ret)

                    let viteTokenIds = unselectBalanceInfos.map { $0.token.id }
                    self.updateUnselectTokenInfoCacheIfNeeded(viteTokenIds: viteTokenIds, completion: { [weak self] (ret) in
                        guard let `self` = self else { return }
                        switch ret {
                        case .success:

                            var ret = [WalletHomeBalanceInfoViewModel]()
                            for balanceInfo in unselectBalanceInfos {
                                if let tokenInfo = self.getViteTokenInfo(for: balanceInfo.token.id) {
                                    let vm = WalletHomeBalanceInfoViewModel(tokenInfo: tokenInfo, balance: balanceInfo.balance)
                                    ret.append(vm)
                                }
                            }
                            self.unselectBalanceInfos.accept(ret)
                        case .failure:
                            break
                        }
                    })
                case .failure(let error):
                    plog(level: .warning, log: address + ": " + error.viteErrorMessage, tag: .transaction)
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

    private func read(address: ViteAddress) -> ViteBalanceInfoMap {

        self.appending = address
        var map = ViteBalanceInfoMap()

        if let jsonString = self.readString(),
            let balanceInfos = [BalanceInfo](JSONString: jsonString) {
            balanceInfos.forEach { balanceInfo in map[balanceInfo.token.id] = balanceInfo }
        }

        return map
    }
}

extension ViteBalanceInfoManager {

    func balanceInfoDriver(forViteTokenId id: String) -> Driver<BalanceInfo?> {
        return balanceInfosDriver.map { map -> BalanceInfo? in
            return map[id]
        }
    }

    func balanceInfo(forViteTokenId id: String) -> BalanceInfo? {
        return balanceInfos.value[id]
    }
}

// for unselected vite token
extension ViteBalanceInfoManager {
    func updateUnselectTokenInfoCacheIfNeeded(viteTokenIds: [ViteTokenId],completion: @escaping (Result<Void>) -> Void) {
        let ids = viteTokenIds.filter { !unselectTokenInfoCache(contains: $0) }
        if ids.isEmpty {
            completion(Result.success(()))
        } else {
            ExchangeProvider.instance.getTokenInfos(chain: "VITE", ids: ids) { (ret) in
                switch ret {
                case .success(let tokenInfos):
                    self.unselectTokenInfoCache = self.unselectTokenInfoCache + tokenInfos
                    completion(Result.success(()))
                case .failure(let error):
                    completion(Result.failure(error))
                }
            }
        }
    }

    func unselectTokenInfoCache(contains viteTokenId: ViteTokenId) -> Bool {
        return getViteTokenInfo(for: viteTokenId) != nil
    }

    func getViteTokenInfo(for viteTokenId: ViteTokenId) -> TokenInfo? {
        for tokenInfo in unselectTokenInfoCache {
            if tokenInfo.toViteToken()?.id == viteTokenId {
                return tokenInfo
            }
        }
        return nil
    }

}
