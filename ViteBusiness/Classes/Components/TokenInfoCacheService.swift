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

    fileprivate var needUpdateTokenInfo: Set<TokenCode> = Set()
    private var tokenCodeMap = [TokenCode: TokenInfo]()
    private var keyMap = [String: TokenInfo]()
    private var dexTokenCodes = [TokenCode]()

    private init() {
        if let cache: Cache = readMappable() {
            dexTokenCodes = cache.dexTokenCodes
            for tokenInfo in cache.tokenInfos {
                tokenCodeMap[tokenInfo.tokenCode] = tokenInfo
                keyMap["\(tokenInfo.rawChainName)_\(tokenInfo.id.lowercased())"] = tokenInfo
                needUpdateTokenInfo.insert(tokenInfo.tokenCode)
            }
        } else {
            let jsonString = TokenInfo.BuildIn.vite.jsonString
            let tokenInfo = TokenInfo(JSONString: jsonString)!
            tokenCodeMap[tokenInfo.tokenCode] = tokenInfo
            keyMap["\(tokenInfo.rawChainName)_\(tokenInfo.id.lowercased())"] = tokenInfo
        }
    }
}
extension TokenInfoCacheService {
    public func fetchDexTokenInfos() {
        func fetch() {
            UnifyProvider.vitex.getDexTokenInfos().done { (tokenInfos) in
                self.dexTokenCodes = tokenInfos.map { $0.tokenCode }
                self.updateTokenInfos(tokenInfos)
                ExchangeRateManager.instance.getRateImmediately(for: tokenInfos.map { $0.tokenCode} )
            }.catch { (error) in
                plog(level: .warning, log: "update tokenInfo error: \(error.localizedDescription)", tag: .exchange)
                GCD.delay(2) { fetch() }
            }
        }
        fetch()
    }

    public var dexTokenInfos: [TokenInfo] {
        dexTokenCodes.map { tokenInfo(for: $0)! }
    }
}

extension TokenInfoCacheService {

    public func updateTokenInfoIfNeeded(for tokenCode: TokenCode) {
        guard needUpdateTokenInfo.contains(tokenCode) else { return }
        TokenInfoCacheService.instance.forceUpdateTokenInfo(for: [tokenCode])
            .done { (_) in
                // do nothing
            }.catch { (error) in
                plog(level: .warning, log: "update tokenInfo error: \(error.localizedDescription)", tag: .exchange)
        }
    }

    public func addTokenInfosIfNotExist(_ tokenInfos: [TokenInfo]) {
        let uncachedTokenInfos = tokenInfos.filter { (tokenInfo) -> Bool in
            if let _: TokenInfo? = self.tokenInfo(for: tokenInfo.tokenCode) {
                return false
            } else {
                return true
            }
        }
        updateTokenInfos(uncachedTokenInfos)
    }

    public func updateTokenInfos(_ tokenInfos: [TokenInfo]) {
        guard tokenInfos.count > 0 else { return }
        for tokenInfo in tokenInfos {
            tokenCodeMap[tokenInfo.tokenCode] = tokenInfo
            keyMap["\(tokenInfo.rawChainName)_\(tokenInfo.id.lowercased())"] = tokenInfo
            needUpdateTokenInfo.remove(tokenInfo.tokenCode)
        }
        save(mappable: Cache(tokenInfos: tokenCodeMap.map({ $1 }), dexTokenCodes: dexTokenCodes))
    }

    // MARK: sync
    public func tokenInfo(for tokenCode: TokenCode) -> TokenInfo? {
        return tokenCodeMap[tokenCode]
    }

    public func tokenInfos(for tokenCodes: [TokenCode]) -> [TokenInfo]? {
        var tokenInfos = [TokenInfo]()
        for tokenCode in tokenCodes {
            if let tokenInfo = tokenInfo(for: tokenCode) {
                tokenInfos.append(tokenInfo)
            } else {
                return nil
            }
        }
        return tokenInfos
    }

    public func tokenInfo(forViteTokenId viteTokenId: ViteTokenId) -> TokenInfo? {
        return keyMap["\(CoinType.vite.name)_\(viteTokenId.lowercased())"]
    }

    // MARK: promise
    public func tokenInfos(for tokenCodes: [TokenCode]) -> Promise<[TokenInfo]> {
        var uncachedTokenCodes = [TokenCode]()
        var tokenInfos = [TokenInfo]()

        for tokenCode in tokenCodes {
            if let tokenInfo = tokenInfo(for: tokenCode) {
                tokenInfos.append(tokenInfo)
            } else {
                uncachedTokenCodes.append(tokenCode)
            }
        }

        if uncachedTokenCodes.count > 0 {
            return Promise<[TokenInfo]> { seal in
                ExchangeProvider.instance.getTokenInfos(tokenCodes: uncachedTokenCodes, completion: { (ret) in
                    switch ret {
                    case .success(let tokenInfos):
                        self.updateTokenInfos(tokenInfos)
                        let ret = tokenCodes.map({ (tokenCode) -> TokenInfo in
                            if let tokenInfo = self.tokenInfo(for: tokenCode) {
                                return tokenInfo
                            } else {
                                fatalError()
                            }
                        })
                        seal.fulfill(ret)
                    case .failure(let error):
                        seal.reject(error)
                    }
                })
            }
        } else {
            return Promise.value(tokenInfos)
        }
    }

    public func tokenInfo(for tokenCode: TokenCode) -> Promise<TokenInfo> {
        return tokenInfos(for: [tokenCode]).map { $0[0] }
    }

    public func forceUpdateTokenInfo(for tokenCodes: [TokenCode]) -> Promise<[TokenInfo]> {
        guard tokenCodes.count > 0 else { return Promise.value([]) }
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

    public func tokenInfo(forViteTokenId viteTokenId: ViteTokenId) -> Promise<TokenInfo> {
        return tokenInfos(forViteTokenIds: [viteTokenId]).map{ $0[0] }
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

    // MARK: async
    public func tokenInfo(for tokenCode: TokenCode, completion: @escaping (Alamofire.Result<TokenInfo>) -> Void) {
        tokenInfo(for: tokenCode).promiseTo(completion: completion)
    }

    public func tokenInfos(forViteTokenIds viteTokenIds: [ViteTokenId], completion: @escaping (Alamofire.Result<[TokenInfo]>) -> Void) {
        tokenInfos(forViteTokenIds: viteTokenIds).promiseTo(completion: completion)
    }

    public func tokenInfo(forViteTokenId viteTokenId: ViteTokenId, completion: @escaping (Alamofire.Result<TokenInfo>) -> Void) {
        tokenInfo(forViteTokenId: viteTokenId).promiseTo(completion: completion)
    }
}

extension TokenInfoCacheService {
    struct Cache: Mappable {
        var tokenInfos = [TokenInfo]()
        var dexTokenCodes = [TokenCode]()

        init?(map: Map) { }
        mutating func mapping(map: Map) {
            tokenInfos <- map["tokenInfos"]
            dexTokenCodes <- map["dexTokenCodes"]
        }

        init(tokenInfos: [TokenInfo], dexTokenCodes: [TokenCode]) {
            self.tokenInfos = tokenInfos
            self.dexTokenCodes = dexTokenCodes
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
