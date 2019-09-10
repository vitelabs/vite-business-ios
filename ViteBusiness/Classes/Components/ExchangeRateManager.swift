//
//  ExchangeRateManager.swift
//  Action
//
//  Created by Stone on 2019/2/22.
//

import RxSwift
import RxCocoa
import ViteWallet
import BigInt

public typealias ExchangeRateMap = [String: [String: String]]

public final class ExchangeRateManager {
    public static let instance = ExchangeRateManager()

    fileprivate let disposeBag = DisposeBag()
    fileprivate var service: ExchangeRateService?

    private init() {}

    private func pri_save() {
        if let data = try? JSONSerialization.data(withJSONObject: rateMapBehaviorRelay.value, options: []) {
            self.save(data: data)
        }
    }

    private func read() -> ExchangeRateMap {
        if let data = readData(),
            let dic = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
            let map = dic as? ExchangeRateMap {
            return map
        } else {
            return ExchangeRateMap()
        }
    }

    public lazy var rateMapDriver: Driver<ExchangeRateMap> = self.rateMapBehaviorRelay.asDriver()
    public var rateMap: ExchangeRateMap { return rateMapBehaviorRelay.value }
    private var rateMapBehaviorRelay: BehaviorRelay<ExchangeRateMap> = BehaviorRelay(value: ExchangeRateMap())

    public func start() {

        HDWalletManager.instance.walletDriver.map({ $0?.uuid }).distinctUntilChanged().drive(onNext: { [weak self] uuid in
            guard let `self` = self else { return }
            if let _ = uuid {
                plog(level: .debug, log: "start fetch", tag: .exchange)
                self.rateMapBehaviorRelay.accept(self.read())
                let tokenCodes = MyTokenInfosService.instance.tokenInfos.map({ $0.tokenCode })
                let service = ExchangeRateService(tokenCodes: tokenCodes, interval: 5 * 60, completion: { [weak self] (r) in
                    guard let `self` = self else { return }
                    switch r {
                    case .success(let map):
                        plog(level: .debug, log: "count: \(map.count)", tag: .exchange)
                        self.rateMapBehaviorRelay.accept(map)
                        self.pri_save()
                    case .failure(let error):
                        plog(level: .warning, log: "getRate error: \(error.localizedDescription)", tag: .exchange)
                    }
                })
                self.service?.stopPoll()
                self.service = service
                self.service?.startPoll()
            } else {
                plog(level: .debug, log: "stop fetch", tag: .exchange)
                self.rateMapBehaviorRelay.accept(ExchangeRateMap())
                self.service?.stopPoll()
                self.service = nil
            }
        }).disposed(by: disposeBag)
    }

    func getRateImmediately(for tokenCode: TokenCode) {
        guard let service = self.service else { return }

        service.getRateImmediately(for: tokenCode) { [weak self] (ret) in
            guard let `self` = self else { return }
            switch ret {
            case .success(let map):
                plog(level: .debug, log: "count: \(map.count)", tag: .exchange)
                if let rate = map[tokenCode] {
                    var old = self.rateMapBehaviorRelay.value
                    old[tokenCode] = rate
                    self.rateMapBehaviorRelay.accept(old)
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

    func price(for tokenInfo: TokenInfo, balance: Amount) -> BigDecimal {

        let currency = AppSettingsService.instance.currency
        if let dic = self[tokenInfo.tokenCode] as? [String: String],
            let rate = dic[currency.rawValue] as? String,
            let price = balance.price(decimals: tokenInfo.decimals, rate: rate) {
            return price
        } else {
            return BigDecimal()
        }
    }

    func priceString(for tokenInfo: TokenInfo, balance: Amount) -> String {
        let currency = AppSettingsService.instance.currency
        let p = price(for: tokenInfo, balance: balance)
        return "\(currency.symbol)\(BigDecimalFormatter.format(bigDecimal: p, style: .decimalRound(2), padding: .padding, options: [.groupSeparator]))"
    }
}

public extension Amount {
    public func price(decimals: Int, rate: String) -> BigDecimal? {
        guard let r = BigDecimal(rate) else { return nil }
        let v = BigDecimal(self)
        let d = BigDecimal(BigInt(10).power(decimals))
        return v * r / d
    }
}

extension ExchangeRateManager {
     func calculateBalanceWithEthRate(_ balance: Amount) -> String? {
        if self.rateMap[TokenInfo.BuildIn.eth.value.tokenCode] == nil{
            return nil
        }
        return self.rateMap.priceString(for: TokenInfo.BuildIn.eth.value, balance: balance)
    }
}

extension ExchangeRateManager: Storageable {
    public func getStorageConfig() -> StorageConfig {
        return StorageConfig(name: "ExchangeRate", path: .wallet)
    }
}
