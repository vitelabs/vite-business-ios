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


    fileprivate let fileHelper = FileHelper(.library, appending: FileHelper.walletPathComponent)
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
    public var rateMap: ExchangeRateMap { return rateMapBehaviorRelay.value }
    private var rateMapBehaviorRelay: BehaviorRelay<ExchangeRateMap>

    public func start() {
        getRate()
    }

    private func getRate() {
        let tokenCodes = MyTokenInfosService.instance.tokenInfos.map({ $0.tokenCode })
        ExchangeProvider.instance.getRate(for: tokenCodes) { [weak self] (ret) in
            switch ret {
            case .success(let map):
                plog(level: .debug, log: "count: \(map.count)", tag: .exchange)
                self?.rateMapBehaviorRelay.accept(map)
                self?.pri_save()
            case .failure(let error):
                plog(level: .warning, log: "getRate error: \(error.localizedDescription)", tag: .exchange)
            }
            GCD.delay(5, task: { self?.getRate() })
        }
    }

    func getRateImmediately(for tokenCode: TokenCode) {
        ExchangeProvider.instance.getRate(for: [tokenCode]) { [weak self] (ret) in
            guard let `self` = self else { return }
            switch ret {
            case .success(let map):
                plog(level: .debug, log: "count: \(map.count)", tag: .exchange)
                if let rate = map[tokenCode] {
                    var old = self.rateMapBehaviorRelay.value
                    old[tokenCode] = rate
                    self.rateMapBehaviorRelay.accept(map)
                    self.pri_save()
                }
            case .failure(let error):
                plog(level: .warning, log: "getRate error: \(error.localizedDescription)", tag: .exchange)
            }
        }
    }
}

public enum CurrencyCode: String {
    case USD = "usd"
    case CNY = "cny"

    var symbol: String {
        switch self {
        case .USD:
            return "$"
        case .CNY:
            return "¥"
        }
    }

    var name: String {
        switch self {
        case .USD:
            return "USD"
        case .CNY:
            return "CNY"
        }
    }

    static var allValues: [CurrencyCode] {
        return [.CNY, .USD]
    }
}

public extension Dictionary where Key == String, Value == [String: String] {
    func priceString(for tokenInfo: TokenInfo, balance: Balance) -> String {
        let currency = AppSettingsService.instance.currency
        if let dic = self[tokenInfo.tokenCode] as? [String: String],
            let rate = dic[currency.rawValue] as? String {

            let x = 1.23 as Decimal


            return "\(currency.symbol)\(balance.amountFull(decimals: tokenInfo.decimals)) * \(rate)"
        } else {
            return "\(currency.symbol)0.00"
        }
    }
}

extension ExchangeRateManager {
     func calculateBalanceWithEthRate(_ balance: Balance) -> String? {
        let ethTokenInfo = TokenInfo(tokenCode: TokenCode.etherCoin, coinType: .eth, name: "", symbol: "", decimals: 18, icon: "", id: "")

        if self.rateMap[TokenCode.etherCoin] == nil{
            return nil
        }
        return self.rateMap.priceString(for: ethTokenInfo, balance: balance)
    }
}
