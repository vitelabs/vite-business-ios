//
//  MyTokenInfosService.swift
//  Pods
//
//  Created by Stone on 2019/2/21.
//

import Foundation
import RxSwift
import RxCocoa
import ViteUtils


public final class MyTokenInfosService {
    public static let instance = MyTokenInfosService()

    fileprivate var fileHelper = FileHelper(.library, appending: FileHelper.appPathComponent)
    fileprivate static let saveKey = "MyTokenInfos"

    public static var defaultTokenInfos: [TokenInfo] {
        return [
            TokenInfo.Const.viteCoin,
            TokenInfo.Const.viteERC20,
            TokenInfo.Const.etherCoin,
        ]
    }

    //MARK: save to disk
    private init() {
        if let data = fileHelper.contentsAtRelativePath(type(of: self).saveKey),
            let jsonString = String(data: data, encoding: .utf8),
            let tokenInfos = [TokenInfo](JSONString: jsonString) {
            self.tokenInfosBehaviorRelay = BehaviorRelay(value: tokenInfos)
        } else {
            self.tokenInfosBehaviorRelay = BehaviorRelay(value: type(of: self).defaultTokenInfos)
        }
    }

    private func pri_save() {
        if let data = self.tokenInfosBehaviorRelay.value.toJSONString()?.data(using: .utf8) {
            if let error = fileHelper.writeData(data, relativePath: type(of: self).saveKey) {
                assert(false, error.localizedDescription)
            }
        }
    }

    private var tokenInfosBehaviorRelay: BehaviorRelay<[TokenInfo]>

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
        guard containsTokenInfo(for: tokenInfo.tokenCode) == false else { return }

        var tokenInfos = tokenInfosBehaviorRelay.value
        tokenInfos.append(tokenInfo)
        tokenInfosBehaviorRelay.accept(tokenInfos)
        pri_save()
    }

    public func removeToken(for tokenCode: TokenCode) {
        guard containsTokenInfo(for: tokenCode) else { return }
        guard isDefaultTokenInfo(for: tokenCode) == false else { return }

        var tokenInfos = tokenInfosBehaviorRelay.value
        for (index, token) in tokenInfos.enumerated() where token.tokenCode == tokenCode {
            tokenInfos.remove(at: index)
            break
        }
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
        for tokenInfo in type(of: self).defaultTokenInfos where tokenInfo.tokenCode == tokenCode {
            return true
        }
        return false
    }
}

