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

    public lazy var appSettingsDriver: Driver<AppSettings> = self.appSettingsBehaviorRelay.asDriver()
    fileprivate var appSettingsBehaviorRelay: BehaviorRelay<AppSettings>!
    var appSettings: AppSettings { return appSettingsBehaviorRelay.value }


    private init() {
        if let appSettings:AppSettings = readMappable() {
            appSettingsBehaviorRelay = BehaviorRelay(value: appSettings)
        } else {
            let currency = LocalizationService.sharedInstance.currentLanguage == .chinese ? CurrencyCode.CNY : CurrencyCode.USD
            var appSettings = AppSettings()
            appSettings.currency = currency
            appSettingsBehaviorRelay = BehaviorRelay(value: appSettings)
        }
    }

    func updateCurrency(_ currency: CurrencyCode) {
        guard currency != appSettingsBehaviorRelay.value.currency else { return }
        var appSettings: AppSettings = appSettingsBehaviorRelay.value
        appSettings.currency = currency
        appSettingsBehaviorRelay.accept(appSettings)
        save(mappable: appSettings)
    }

    func setVitexInviteFalse() {
        guard appSettingsBehaviorRelay.value.guide.vitexInvite else { return }
        var appSettings: AppSettings = appSettingsBehaviorRelay.value
        appSettings.guide.vitexInvite = false
        appSettingsBehaviorRelay.accept(appSettings)
        save(mappable: appSettings)
    }
}

extension AppSettingsService {
    public struct AppSettings: Mappable {
        public var currency: CurrencyCode = .USD
        public var guide = Guide()

        public init?(map: Map) { }
        public mutating func mapping(map: Map) {
            currency <- map["currency"]
            guide <- map["guide"]
        }

        public init() {}
    }

    public struct Guide: Mappable {
        public var vitexInvite = true

        public init?(map: Map) { }
        public mutating func mapping(map: Map) {
            vitexInvite <- map["vitexInvite"]
        }

        public init() {}
    }
}

extension AppSettingsService: Storageable {
    public func getStorageConfig() -> StorageConfig {
        return StorageConfig(name: "AppSettings", path: .app)
    }
}
