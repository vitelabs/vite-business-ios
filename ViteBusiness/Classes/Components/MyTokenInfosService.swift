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

extension MyTokenInfosService: Storageable {
    public func getStorageConfig() -> StorageConfig {
        return StorageConfig(name: "MyTokenInfos", path: .wallet)
    }
}

public final class MyTokenInfosService: NSObject {
    public static let instance = MyTokenInfosService()
    fileprivate var needUpdateTokenInfo: Set<TokenCode> = Set()

    private override init() {}
    private func pri_save() {
        save(mappable: tokenInfosBehaviorRelay.value)
    }

    private var tokenInfosBehaviorRelay: BehaviorRelay<[TokenInfo]> = BehaviorRelay(value: [])

    private func sortTokenInfos(tokenInfos: [TokenInfo]) -> [TokenInfo] {

        var viteTokenInfos: NSMutableArray = NSMutableArray()
        var ethTokenInfos: NSMutableArray = NSMutableArray()
        var grinTokenInfos: NSMutableArray = NSMutableArray()

        tokenInfos.forEach { (tokenInfo) in
            switch tokenInfo.coinType {
            case .vite:
                viteTokenInfos.add(tokenInfo)
            case .eth:
                ethTokenInfos.add(tokenInfo)
            case .grin:
                grinTokenInfos.add(tokenInfo)
            case .btc:
                fatalError()
            }
        }

        return (viteTokenInfos as! [TokenInfo]) + (ethTokenInfos as! [TokenInfo]) + (grinTokenInfos as! [TokenInfo])
    }

    //MARK: Launch
    func start() {

        Observable.combineLatest(
            AppConfigService.instance.configDriver.asObservable(),
            HDWalletManager.instance.walletDriver.map({ $0?.uuid }).distinctUntilChanged().asObservable())
            .bind { [weak self] (config, uuid) in
                guard let `self` = self else { return }
                if let _ = uuid {
                    #if DAPP
                    self.tokenInfosBehaviorRelay.accept([
                        TokenInfo(tokenCode: ViteConst.instance.tokenCode.viteCoin,
                                  coinType: .vite,
                                  name: ViteWalletConst.viteToken.name,
                                  symbol: ViteWalletConst.viteToken.symbol,
                                  decimals: ViteWalletConst.viteToken.decimals,
                                  icon: "https://token-profile-1257137467.cos.ap-hongkong.myqcloud.com/icon/e6dec7dfe46cb7f1c65342f511f0197c.png",
                                  id: ViteWalletConst.viteToken.id)])
                    self.needUpdateTokenInfo = Set()
                    #else
                    guard let array = config.defaultTokenInfos as? [[String: Any]] else { return }
                    let defaultTokenInfos = [TokenInfo](JSONArray: array).compactMap { $0 }
                    self.defaultTokenInfos = defaultTokenInfos

                    if let jsonString = self.readString(),
                        let tokenInfos = [TokenInfo](JSONString: jsonString) {
                        let selected = tokenInfos.filter { !defaultTokenInfos.contains($0) }

                        // update icon
                        let def = defaultTokenInfos.map({ (old) -> TokenInfo in
                            for tokenInfo in tokenInfos where tokenInfo.tokenCode == old.tokenCode { return tokenInfo }
                            return old
                        })
                        self.tokenInfosBehaviorRelay.accept(self.sortTokenInfos(tokenInfos: def + selected))
                    } else {
                        self.tokenInfosBehaviorRelay.accept(defaultTokenInfos)
                    }
                    self.needUpdateTokenInfo = Set(self.tokenInfosBehaviorRelay.value.map({ $0.tokenCode }))
                    #endif
                } else {
                    self.tokenInfosBehaviorRelay.accept([])
                    self.needUpdateTokenInfo = Set()
                }
        }.disposed(by: rx.disposeBag)
    }

    //MARK: public func
    public fileprivate(set) var defaultTokenInfos: [TokenInfo] = []
    public lazy var tokenInfosDriver: Driver<[TokenInfo]> = self.tokenInfosBehaviorRelay.asDriver()
    public var tokenInfos: [TokenInfo] {  return tokenInfosBehaviorRelay.value }

    public func updateTokenInfoIfNeeded(for tokenCode: TokenCode) {
        guard needUpdateTokenInfo.contains(tokenCode) else { return }

        ExchangeProvider.instance.getTokenInfo(tokenCode: tokenCode) { (r) in
            switch r {
            case .success(let tokenInfo):
                self.needUpdateTokenInfo.remove(tokenCode)
                var tokenInfos = self.tokenInfosBehaviorRelay.value
                var index: Int?
                for (i, t) in tokenInfos.enumerated() where t.tokenCode == tokenInfo.tokenCode {
                    index = i
                }

                if let index = index {
                    tokenInfos.remove(at: index)
                    tokenInfos.insert(tokenInfo, at: index)
                    self.tokenInfosBehaviorRelay.accept(tokenInfos)
                    self.pri_save()
                }

            case .failure(let error):
                plog(level: .warning, log: "update tokenInfo error: \(error.localizedDescription)", tag: .exchange)
            }
        }
    }

