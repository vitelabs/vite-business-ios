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
import ViteUtils

public class AppConfigService {
    static let instance = AppConfigService()

    lazy var configDriver: Driver<AppConfig> = self.configBehaviorRelay.asDriver()
    fileprivate let configBehaviorRelay: BehaviorRelay<AppConfig>
    fileprivate let fileHelper = FileHelper(.library, appending: FileHelper.appPathComponent)
    fileprivate static let saveKey = "AppConfig"

    fileprivate var appConfigHash: String?

    private init() {
        if let data = self.fileHelper.contentsAtRelativePath(type(of: self).saveKey),
            let jsonString = String(data: data, encoding: .utf8),
            let config = AppConfig(JSONString: jsonString) {
            appConfigHash = jsonString.md5()
            configBehaviorRelay = BehaviorRelay(value: config)
        } else if let bundle = Bundle.podBundle(for: type(of: self).self, bundleName: "ViteBusiness"),
            let config: AppConfig = bundle.getObject(forResource: type(of: self).saveKey, withExtension: nil, subdirectory: "Config") {
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
                if let data = string.data(using: .utf8) {
                    if let error = self.fileHelper.writeData(data, relativePath: type(of: self).saveKey) {
                        assert(false, error.localizedDescription)
                    }
                }

                if let config = AppConfig(JSONString: string) {
                    self.configBehaviorRelay.accept(config)
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
        fileprivate(set) var defaultTokens: [String: Any] = [:]

        public init?(map: Map) { }

        public mutating func mapping(map: Map) {
            myPage <- map["my_page"]
            defaultTokens <- map["default_tokens"]
        }
    }

    public struct ConfigHash: Mappable {
        fileprivate(set) var appConfig: String?
        fileprivate(set) var localization: [String: Any] = [:]

        public init?(map: Map) { }

        public mutating func mapping(map: Map) {
            appConfig <- map["AppConfig"]
            localization <- map["Localization"]
        }
    }
}
