//
//  ExchangeRateManager.swift
//  Action
//
//  Created by Stone on 2019/2/22.
//

import RxSwift
import RxCocoa
import ViteUtils
import ViteWallet

public typealias ExchangeRateMap = [String: [String: String]]

public final class ExchangeRateManager {
    public static let instance = ExchangeRateManager()


    fileprivate let fileHelper = FileHelper(.library, appending: FileHelper.appPathComponent)
    fileprivate static let saveKey = "ExchangeRate"

    private init() {
        if let data = self.fileHelper.contentsAtRelativePath(type(of: self).saveKey),
            let dic = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
            let map = dic as? ExchangeRateMap {
            rateMapBehaviorRelay = BehaviorRelay(value: map)
        } else {
            rateMapBehaviorRelay = BehaviorRelay(value: ExchangeRateMap())
        }
    }

    private func pri_save() {
        if let data = try? JSONSerialization.data(withJSONObject: rateMapBehaviorRelay.value, options: []) {
            if let error = self.fileHelper.writeData(data, relativePath: type(of: self).saveKey) {
                assert(false, error.localizedDescription)
            }
        }
    }

    public lazy var rateMapDriver: Driver<ExchangeRateMap> = self.rateMapBehaviorRelay.asDriver()
    private var rateMapBehaviorRelay: BehaviorRelay<ExchangeRateMap>
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

public extension Dictionary where Key == String, Value == [String: String] {
    func priceString(for tokenInfo: TokenInfo, balance: Balance) -> String {
        let currency = AppSettingsService.instance.currency
        if let dic = self[tokenInfo.tokenCode] as? [String: String],
            let rate = dic[currency.rawValue] as? [String] {
            return "\(currency.symbol) \(balance.amountFull(decimals: tokenInfo.decimals)) * \(rate)"
        } else {
            return "\(currency.symbol) 0.00"
        }
    }
}
