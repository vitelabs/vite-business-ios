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
import ViteUtils
import Alamofire


public final class MyTokenInfosService: NSObject {
    public static let instance = MyTokenInfosService()

    fileprivate var fileHelper: FileHelper! = nil
    fileprivate static let saveKey = "MyTokenInfos"

    private override init() {}
    private func pri_save() {
        if let data = self.tokenInfosBehaviorRelay.value.toJSONString()?.data(using: .utf8) {
            if let error = fileHelper.writeData(data, relativePath: type(of: self).saveKey) {
                assert(false, error.localizedDescription)
            }
        }
    }

    private var tokenInfosBehaviorRelay: BehaviorRelay<[TokenInfo]> = BehaviorRelay(value: [])

    //MARK: Launch
    func start() {

        Observable.combineLatest(
            AppConfigService.instance.configDriver.asObservable(),
            HDWalletManager.instance.walletDriver.map({ $0?.uuid }).distinctUntilChanged().asObservable())
            .bind { [weak self] (config, uuid) in
                guard let `self` = self else { return }
                if let _ = uuid {
                    guard let array = config.defaultTokenInfos as? [[String: Any]] else { return }
                    let defaultTokenInfos = [TokenInfo](JSONArray: array).compactMap { $0 }
                    self.defaultTokenInfos = defaultTokenInfos

                    self.fileHelper = FileHelper(.library, appending: "\(FileHelper.walletPathComponent)")

                    if let data = self.fileHelper.contentsAtRelativePath(type(of: self).saveKey),
                        let jsonString = String(data: data, encoding: .utf8),
                        let tokenInfos = [TokenInfo](JSONString: jsonString) {
                        let selected = tokenInfos.filter { !defaultTokenInfos.contains($0) }
                        self.tokenInfosBehaviorRelay.accept(selected + defaultTokenInfos)
                    } else {
                        self.tokenInfosBehaviorRelay.accept(defaultTokenInfos)
                    }
                } else {
                    self.tokenInfosBehaviorRelay.accept([])
                }
        }.disposed(by: rx.disposeBag)
    }

    //MARK: public func
    public fileprivate(set) var defaultTokenInfos: [TokenInfo] = []
    public lazy var tokenInfosDriver: Driver<[TokenInfo]> = self.tokenInfosBehaviorRelay.asDriver()
    public var tokenInfos: [TokenInfo] {  return tokenInfosBehaviorRelay.value }

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
        tokenInfosBehaviorRelay.accept(tokenInfos)
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

    public func tokenInfo(forViteTokenId viteTokenId: String) -> TokenInfo? {
        for tokenInfo in tokenInfos where tokenInfo.coinType == .vite && tokenInfo.viteTokenId == viteTokenId {
            return tokenInfo
        }
        return nil
    }

    public func tokenInfo(forEthContractAddress address: String) -> TokenInfo? {
        for tokenInfo in tokenInfos where tokenInfo.coinType == .eth && tokenInfo.ethContractAddress == address {
            return tokenInfo
        }
        return nil
    }

    func tokenInfo(for tokenCode: TokenCode, completion: @escaping (Alamofire.Result<TokenInfo>) -> Void) {

        if let tokenInfo = tokenInfo(for: tokenCode) {
            completion(Result.success(tokenInfo))
        } else {
            ExchangeProvider.instance.getTokenInfo(tokenCode: tokenCode, completion: completion)
        }
    }

    func tokenInfo(forViteTokenId viteTokenId: String, completion: @escaping (Alamofire.Result<TokenInfo>) -> Void) {

        if let tokenInfo = tokenInfo(forViteTokenId: viteTokenId) {
            completion(Result.success(tokenInfo))
        } else {
            ExchangeProvider.instance.getTokenInfo(chain: "Vite", id: viteTokenId, completion: completion)
        }
    }

    func tokenInfo(forEthContractAddress address: String, completion: @escaping (Alamofire.Result<TokenInfo>) -> Void) {

        if let tokenInfo = tokenInfo(forEthContractAddress: address) {
            completion(Result.success(tokenInfo))
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
