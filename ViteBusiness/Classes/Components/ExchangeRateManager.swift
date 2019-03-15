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
import BigInt

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


public struct Bigdecimal {

    let symbol: Bool // true as +, false as -
    let beforeDecPoint: String
    let afterDecPoint: String
    let number: BigInt
    let digits: Int



    // +0
    // +0.1
    // -0.23
    // -1
    // +123

    // 目前输入不支持科学技术法
    public init?(_ string: String = "0") {

        let separators = CharacterSet(charactersIn: ".,")
        let components = string.components(separatedBy: separators)
        guard components.count == 1 || components.count == 2 else { return nil }

        var s = true
        var b = ""
        var a = ""

        if components[0].hasPrefix("+") {
            b = String(components[0].dropFirst())
        } else if components[0].hasPrefix("-") {
            s = false
            b = String(components[0].dropFirst())
        } else {
            b = components[0]
        }

        if b.isEmpty {
            b = "0"
        }

        if components.count == 2 {
            a = components[1]
        }

        if a.isEmpty {
            a = "0"
        }

        if a == "0" && b == "0" {
            s = true
        }

        guard b.trimmingCharacters(in: .decimalDigits).isEmpty else { return nil }
        guard a.trimmingCharacters(in: .decimalDigits).isEmpty else { return nil }

        symbol = s
        beforeDecPoint = String((b + "#").trimmingCharacters(in: CharacterSet(charactersIn: "0")).dropLast())
        afterDecPoint = String(("#" + a).trimmingCharacters(in: CharacterSet(charactersIn: "0")).dropFirst())

        digits = afterDecPoint.count

        let string = (symbol ? "" : "-") + beforeDecPoint + afterDecPoint
        guard let n = BigInt(string) else { return nil }

        st 
    }


    public static func + (left: Bigdecimal, right: Bigdecimal) -> Bigdecimal {
        return Bigdecimal("")!
    }

}
