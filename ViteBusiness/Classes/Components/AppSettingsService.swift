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
import APIKit
import JSONRPCKit
import PromiseKit
import ViteWallet

public class AppSettingsService {
    public static let instance = AppSettingsService()

    public lazy var appSettingsDriver: Driver<AppSettings> = self.appSettingsBehaviorRelay.asDriver()
    fileprivate var appSettingsBehaviorRelay: BehaviorRelay<AppSettings>!
    var appSettings: AppSettings { return appSettingsBehaviorRelay.value }


    private init() {
        if let appSettings:AppSettings = readMappable() {
            appSettingsBehaviorRelay = BehaviorRelay(value: appSettings)
        } else {
            let currency: CurrencyCode = {
                switch LocalizationService.sharedInstance.currentLanguage {
                case .chinese:
                    return CurrencyCode.CNY
                case .korea:
                    return CurrencyCode.KRW
                case .russia:
                    return CurrencyCode.RUB
                case .turkey:
                    return CurrencyCode.TRY
                case .vietnam:
                    return CurrencyCode.VND
                case .base:
                    return CurrencyCode.USD
                }
            }()
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

    func updateDexHideSmall(_ dexHideSmall: Bool) {
        guard dexHideSmall != appSettingsBehaviorRelay.value.dexHideSmall else { return }
        var appSettings: AppSettings = appSettingsBehaviorRelay.value
        appSettings.dexHideSmall = dexHideSmall
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
        public var dexHideSmall: Bool = false
        public var chainNodeConfigs: [ChainNodeConfig] = [
            ChainNodeConfig(type: .vite, current: nil),
            ChainNodeConfig(type: .eth, current: nil),
            ]
        public var powConfig = PowConfig(current: nil)
        public var guide = Guide()

        public init?(map: Map) { }
        public mutating func mapping(map: Map) {
            currency <- map["currency"]
            dexHideSmall <- map["dexHideSmall"]
            chainNodeConfigs <- map["chainNodeConfigs"]
            powConfig <- map["powConfig"]
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

extension AppSettingsService {
    public enum ChainType: String {
        case vite = "VITE"
        case eth = "ETHEREUM"
        
        func check(node: String, result: @escaping (Bool) -> ()) {
            guard let url = URL(string: node) else {
                result(false)
                return
            }
            switch self {
            case .vite:
                RPCRequest(for: ViteWallet.RPCServer(url: url), batch: BatchFactory().create(GetSnapshotChainHeightRequest())).promise.done { _ in
                    result(true)
                }.catch { _ in
                    result(false)
                }
            case .eth:
                ETHWalletManager.check(node: url, result: result)
            }
        }
    }
    
    public struct PowConfig: Mappable {
        public var urls: [String] = []
        public var current: String? = nil // nil means use official
        
        public init(current: String?) {
            self.current = current
        }
        
        public init?(map: Map) { }
        public mutating func mapping(map: Map) {
            urls <- map["urls"]
            current <- map["current"]
        }

        public init() {}
    }
    
    public struct ChainNodeConfig: Mappable {
        public var type: ChainType = .vite
        public var nodes: [String] = []
        public var current: String? = nil // nil means use official
        
        public init(type: ChainType, current: String?) {
            self.type = type
            self.current = current
        }
        
        public init?(map: Map) { }
        public mutating func mapping(map: Map) {
            type <- map["type"]
            nodes <- map["nodes"]
            current <- map["current"]
        }

        public init() {}
    }
    
    public func getNodeConfig(type: ChainType) -> ChainNodeConfig {
        appSettings.chainNodeConfigs.filter { $0.type == type }[0]
    }
    
    public func getNode(type: ChainType) -> String {
        let config = appSettings.chainNodeConfigs.filter { $0.type == type }[0]
        switch type {
        case .vite:
            return config.current ?? ViteConst.instance.vite.nodeHttp
        case .eth:
            return config.current ?? ViteConst.instance.eth.nodeHttp
        }
    }
    
    public func updateNode(type: ChainType, config: ChainNodeConfig) {
        var appSettings: AppSettings = appSettingsBehaviorRelay.value
        var index: Int?
        for (i, config) in appSettings.chainNodeConfigs.enumerated() where config.type == type {
            index = i
        }
        guard let i = index else { return }
        appSettings.chainNodeConfigs[i] = config
        appSettingsBehaviorRelay.accept(appSettings)
        save(mappable: appSettings)
    }
    
    public func getPowConfig() -> PowConfig {
        appSettings.powConfig
    }
    
    public func getPowURL() -> String {
        getPowConfig().current ?? ViteConst.instance.vite.nodeHttp
    }
    
    public func updatePow(config: PowConfig) {
        var appSettings: AppSettings = appSettingsBehaviorRelay.value
        appSettings.powConfig = config
        appSettingsBehaviorRelay.accept(appSettings)
        save(mappable: appSettings)
    }
}

extension AppSettingsService: Storageable {
    public func getStorageConfig() -> StorageConfig {
        return StorageConfig(name: "AppSettings", path: .app)
    }
}
