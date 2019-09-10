//
//  TokenInfoCacheService.swift
//  ViteBusiness
//
//  Created by Stone on 2019/9/6.
//

import RxSwift
import RxCocoa
import ObjectMapper
import ViteWallet
import Alamofire
import PromiseKit

public class TokenInfoCacheService {
    public static let instance = TokenInfoCacheService()

    private var tokenCodeMap = [TokenCode: TokenInfo]()
    private var viteTokenIdMap = [ViteTokenId: TokenInfo]()

    private init() {
        if let cache: Cache = readMappable() {
            for tokenInfo in cache.tokenInfos {
                tokenCodeMap[tokenInfo.tokenCode] = tokenInfo
                if tokenInfo.coinType == .vite {
                    viteTokenIdMap[tokenInfo.id] = tokenInfo
                }
            }
        }
    }
}

extension TokenInfoCacheService {

    public func updateTokenInfos(_ tokenInfos: [TokenInfo]) {
        for tokenInfo in tokenInfos {
            tokenCodeMap[tokenInfo.tokenCode] = tokenInfo
            if tokenInfo.coinType == .vite {
                viteTokenIdMap[tokenInfo.id] = tokenInfo
            }
        }
        save(mappable: Cache(tokenInfos: tokenCodeMap.map({ $1 })))
    }

    public func forceUpdateTokenInfo(for tokenCodes: [TokenCode]) -> Promise<[TokenInfo]> {
        return Promise<[TokenInfo]> { seal in
            ExchangeProvider.instance.getTokenInfos(tokenCodes: tokenCodes) { (ret) in
                switch ret {
                case .success(let tokenInfos):
                    self.updateTokenInfos(tokenInfos)
                    let tokenInfos = tokenCodes.map({ (tokenCode) -> TokenInfo in
                        if let tokenInfo = self.tokenInfo(for: tokenCode) {
                            return tokenInfo
                        } else {
                            fatalError()
                        }
                    })
                    seal.fulfill(tokenInfos)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }

    public func tokenInfos(forViteTokenIds viteTokenIds: [ViteTokenId]) -> Promise<[TokenInfo]> {

        var uncachedIds = [ViteTokenId]()
        var tokenInfos = [TokenInfo]()

        for id in viteTokenIds {
            if let tokenInfo = tokenInfo(forViteTokenId: id) {
                tokenInfos.append(tokenInfo)
            } else {
                uncachedIds.append(id)
            }
        }

        if uncachedIds.count > 0 {
            return Promise<[TokenInfo]> { seal in
                ExchangeProvider.instance.getTokenInfos(chain: "VITE", ids: uncachedIds) { (ret) in
                    switch ret {
                    case .success(let tokenInfos):
                        self.updateTokenInfos(tokenInfos)
                        let tokenInfos = viteTokenIds.map({ (id) -> TokenInfo in
                            if let tokenInfo = self.tokenInfo(forViteTokenId: id) {
                                return tokenInfo
                            } else {
                                fatalError()
                            }
                        })
                        seal.fulfill(tokenInfos)
                    case .failure(let error):
                        seal.reject(error)
                    }
                }
            }
        } else {
            return Promise.value(tokenInfos)
        }
    }

    public func tokenInfos(forViteTokenIds viteTokenIds: [ViteTokenId], completion: @escaping (Alamofire.Result<[TokenInfo]>) -> Void) {
        tokenInfos(forViteTokenIds: viteTokenIds).promiseTo(completion: completion)
    }

    public func tokenInfo(forViteTokenId viteTokenId: ViteTokenId) -> TokenInfo? {
        return viteTokenIdMap[viteTokenId]
    }

    public func tokenInfo(forViteTokenId viteTokenId: ViteTokenId) -> Promise<TokenInfo> {
        if let tokenInfo = tokenInfo(forViteTokenId: viteTokenId) {
            return Promise.value(tokenInfo)
        } else {
            return Promise<TokenInfo> { seal in
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
                        seal.fulfill(tokenInfo)
                    }).catch({ error in
                        seal.reject(error)
                    })
                #else
                ExchangeProvider.instance.getTokenInfo(chain: "VITE", id: viteTokenId, completion: { ret in
                    switch ret {
                    case .success(let tokenInfo):
                        self.updateTokenInfos([tokenInfo])
                        seal.fulfill(tokenInfo)
                    case .failure(let error):
                        seal.reject(error)
                    }
                })
                #endif
            }
        }
    }

    public func tokenInfo(forViteTokenId viteTokenId: ViteTokenId, completion: @escaping (Alamofire.Result<TokenInfo>) -> Void) {
        tokenInfo(forViteTokenId: viteTokenId).promiseTo(completion: completion)
    }

    public func tokenInfo(for tokenCode: TokenCode) -> TokenInfo? {
        return tokenCodeMap[tokenCode]
    }


    public func tokenInfo(for tokenCode: TokenCode) -> Promise<TokenInfo> {
        if let tokenInfo = tokenInfo(for: tokenCode) {
            return Promise.value(tokenInfo)
        } else {
            return Promise<TokenInfo> { seal in
                ExchangeProvider.instance.getTokenInfo(tokenCode: tokenCode, completion: { ret in
                    switch ret {
                    case .success(let tokenInfo):
                        self.updateTokenInfos([tokenInfo])
                        seal.fulfill(tokenInfo)
                    case .failure(let error):
                        seal.reject(error)
                    }
                })
            }
        }
    }

    func tokenInfo(for tokenCode: TokenCode, completion: @escaping (Alamofire.Result<TokenInfo>) -> Void) {
        tokenInfo(for: tokenCode).promiseTo(completion: completion)
    }
}

extension TokenInfoCacheService {
    struct Cache: Mappable {
        var tokenInfos = [TokenInfo]()

        init?(map: Map) { }
        mutating func mapping(map: Map) {
            tokenInfos <- map["tokenInfos"]
        }

        init(tokenInfos: [TokenInfo]) {
            self.tokenInfos = tokenInfos
        }
    }
}

extension TokenInfoCacheService: Storageable {
    public func getStorageConfig() -> StorageConfig {
        return StorageConfig(name: "TokenInfoCache", path: .app)
    }
}

extension Promise {
    public func promiseTo(completion: @escaping (Alamofire.Result<T>) -> Void) {
        self
            .done { (ret) in
                completion(Result.success(ret))
            }
            .catch { (error) in
                completion(Result.failure(error))
        }
    }
}
