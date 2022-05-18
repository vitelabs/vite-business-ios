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
                //plog(level: .debug, log: "start fetch", tag: .exchange)
                self.rateMapBehaviorRelay.accept(self.read())
                var tokenCodes = Set(MyTokenInfosService.instance.tokenInfos.map({ $0.tokenCode }))
                tokenCodes.insert(TokenInfo.BuildIn.vite_btc_000.value.tokenCode)
                tokenCodes = tokenCodes.union(TokenInfoCacheService.instance.dexTokenInfos.map({$0.tokenCode}))
                let service = ExchangeRateService(tokenCodes: Array(tokenCodes), interval: 5 * 60, completion: { [weak self] (r) in
                    guard let `self` = self else { return }
                    switch r {
                    case .success(let map):
                        //plog(level: .debug, log: "count: \(map.count)", tag: .exchange)
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
                //plog(level: .debug, log: "stop fetch", tag: .exchange)
                self.rateMapBehaviorRelay.accept(ExchangeRateMap())
                self.service?.stopPoll()
                self.service = nil
            }
        }).disposed(by: disposeBag)
    }

    func getRateImmediately(for tokenCodes: [TokenCode]) {
        guard let service = self.service else { return }

        service.getRateImmediately(for: tokenCodes) { [weak self] (ret) in
            guard let `self` = self else { return }
            switch ret {
            case .success(let map):
                //plog(level: .debug, log: "count: \(map.count)", tag: .exchange)

                var old = self.rateMapBehaviorRelay.value
                for tokenCode in tokenCodes {
                    if let rate = map[tokenCode] {
                        old[tokenCode] = rate
                    }
                }
                self.rateMapBehaviorRelay.accept(old)
                self.pri_save()
            case .failure(let error):
                plog(level: .warning, log: "getRate error: \(error.localizedDescription)", tag: .exchange)
            }
        }
    }
}

public enum CurrencyCode: String {
    case USD = "usd"
    case CNY = "cny"
    case RUB = "rub"
    case KRW = "krw"
    case TRY = "try"
    case VND = "vnd"
    case EUR = "eur"
    case GBP = "gbp"
    case INR = "inr"
    case UAH = "uah"
    

    var symbol: String {
        switch self {
        case .USD:
            return "$"
        case .CNY:
            return "¥"
        case .RUB:
            return "₽"
        case .KRW:
            return "₩"
        case .TRY:
            return "₺"
        case .VND:
            return "₫"
        case .EUR:
            return "€"
        case .GBP:
            return "£"
        case .INR:
            return "₹"
        case .UAH:
            return "₴"
        }
    }

    var name: String {
        switch self {
        case .USD:
            return "USD"
        case .CNY:
            return "CNY"
        case .RUB:
            return "RUB"
        case .KRW:
            return "KRW"
        case .TRY:
            return "TRY"
        case .VND:
            return "VND"
        case .EUR:
            return "EUR"
        case .GBP:
            return "GBP"
        case .INR:
            return "INR"
        case .UAH:
            return "UAH"
        }
    }

    static var allValues: [CurrencyCode] {
        return [.CNY, .EUR, .GBP, .INR, .KRW, .RUB, .TRY, .UAH, .USD, .VND]
    }
}

public extension Dictionary where Key == String, Value == [String: String] {

    func price(for tokenInfo: TokenInfo, balance: Amount) -> BigDecimal {

        let currency = AppSettingsService.instance.appSettings.currency
        if let dic = self[tokenInfo.tokenCode] as? [String: String],
            let rate = dic[currency.rawValue] as? String,
            let price = balance.price(decimals: tokenInfo.decimals, rate: rate) {
            return price
        } else {
            return BigDecimal()
        }
    }

    func priceString(tokenCode: String, balance: Double) -> String {
        let currency = AppSettingsService.instance.appSettings.currency

        if let dic = self[tokenCode] as? [String: String],
           let rate = dic[currency.rawValue] as? String{
            let price = String.init(format: "%0.2f", balance *  Double(string: rate)!)
            return "\(currency.symbol)\(price)"
        }
        return "\(currency.symbol)0.00"
    }

    func priceString(for tokenInfo: TokenInfo, balance: Amount) -> String {
        let currency = AppSettingsService.instance.appSettings.currency
        let p = price(for: tokenInfo, balance: balance)
        return "\(currency.symbol)\(BigDecimalFormatter.format(bigDecimal: p, style: .decimalRound(2), padding: .padding, options: [.groupSeparator]))"
    }

    func btcPriceString(btc: BigDecimal) -> String {
        let currency = AppSettingsService.instance.appSettings.currency
        guard let dic = self[TokenInfo.BuildIn.vite_btc_000.value.tokenCode] as? [String: String],
            let string = dic[currency.rawValue] as? String,
            let rate = BigDecimal(string) else {
                return "\(currency.symbol)0.00"
        }

        let bigDecimal = btc * rate
        return currency.symbol + BigDecimalFormatter.format(bigDecimal: bigDecimal, style: .decimalTruncation(2), padding: .none, options: [.groupSeparator])
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

    func calculateBalanceWithBnbRate(_ balance: Amount) -> String? {
        if self.rateMap[TokenInfo.BuildIn.bnb.value.tokenCode] == nil{
            return nil
        }
        return self.rateMap.priceString(for: TokenInfo.BuildIn.bnb.value, balance: balance)
    }

    func calculateBtcBalanceWithPrice(_ price: BigDecimal) -> String {
        let currency = AppSettingsService.instance.appSettings.currency
        if let dic = rateMap[TokenInfo.BuildIn.vite_btc_000.value.tokenCode] as? [String: String],
            let rateString = dic[currency.rawValue] as? String,
            let rate = BigDecimal(rateString),
            rate != BigDecimal(0) {
            let btc = price / rate
            return BigDecimalFormatter.format(bigDecimal: btc, style: .decimalRound(8), padding: .none, options: [.groupSeparator])
        } else {
            return "0"
        }
    }
}

extension ExchangeRateManager: Storageable {
    public func getStorageConfig() -> StorageConfig {
        return StorageConfig(name: "ExchangeRate", path: .wallet)
    }
}
