//
//  AppConfigService.swift
//  Vite
//
//  Created by Stone on 2018/10/22.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional
import ObjectMapper

public class AppConfigService {
    public static let instance = AppConfigService()

    lazy var configDriver: Driver<AppConfig> = self.configBehaviorRelay.asDriver()
    fileprivate var configBehaviorRelay: BehaviorRelay<AppConfig>!
    fileprivate var appConfigHash: String?
    fileprivate var lastBuildNumber: Int?
    public var pDelay: Int = 3

    public var isOnlineVersion: Bool {
        if let lastBuildNumber = lastBuildNumber, lastBuildNumber >= Bundle.main.buildNumberInt {
            return true
        } else {
            return false
        }
    }

    private init() {
        if let (config, hash): (AppConfig, String) = readMappableAndHash() {
            appConfigHash = hash
            configBehaviorRelay = BehaviorRelay(value: config)
        } else if let bundle = Bundle.podBundle(for: type(of: self).self, bundleName: "ViteBusiness"),
            let config: AppConfig = bundle.getObject(forResource: getStorageConfig().name, withExtension: nil, subdirectory: "Config") {
            appConfigHash = nil
            configBehaviorRelay = BehaviorRelay(value: config)
        } else {
            fatalError("app file not found in bundle")
        }
    }

    public func start() {
        getConfigHash()
    }

    fileprivate func getConfigHash() {
        COSProvider.instance.getConfigHash { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case .success(let jsonString):
                plog(level: .debug, log: "get config hash finished", tag: .getConfig)
                guard let string = jsonString else { return }
                guard let configHash = ConfigHash(JSONString: string) else { return }
                self.lastBuildNumber = configHash.lastBuildNumber
                self.pDelay = configHash.pDelay ?? self.pDelay
                self.getAppSettingsConfig(hash: configHash.appConfig)
                LocalizationService.sharedInstance.updateLocalizableIfNeeded(localizationHash: configHash.localization)
            case .failure(let error):
                plog(level: .warning, log: error.viteErrorMessage, tag: .getConfig)
                GCD.delay(2, task: { self.getConfigHash() })
            }
        }
    }

    fileprivate func getAppSettingsConfig(hash: String?) {
        guard let hash = hash, hash != appConfigHash else { return }

        COSProvider.instance.getAppConfig { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case .success(let jsonString):
                plog(level: .debug, log: "get app config finished", tag: .getConfig)
                guard let string = jsonString else { return }
                self.appConfigHash = string.md5()
                plog(level: .debug, log: "md5: \(self.appConfigHash)", tag: .getConfig)
                if let config = AppConfig(JSONString: string) {
                    self.configBehaviorRelay.accept(config)
                    // make sure md5 not change
                    self.save(string: string)
                }

            case .failure(let error):
                plog(level: .warning, log: error.viteErrorMessage, tag: .getConfig)
                GCD.delay(2, task: { self.getAppSettingsConfig(hash: hash) })
            }
        }
    }
}

extension AppConfigService {

    public struct AppConfig: Mappable {
        fileprivate(set) var myPage: [String: Any] = [:]
        fileprivate(set) var defaultTokenInfos: [[String: Any]] = []

        public init?(map: Map) { }

        public mutating func mapping(map: Map) {
            myPage <- map["my_page"]
            defaultTokenInfos <- map["default_tokenInfos"]
        }
    }

    public struct ConfigHash: Mappable {
        fileprivate(set) var appConfig: String?
        fileprivate(set) var lastBuildNumber: Int?
        fileprivate(set) var pDelay: Int?
        fileprivate(set) var localization: [String: Any] = [:]

        public init?(map: Map) { }

        public mutating func mapping(map: Map) {
            appConfig <- map["AppConfig"]
            lastBuildNumber <- map["LastBuildNumber"]
            pDelay <- map["pDelay"]
            localization <- map["Localization"]
        }
    }
}

extension AppConfigService: Storageable {
    public func getStorageConfig() -> StorageConfig {
        return StorageConfig(name: "AppConfig", path: .app)
    }
}
