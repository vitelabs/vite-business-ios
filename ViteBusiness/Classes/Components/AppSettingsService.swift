//
//  AppSettingsService.swift
//  Action
//
//  Created by Stone on 2019/2/22.
//

import Foundation
import RxSwift
import RxCocoa
import ObjectMapper

public class AppSettingsService {
    public static let instance = AppSettingsService()

    public lazy var currencyDriver: Driver<CurrencyCode> = self.currencyBehaviorRelay.asDriver()
    fileprivate var currencyBehaviorRelay: BehaviorRelay<CurrencyCode>!

    private init() {
        if let settings:AppSettings = readMappable() {
            currencyBehaviorRelay = BehaviorRelay(value: settings.currency)
        } else {
            let currency = LocalizationService.sharedInstance.currentLanguage == .chinese ? CurrencyCode.CNY : CurrencyCode.USD
            currencyBehaviorRelay = BehaviorRelay(value: currency)
        }
    }

    func updateCurrency(_ currency: CurrencyCode) {
        guard currency != currencyBehaviorRelay.value else { return }
        currencyBehaviorRelay.accept(currency)
        save(mappable: AppSettings(currency: currencyBehaviorRelay.value))
    }

    var currency: CurrencyCode {
        return currencyBehaviorRelay.value
    }
}

extension AppSettingsService {
    struct AppSettings: Mappable {
        var currency: CurrencyCode = .USD

        init?(map: Map) { }
        mutating func mapping(map: Map) {
            currency <- map["currency"]
        }

        init(currency: CurrencyCode) {
            self.currency = currency
        }
    }
}

extension AppSettingsService: Storageable {
    public func getStorageConfig() -> StorageConfig {
        return StorageConfig(name: "AppSettings", path: .app)
    }
}
