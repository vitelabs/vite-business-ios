//
//  NewAssetService.swift
//  ViteBusiness
//
//  Created by Water on 2019/6/19.
//

import RxSwift
import RxCocoa
import Foundation
import NSObject_Rx

extension NewAssetService: Storageable {
    public func getStorageConfig() -> StorageConfig {
        return StorageConfig(name: "IgnoreReminderToken", path: .wallet)
    }
}

public class NewAssetService {
    public static let instance = NewAssetService()
    var isNewTipTokens : [WalletHomeBalanceInfoViewModel] = []

    init() {
        if let jsonString = self.readString(),
            let tokenInfos = [TokenInfo](JSONString: jsonString) {            self.ignoreReminderTokensBehaviorRelay.accept(tokenInfos)
        }
    }

    public lazy var ignoreReminderTokensDriver: Driver<[TokenInfo]> = self.ignoreReminderTokensBehaviorRelay.asDriver()
    public var ignoreReminderTokens: [TokenInfo] {  return ignoreReminderTokensBehaviorRelay.value }

    private var ignoreReminderTokensBehaviorRelay: BehaviorRelay<[TokenInfo]> = BehaviorRelay(value: [])


    func handleIsNewTipTokens(_ input : [WalletHomeBalanceInfoViewModel])-> [TokenInfo] {
        self.isNewTipTokens = input

        var list : [TokenInfo] = []
        for viewModel in input where self.containsTokenInfo(for: viewModel.tokenInfo.tokenCode) {
            list.append(viewModel.tokenInfo)
        }
        return list
    }

    public func addIgnoreReminderToken(tokenInfo: TokenInfo) {
        guard containsTokenInfo(for: tokenInfo.tokenCode) == false else { return }

        var tokenInfos = ignoreReminderTokensBehaviorRelay.value
        tokenInfos.append(tokenInfo)
        ignoreReminderTokensBehaviorRelay.accept(tokenInfos)
        pri_save()
    }

    public func addIgnoreReminderTokens(_ tokenInfos: [TokenInfo]) {
        for token in tokenInfos where self.containsTokenInfo(for: token.tokenCode){
            self.addIgnoreReminderToken(tokenInfo: token)
        }
    }

    public func containsTokenInfo(for tokenCode: TokenCode) -> Bool {
        for tokenInfo in ignoreReminderTokens where tokenInfo.tokenCode == tokenCode {
            return true
        }
        return false
    }

    private func pri_save() {
        save(mappable: ignoreReminderTokensBehaviorRelay.value)
    }
}
