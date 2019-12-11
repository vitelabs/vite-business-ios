//
//  MyTokenInfosService.swift
//  Pods
//
//  Created by Stone on 2019/2/21.
//

import Foundation
import RxSwift
import RxCocoa
import NSObject_Rx
import Alamofire
import ViteWallet
import ObjectMapper

extension MyTokenInfosService: Storageable {
    public func getStorageConfig() -> StorageConfig {
        return StorageConfig(name: "MyTokenInfos", path: .wallet)
    }
}

public final class MyTokenInfosService: NSObject {
    public static let instance = MyTokenInfosService()

    private override init() {}
    private func pri_save() {
        let myTokenCodes = tokenCodesBehaviorRelay.value
        let removedTokenCodes = Array(self.removedTokenCodes)
        let storager = Storager(myTokenCodes: myTokenCodes, removedTokenCodes: removedTokenCodes)
        save(mappable: storager)
    }

    fileprivate(set) var removedTokenCodes = Set<TokenCode>()

    private var tokenCodesBehaviorRelay: BehaviorRelay<[TokenCode]> = BehaviorRelay(value: [])
    private var tokenInfosBehaviorRelay: BehaviorRelay<[TokenInfo]> = BehaviorRelay(value: [])

    //MARK: Launch
    func start() {

        Observable.combineLatest(
            AppConfigService.instance.configDriver.asObservable(),
            HDWalletManager.instance.walletDriver.map({ $0?.uuid }).distinctUntilChanged().asObservable())
            .bind { [weak self] (config, uuid) in
                guard let `self` = self else { return }
                if let _ = uuid {
                    #if DAPP
                    self.tokenInfosBehaviorRelay.accept([TokenInfo.BuildIn.vite.value])
                    #else

                    let defaultTokenCodes = config.defaultTokenCodes
                    let myTokenCodes: [TokenCode]
                    if let jsonString = self.readString() {
                        // Compatible with older versions(2.7.0)
                        if let tokenInfos = [TokenInfo](JSONString: jsonString) {
                            TokenInfoCacheService.instance.addTokenInfosIfNotExist(tokenInfos)
                            myTokenCodes = tokenInfos.map { $0.tokenCode }
                        } else if let storager = Storager(JSONString: jsonString) {
                            myTokenCodes = storager.myTokenCodes
                            self.removedTokenCodes = Set(storager.removedTokenCodes)
                        } else {
                            myTokenCodes = [TokenInfo.BuildIn.vite.value.tokenCode]
                        }
                    } else {
                        myTokenCodes = [TokenInfo.BuildIn.vite.value.tokenCode]
                    }

                    self.tokenCodesBehaviorRelay.accept(myTokenCodes)

                    let myTokenInfos = myTokenCodes
                        .map { TokenInfoCacheService.instance.tokenInfo(for: $0) }
                        .compactMap { $0 }
                    let defaultTokenInfos = defaultTokenCodes
                        .map { TokenInfoCacheService.instance.tokenInfo(for: $0) }
                        .compactMap { $0 }

                    let tokenInfos = self.sortTokenInfos(defaultTokenInfos: defaultTokenInfos, myTokenInfos: myTokenInfos)
                    self.tokenInfosBehaviorRelay.accept(tokenInfos)

                    if myTokenCodes.count == myTokenInfos.count && defaultTokenCodes.count == defaultTokenInfos.count {
                        self.pri_save()
                    } else {
                        self.fetchTokenInfos(defaultTokenCodes: defaultTokenCodes, myTokenCodes: myTokenCodes)
                    }

                    #endif
                } else {
                    self.tokenCodesBehaviorRelay.accept([])
                    self.tokenInfosBehaviorRelay.accept([])
                }
        }.disposed(by: rx.disposeBag)
    }

    private func fetchTokenInfos(defaultTokenCodes: [TokenCode], myTokenCodes: [TokenCode]) {
        let set = Set(defaultTokenCodes).union(Set(myTokenCodes))
        TokenInfoCacheService.instance.tokenInfos(for: Array(set))
            .done { _ in
                let defaultTokenInfos = TokenInfoCacheService.instance.tokenInfos(for: defaultTokenCodes)!
                let myTokenInfos = TokenInfoCacheService.instance.tokenInfos(for: myTokenCodes)!
                let tokenInfos = self.sortTokenInfos(defaultTokenInfos: defaultTokenInfos, myTokenInfos: myTokenInfos)
                self.tokenInfosBehaviorRelay.accept(tokenInfos)
                self.pri_save()
            }.catch{ error in
                plog(level: .warning, log: "fetch my tokenInfos error: \(error.localizedDescription)", tag: .exchange)
                GCD.delay(1) { self.fetchTokenInfos(defaultTokenCodes: defaultTokenCodes, myTokenCodes: myTokenCodes) }
        }
    }

