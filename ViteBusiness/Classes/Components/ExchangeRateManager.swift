//
//  ExchangeRateManager.swift
//  Action
//
//  Created by Stone on 2019/2/22.
//

import ViteWallet
import RxSwift
import RxCocoa

public final class ExchangeRateManager {
    public static let instance = ExchangeRateManager()
    private init() {}

    public lazy var tokensDriver: Driver<[TokenInfo]> = self.tokensBehaviorRelay.asDriver()
    private var tokensBehaviorRelay: BehaviorRelay<[TokenInfo]> = BehaviorRelay(value: [TokenInfo]())

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

    private func pri_save() {

    }
}

public enum CurrencyCode: String {
    case USD
    case CNY

    var symbol: String {
        switch self {
        case .USD:
            return "$"
        case .CNY:
            return "¥"
        }
    }
}

public struct ExchangeRate {

    let code: CurrencyCode
    let rate: [String: String]

}

//extension Balance {
//    public func price(decimals: Int, rate: ExchangeRate) -> String {
//        return "\(rate.code.symbol) 100.00"
//    }
//}
