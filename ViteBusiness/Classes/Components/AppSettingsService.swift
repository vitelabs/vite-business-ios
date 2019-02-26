//
//  AppSettingsService.swift
//  Action
//
//  Created by Stone on 2019/2/22.
//

import Foundation
import RxSwift
import RxCocoa
import ViteUtils
import ObjectMapper

public class AppSettingsService {
    static let instance = AppSettingsService()

    lazy var currencyDriver: Driver<CurrencyCode> = self.currencyBehaviorRelay.asDriver()
    fileprivate let currencyBehaviorRelay: BehaviorRelay<CurrencyCode>
    fileprivate let fileHelper = FileHelper(.library, appending: FileHelper.appPathComponent)
    fileprivate static let saveKey = "AppSettings"

    private init() {
        if let data = self.fileHelper.contentsAtRelativePath(type(of: self).saveKey),
            let jsonString = String(data: data, encoding: .utf8),
            let settings = AppSettings(JSONString: jsonString) {
            currencyBehaviorRelay = BehaviorRelay(value: settings.currency)
        } else {
            let currency = LocalizationService.sharedInstance.currentLanguage == .chinese ? CurrencyCode.CNY : CurrencyCode.USD
            currencyBehaviorRelay = BehaviorRelay(value: currency)
        }
    }

    private func pri_save() {
        let settings = AppSettings(currency: currencyBehaviorRelay.value)
        if let data = settings.toJSONString()?.data(using: .utf8) {
            if let error = fileHelper.writeData(data, relativePath: type(of: self).saveKey) {
                assert(false, error.localizedDescription)
            }
        }
    }

    func updateCurrency(_ currency: CurrencyCode) {
        guard currency != currencyBehaviorRelay.value else { return }
        currencyBehaviorRelay.accept(currency)
        pri_save()
    }
}

extension AppSettingsService {
    struct AppSettings: Mappable {
        var currency: CurrencyCode = .USD

        public init?(map: Map) { }
        public mutating func mapping(map: Map) {
            currency <- map["currency"]
        }

        init(currency: CurrencyCode) {
            self.currency = currency
        }
    }
}
