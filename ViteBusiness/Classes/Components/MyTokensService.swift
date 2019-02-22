//
//  MyTokensService.swift
//  Pods
//
//  Created by Stone on 2019/2/21.
//

import Foundation
import RxSwift
import RxCocoa
import ViteUtils


public final class MyTokensService {
    public static let instance = MyTokensService()

    fileprivate var fileHelper = FileHelper(.library, appending: FileHelper.appPathComponent)
    fileprivate static let saveKey = "MyTokens"

    //MARK: save to disk
    private init() {
        if let data = fileHelper.contentsAtRelativePath(type(of: self).saveKey),
            let jsonString = String(data: data, encoding: .utf8),
            let tokens = [TokenInfo](JSONString: jsonString) {
            self.tokensBehaviorRelay = BehaviorRelay(value: tokens)
        } else {
            self.tokensBehaviorRelay = BehaviorRelay(value: [TokenInfo]())
        }
    }

    private func pri_save() {
        if let data = self.tokensBehaviorRelay.value.toJSONString()?.data(using: .utf8) {
            if let error = fileHelper.writeData(data, relativePath: type(of: self).saveKey) {
                assert(false, error.localizedDescription)
            }
        }
    }

    //MARK: public func
    public lazy var tokensDriver: Driver<[TokenInfo]> = self.tokensBehaviorRelay.asDriver()
    private var tokensBehaviorRelay: BehaviorRelay<[TokenInfo]>

    public func append(token: TokenInfo) {
        var tokens = tokensBehaviorRelay.value
        tokens.append(token)
        tokensBehaviorRelay.accept(tokens)
        pri_save()
    }

    public func removeToken(for tokenCode: String) {
        var tokens = tokensBehaviorRelay.value
        for (index, token) in tokens.enumerated() where token.tokenCode == tokenCode {
            tokens.remove(at: index)
            break
        }
        tokensBehaviorRelay.accept(tokens)
        pri_save()
    }

    public func containsToken(for tokenCode: String) -> Bool {
        let tokens = tokensBehaviorRelay.value
        for token in tokens where token.tokenCode == tokenCode {
            return true
        }
        return false
    }

    public func isDefaultToken(for tokenCode: String) -> Bool {
        return false
    }
}

