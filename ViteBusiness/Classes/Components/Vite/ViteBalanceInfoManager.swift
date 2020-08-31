//
//  ViteBalanceInfoManager.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/4.
//

import ViteWallet
import PromiseKit
import ObjectMapper

import BigInt
import enum Alamofire.Result
import RxSwift
import RxCocoa

public typealias ViteBalanceInfoMap = [String: BalanceInfo]
public typealias DexBalanceInfoMap = [String: DexBalanceInfo]

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

    lazy var dexBalanceInfosDriver: Driver<DexBalanceInfoMap> = self.dexBalanceInfosBehaviorRelay.asDriver()
    fileprivate var dexBalanceInfosBehaviorRelay: BehaviorRelay<DexBalanceInfoMap>! = nil

    lazy var balanceInfosDriver: Driver<ViteBalanceInfoMap> = self.balanceInfos.asDriver()
    fileprivate var balanceInfos: BehaviorRelay<ViteBalanceInfoMap>! = nil

    lazy var unselectBalanceInfoVMsDriver: Driver<[WalletHomeBalanceInfoViewModel]> = self.unselectBalanceInfos.asDriver()
    fileprivate var unselectBalanceInfos: BehaviorRelay<[WalletHomeBalanceInfoViewModel]> = BehaviorRelay(value: [])
    fileprivate var unselectTokenInfoCache = [TokenInfo]()

    fileprivate var service: FetchBalanceInfoService?

    fileprivate var address: ViteAddress?

    func start() {
        HDWalletManager.instance.accountDriver.drive(onNext: { [weak self] a in
            guard let `self` = self else { return }

            let storage: Storage
            if let account = a {
                storage = self.read(address: account.address)
            } else {
                storage = Storage()
            }

            if self.balanceInfos == nil {
                self.balanceInfos = BehaviorRelay<ViteBalanceInfoMap>(value: storage.walletBalanceInfoMap)
            } else {
                self.balanceInfos.accept(storage.walletBalanceInfoMap)
            }

            if self.dexBalanceInfosBehaviorRelay == nil {
                self.dexBalanceInfosBehaviorRelay = BehaviorRelay<DexBalanceInfoMap>(value: storage.dexBalanceInfoMap)
            } else {
                self.dexBalanceInfosBehaviorRelay.accept(storage.dexBalanceInfoMap)
            }

            self.unselectBalanceInfos.accept([])
            self.unselectTokenInfoCache = [TokenInfo]()

            self.address = a?.address
            self.triggerService()
        }).disposed(by: disposeBag)
    }

    private func triggerService() {


        if let address = self.address {

            guard address != self.service?.address else { return }

            //plog(level: .debug, log: address + ": " + "start fetch balanceInfo", tag: .transaction)
            let service = FetchBalanceInfoService(address: address, interval: 5, completion: { [weak self] (r) in
                guard let `self` = self else { return }

                switch r {
                case .success(let balanceInfos, let dexBalanceInfos):

                    //plog(level: .debug, log: address + ": " + "balanceInfo \(balanceInfos.reduce("", { (ret, balanceInfo) -> String in ret + " " + "\(balanceInfo.token.symbol):" + balanceInfo.balance.description }))", tag: .transaction)

                    let storage = Storage(walletBalanceInfos: balanceInfos, dexBalanceInfos: dexBalanceInfos)

                    let tokenInfos = MyTokenInfosService.instance.tokenInfos.filter({ $0.coinType == .vite })

                    let viteTokenIdSet = Set(tokenInfos.map { $0.viteTokenId })
                    let unselectBalanceInfos = balanceInfos
                        .filter { !viteTokenIdSet.contains($0.token.id)}
                        .filter { $0.balance > 0 }

                    self.save(mappable: storage)
                    self.balanceInfos.accept(storage.walletBalanceInfoMap)
                    self.dexBalanceInfosBehaviorRelay.accept(storage.dexBalanceInfoMap)

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
            self.service?.stopPoll()
            self.service = nil
        }
    }

    private func read(address: ViteAddress) -> Storage {
        self.appending = address
        if let jsonString = self.readString(),
            let storage = Storage(JSONString: jsonString) {
            return storage
        } else {
            return Storage()
        }
    }
}

extension ViteBalanceInfoManager {
    struct Storage: Mappable {
        var walletBalanceInfoMap: ViteBalanceInfoMap = [:]
        var dexBalanceInfoMap: DexBalanceInfoMap = [:]

        init?(map: Map) { }
        mutating func mapping(map: Map) {
            walletBalanceInfoMap <- map["walletBalanceInfoMap"]
            dexBalanceInfoMap <- map["dexBalanceInfoMap"]
        }

        init(walletBalanceInfos: [BalanceInfo] = [], dexBalanceInfos: [DexBalanceInfo] = []) {
            self.walletBalanceInfoMap = walletBalanceInfos
                .reduce(ViteBalanceInfoMap(), { (m, balanceInfo) -> ViteBalanceInfoMap in
                    var map = m
                    map[balanceInfo.token.id] = balanceInfo
                    return map
                })
            self.dexBalanceInfoMap = dexBalanceInfos
                .reduce(DexBalanceInfoMap(), { (m, balanceInfo) -> DexBalanceInfoMap in
                    var map = m
                    map[balanceInfo.token.id] = balanceInfo
                    return map
                })
        }
    }
}

extension ViteBalanceInfoManager {

    func balanceInfoDriver(forViteTokenId id: String) -> Driver<BalanceInfo?> {
        return balanceInfosDriver.map { map -> BalanceInfo? in
            if let ret = map[id] {
                return ret
            } else {
                if let tokenInfo = TokenInfoCacheService.instance.tokenInfo(forViteTokenId: id) {
                    return BalanceInfo(token: tokenInfo.toViteToken()!)
                } else {
                    return nil
                }
            }
        }
    }

    func dexBalanceInfoDriver(forViteTokenId id: String) -> Driver<DexBalanceInfo?> {
        return dexBalanceInfosDriver.map { map -> DexBalanceInfo? in
            if let ret = map[id] {
                return ret
            } else {
                if let tokenInfo = TokenInfoCacheService.instance.tokenInfo(forViteTokenId: id) {
                    return DexBalanceInfo(token: tokenInfo.toViteToken()!)
                } else {
                    return nil
                }
            }
        }
    }

    func balanceInfo(forViteTokenId id: String) -> BalanceInfo? {
        if let ret = balanceInfos.value[id] {
            return ret
        } else {
            if let tokenInfo = TokenInfoCacheService.instance.tokenInfo(forViteTokenId: id) {
                return BalanceInfo(token: tokenInfo.toViteToken()!)
            } else {
                return nil
            }
        }
    }

    func dexBalanceInfo(forViteTokenId id: String) -> DexBalanceInfo? {
        if let ret = dexBalanceInfosBehaviorRelay.value[id] {
            return ret
        } else {
            if let tokenInfo = TokenInfoCacheService.instance.tokenInfo(forViteTokenId: id) {
                return DexBalanceInfo(token: tokenInfo.toViteToken()!)
            } else {
                return nil
            }
        }
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