    private func sortTokenInfos(defaultTokenInfos: [TokenInfo], myTokenInfos: [TokenInfo]) -> [TokenInfo] {

        let set = Set(defaultTokenInfos.map{ $0.tokenCode })

        var viteTokenInfos: NSMutableArray = NSMutableArray()
        var ethTokenInfos: NSMutableArray = NSMutableArray()
        var bnbTokenInfos: NSMutableArray = NSMutableArray()
        var grinTokenInfos: NSMutableArray = NSMutableArray()

        defaultTokenInfos.forEach { (tokenInfo) in
            if !removedTokenCodes.contains(tokenInfo.tokenCode) {
                switch tokenInfo.coinType {
                case .vite:
                    viteTokenInfos.add(tokenInfo)
                case .eth:
                    ethTokenInfos.add(tokenInfo)
                case .grin:
                    grinTokenInfos.add(tokenInfo)
                case .bnb:
                    bnbTokenInfos.add(tokenInfo)
                case .unsupport:
                    break
                }
            }
        }

        myTokenInfos.forEach { (tokenInfo) in
            if !removedTokenCodes.contains(tokenInfo.tokenCode) && !set.contains(tokenInfo.tokenCode) {
                switch tokenInfo.coinType {
                case .vite:
                    viteTokenInfos.add(tokenInfo)
                case .eth:
                    ethTokenInfos.add(tokenInfo)
                case .bnb:
                    bnbTokenInfos.add(tokenInfo)
                case .grin:
                    grinTokenInfos.add(tokenInfo)
                case .unsupport:
                    break
                }
            }
        }

        return (viteTokenInfos as! [TokenInfo]) + (ethTokenInfos as! [TokenInfo]) + (grinTokenInfos as! [TokenInfo]) + (bnbTokenInfos as! [TokenInfo])
    }

    //MARK: public func
    public lazy var tokenInfosDriver: Driver<[TokenInfo]> = self.tokenInfosBehaviorRelay.asDriver()
    public var tokenCodes: [TokenCode] {  return tokenCodesBehaviorRelay.value }
    public var tokenInfos: [TokenInfo] {  return tokenInfosBehaviorRelay.value }

    public func tokenInfo(forBnbSymbol symbol: String) -> TokenInfo? {
        for tokenInfo in tokenInfos where tokenInfo.id == symbol {
            return tokenInfo
        }
        return nil
    }

    public func tokenInfo(for tokenCode: TokenCode) -> TokenInfo? {
        for tokenInfo in tokenInfos where tokenInfo.tokenCode == tokenCode {
            return tokenInfo
        }
        return nil
    }

    public func append(tokenInfo: TokenInfo) {
        TokenInfoCacheService.instance.updateTokenInfos([tokenInfo])
        guard contains(for: tokenInfo.tokenCode) == false else { return }

        removedTokenCodes.remove(tokenInfo.tokenCode)
        var tokenInfos = tokenInfosBehaviorRelay.value
        tokenInfos.append(tokenInfo)
        let ret = sortTokenInfos(defaultTokenInfos: [], myTokenInfos: tokenInfos)
        tokenCodesBehaviorRelay.accept(ret.map { $0.tokenCode })
        tokenInfosBehaviorRelay.accept(ret)
        pri_save()
        ExchangeRateManager.instance.getRateImmediately(for: tokenInfo.tokenCode)
    }

    public func removeToken(for tokenCode: TokenCode) {
        guard contains(for: tokenCode) else { return }
        guard canRemove(for: tokenCode) else { return }

        let tokenInfos = tokenInfosBehaviorRelay.value.filter { $0.tokenCode != tokenCode }
        tokenCodesBehaviorRelay.accept(tokenInfos.map { $0.tokenCode })
        tokenInfosBehaviorRelay.accept(tokenInfos)
        removedTokenCodes.insert(tokenCode)
        pri_save()
    }

    public func contains(for tokenCode: TokenCode) -> Bool {
        for code in tokenCodes where code == tokenCode {
            return true
        }
        return false
    }

    public func canRemove(for tokenCode: TokenCode) -> Bool {
        return tokenCode != TokenInfo.BuildIn.vite.value.tokenCode
    }
}

extension TokenInfo {
    var canRemove: Bool {
        return MyTokenInfosService.instance.canRemove(for: tokenCode)
    }

    var isContains: Bool {
        return MyTokenInfosService.instance.contains(for: tokenCode)
    }
}

extension MyTokenInfosService {
    fileprivate struct Storager: Mappable {

        fileprivate(set) var myTokenCodes = [TokenCode]()
        fileprivate(set) var removedTokenCodes = [TokenCode]()

        init?(map: Map) {

        }

        mutating func mapping(map: Map) {
            myTokenCodes <- map["myTokenCodes"]
            removedTokenCodes <- map["removedTokenCodes"]
        }

        init(myTokenCodes: [TokenCode], removedTokenCodes: [TokenCode]) {
            self.myTokenCodes = myTokenCodes
            self.removedTokenCodes = removedTokenCodes
        }
    }
}

extension MyTokenInfosService {
    // for debug
    func clear() {
        tokenCodesBehaviorRelay.accept([])
        tokenInfosBehaviorRelay.accept([])
        removedTokenCodes = []
        pri_save()
    }
}
