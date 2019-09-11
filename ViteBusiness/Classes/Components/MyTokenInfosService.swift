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
        let myTokenCodes = tokenInfosBehaviorRelay.value.map{ $0.tokenCode }
        let removedTokenCodes = Array(self.removedTokenCodes)
        let storager = Storager(myTokenCodes: myTokenCodes, removedTokenCodes: removedTokenCodes)
        save(mappable: storager)
    }

    fileprivate(set) var removedTokenCodes = Set<TokenCode>()

    private var tokenInfosBehaviorRelay: BehaviorRelay<[TokenInfo]> = BehaviorRelay(value: [])

    //MARK: Launch
    func start() {

        Observable.combineLatest(
            AppConfigService.instance.defaultTokenInfosDriver.asObservable(),
            HDWalletManager.instance.walletDriver.map({ $0?.uuid }).distinctUntilChanged().asObservable())
            .bind { [weak self] (defaultTokenInfos, uuid) in
                guard let `self` = self else { return }
                if let _ = uuid {
                    #if DAPP
                    self.tokenInfosBehaviorRelay.accept([TokenInfo.BuildIn.vite.value])
                    #else

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

                    if let myTokenInfos = TokenInfoCacheService.instance.tokenInfos(for: myTokenCodes) {
                        let tokenInfos = self.sortTokenInfos(defaultTokenInfos: defaultTokenInfos, myTokenInfos: myTokenInfos)
                        self.tokenInfosBehaviorRelay.accept(tokenInfos)
                        self.pri_save()
                    } else {
                        self.tokenInfosBehaviorRelay.accept(defaultTokenInfos)
                        self.fetchMyTokenInfos(defaultTokenInfos: defaultTokenInfos, tokenCodes: myTokenCodes)
                    }
                    #endif
                } else {
                    self.tokenInfosBehaviorRelay.accept([])
                }
        }.disposed(by: rx.disposeBag)
    }

    private func fetchMyTokenInfos(defaultTokenInfos: [TokenInfo], tokenCodes: [TokenCode]) {
        TokenInfoCacheService.instance.tokenInfos(for: tokenCodes)
            .done { tokenInfos in
                let tokenInfos = self.sortTokenInfos(defaultTokenInfos: defaultTokenInfos, myTokenInfos: tokenInfos)
                self.tokenInfosBehaviorRelay.accept(tokenInfos)
                self.pri_save()
            }.catch{ error in
                plog(level: .warning, log: "fetch my tokenInfos error: \(error.localizedDescription)", tag: .exchange)
                GCD.delay(1) { self.fetchMyTokenInfos(defaultTokenInfos: defaultTokenInfos, tokenCodes: tokenCodes) }
        }
    }

    private func sortTokenInfos(defaultTokenInfos: [TokenInfo], myTokenInfos: [TokenInfo]) -> [TokenInfo] {

        let set = Set(defaultTokenInfos.map{ $0.tokenCode })

        var viteTokenInfos: NSMutableArray = NSMutableArray()
        var ethTokenInfos: NSMutableArray = NSMutableArray()
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
                case .grin:
                    grinTokenInfos.add(tokenInfo)
                case .unsupport:
                    break
                }
            }
        }

        return (viteTokenInfos as! [TokenInfo]) + (ethTokenInfos as! [TokenInfo]) + (grinTokenInfos as! [TokenInfo])
    }

    //MARK: public func
    public lazy var tokenInfosDriver: Driver<[TokenInfo]> = self.tokenInfosBehaviorRelay.asDriver()
    public var tokenInfos: [TokenInfo] {  return tokenInfosBehaviorRelay.value }

    public func tokenInfo(for tokenCode: TokenCode) -> TokenInfo? {
        for tokenInfo in tokenInfos where tokenInfo.tokenCode == tokenCode {
            return tokenInfo
        }
        return nil
    }

    public func append(tokenInfo: TokenInfo) {
        TokenInfoCacheService.instance.updateTokenInfos([tokenInfo])
        guard containsTokenInfo(for: tokenInfo.tokenCode) == false else { return }

        var tokenInfos = tokenInfosBehaviorRelay.value
        tokenInfos.append(tokenInfo)
        tokenInfosBehaviorRelay.accept(sortTokenInfos(defaultTokenInfos: [], myTokenInfos: tokenInfos))
        removedTokenCodes.remove(tokenInfo.tokenCode)
        pri_save()
        ExchangeRateManager.instance.getRateImmediately(for: tokenInfo.tokenCode)
    }

    public func removeToken(for tokenCode: TokenCode) {
        guard containsTokenInfo(for: tokenCode) else { return }
        guard canRemoveTokenInfo(for: tokenCode) else { return }

        let tokenInfos = tokenInfosBehaviorRelay.value.filter { $0.tokenCode != tokenCode }
        tokenInfosBehaviorRelay.accept(tokenInfos)
        removedTokenCodes.insert(tokenCode)
        pri_save()
    }

    public func containsTokenInfo(for tokenCode: TokenCode) -> Bool {
        for tokenInfo in tokenInfos where tokenInfo.tokenCode == tokenCode {
            return true
        }
        return false
    }

    public func canRemoveTokenInfo(for tokenCode: TokenCode) -> Bool {
        return tokenCode != TokenInfo.BuildIn.vite.value.tokenCode
    }
}

extension TokenInfo {
    var canRemove: Bool {
        return MyTokenInfosService.instance.canRemoveTokenInfo(for: tokenCode)
    }

    var isContains: Bool {
        return MyTokenInfosService.instance.containsTokenInfo(for: tokenCode)
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
        tokenInfosBehaviorRelay.accept([])
        removedTokenCodes = []
        pri_save()
    }
}
