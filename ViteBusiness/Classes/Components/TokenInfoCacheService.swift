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

    public func updateTokenInfo(_ tokenInfo: TokenInfo) {
        tokenCodeMap[tokenInfo.tokenCode] = tokenInfo
        if tokenInfo.coinType == .vite {
            viteTokenIdMap[tokenInfo.id] = tokenInfo
        }
        save(mappable: Cache(tokenInfos: tokenCodeMap.map({ $1 })))
    }

    public func tokenInfo(forViteTokenId viteTokenId: ViteTokenId) -> TokenInfo? {
        return viteTokenIdMap[viteTokenId]
    }

    public func tokenInfo(forViteTokenId viteTokenId: ViteTokenId, completion: @escaping (Alamofire.Result<TokenInfo>) -> Void) {

        if let tokenInfo = tokenInfo(forViteTokenId: viteTokenId) {
            completion(Result.success(tokenInfo))
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
            ExchangeProvider.instance.getTokenInfo(chain: "VITE", id: viteTokenId, completion: { ret in
                switch ret {
                case .success(let tokenInfo):
                    self.updateTokenInfo(tokenInfo)
                    completion(Result.success(tokenInfo))
                case .failure(let error):
                    completion(Result.failure(error))
                }
            })
            #endif
        }
    }

    public func tokenInfo(for tokenCode: TokenCode) -> TokenInfo? {
        return tokenCodeMap[tokenCode]
    }

    func tokenInfo(for tokenCode: TokenCode, completion: @escaping (Alamofire.Result<TokenInfo>) -> Void) {

        if let tokenInfo = tokenInfo(for: tokenCode) {
            completion(Alamofire.Result.success(tokenInfo))
        } else {
            ExchangeProvider.instance.getTokenInfo(tokenCode: tokenCode, completion: { ret in
                switch ret {
                case .success(let tokenInfo):
                    self.updateTokenInfo(tokenInfo)
                    completion(Result.success(tokenInfo))
                case .failure(let error):
                    completion(Result.failure(error))
                }
            })
        }
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