    public func tokenInfo(for tokenCode: TokenCode) -> TokenInfo? {
        for tokenInfo in tokenInfos where tokenInfo.tokenCode == tokenCode {
            return tokenInfo
        }
        return nil
    }

    public func append(tokenInfo: TokenInfo) {
        guard containsTokenInfo(for: tokenInfo.tokenCode) == false else { return }

        var tokenInfos = tokenInfosBehaviorRelay.value
        tokenInfos.append(tokenInfo)
        tokenInfosBehaviorRelay.accept(sortTokenInfos(tokenInfos: tokenInfos))
        pri_save()
        ExchangeRateManager.instance.getRateImmediately(for: tokenInfo.tokenCode)
    }

    public func removeToken(for tokenCode: TokenCode) {
        guard containsTokenInfo(for: tokenCode) else { return }
        guard isDefaultTokenInfo(for: tokenCode) == false else { return }

        let tokenInfos = tokenInfosBehaviorRelay.value.filter { $0.tokenCode != tokenCode }
        tokenInfosBehaviorRelay.accept(tokenInfos)
        pri_save()
    }

    public func containsTokenInfo(for tokenCode: TokenCode) -> Bool {
        for tokenInfo in tokenInfos where tokenInfo.tokenCode == tokenCode {
            return true
        }
        return false
    }

    public func isDefaultTokenInfo(for tokenCode: TokenCode) -> Bool {
        for tokenInfo in defaultTokenInfos where tokenInfo.tokenCode == tokenCode {
            return true
        }
        return false
    }
}

extension MyTokenInfosService {

    public func tokenInfo(forViteTokenId viteTokenId: ViteTokenId) -> TokenInfo? {
        for tokenInfo in tokenInfos where tokenInfo.coinType == .vite && tokenInfo.viteTokenId == viteTokenId {
            return tokenInfo
        }
        return nil
    }

    public func tokenInfo(forEthContractAddress address: String) -> TokenInfo? {
        for tokenInfo in tokenInfos where tokenInfo.coinType == .eth && tokenInfo.ethContractAddress.lowercased() == address.lowercased() {
            return tokenInfo
        }
        return nil
    }

    func tokenInfo(for tokenCode: TokenCode, completion: @escaping (Alamofire.Result<TokenInfo>) -> Void) {

        if let tokenInfo = tokenInfo(for: tokenCode) {
            completion(Alamofire.Result.success(tokenInfo))
        } else {
            ExchangeProvider.instance.getTokenInfo(tokenCode: tokenCode, completion: completion)
        }
    }

    func tokenInfo(forViteTokenId viteTokenId: ViteTokenId, completion: @escaping (Alamofire.Result<TokenInfo>) -> Void) {

        if let tokenInfo = tokenInfo(forViteTokenId: viteTokenId) {
            completion(Alamofire.Result.success(tokenInfo))
        } else {
            #if DAPP
            ViteNode.mintage.getToken(tokenId: viteTokenId)
            .done({
                let tokenInfo = TokenInfo(tokenCode: $0.id,
                                          coinType: .vite,
                                          name: $0.name,
                                          symbol: $0.symbol,
                                          decimals: $0.decimals,
                                          icon: "",
                                          id: $0.id)
                completion(Result.success(tokenInfo))
            }).catch({ error in
                completion(Result.failure(error))
            })
            #else
            ExchangeProvider.instance.getTokenInfo(chain: "VITE", id: viteTokenId, completion: completion)
            #endif
        }
    }

    func tokenInfo(forEthContractAddress address: String, completion: @escaping (Alamofire.Result<TokenInfo>) -> Void) {

        if let tokenInfo = tokenInfo(forEthContractAddress: address) {
            completion(Alamofire.Result.success(tokenInfo))
        } else {
            ExchangeProvider.instance.getTokenInfo(chain: "ETH", id: address, completion: completion)
        }
    }
}

extension TokenInfo {
    var isDefault: Bool {
        return MyTokenInfosService.instance.isDefaultTokenInfo(for: tokenCode)
    }

    var isContains: Bool {
        return MyTokenInfosService.instance.containsTokenInfo(for: tokenCode)
    }
}

extension MyTokenInfosService {
    // for debug
    func clear() {
        tokenInfosBehaviorRelay.accept([])
        pri_save()
    }
}
