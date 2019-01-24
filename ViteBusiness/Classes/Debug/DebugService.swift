//
//  DebugService.swift
//  Vite
//
//  Created by Stone on 2018/10/23.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import ViteWallet
import Foundation
import ObjectMapper
import ViteUtils

public class DebugService {
    public static let instance = DebugService()
    fileprivate let fileHelper = FileHelper(.library, appending: FileHelper.appPathComponent)
    fileprivate static let saveKey = "DebugService"

    let rpcDefaultTestEnvironmentUrl = URL(string: "http://45.40.197.46:48132")!
    let browserDefaultTestEnvironmentUrl = URL(string: "http://132.232.134.168:8080")!

    public enum AppEnvironment: Int {
        case test = 0
        case stage = 1
        case online = 2
        case custom = -1

        var name: String {
            switch self {
            case .test:
                return "Test"
            case .stage:
                return "Stage"
            case .online:
                return "Online"
            case .custom:
                return "Custom"
            }
        }

        static var allValues: [AppEnvironment] = [.test, .stage, .online]
    }

    public enum ConfigEnvironment: Int {
        case test = 0
        case stage = 1
        case online = 2

        static var allValues: [ConfigEnvironment] = [.test, .stage, .online]

        var name: String {
            switch self {
            case .test:
                return "Test"
            case .stage:
                return "Stage"
            case .online:
                return "Online"
            }
        }

        var url: URL {
            switch self {
            case .test:
                return URL(string: "https://testnet-vite-test-1257137467.cos.ap-beijing.myqcloud.com")!
            case .stage:
                return URL(string: "https://testnet-vite-stage-1257137467.cos.ap-beijing.myqcloud.com")!
            case .online:
                return URL(string: "https://testnet-vite-1257137467.cos.ap-hongkong.myqcloud.com")!
            }
        }
    }

    func setAppEnvironment(_ appEnvironment: AppEnvironment) {
        switch appEnvironment {
        case .test:
            config = Config.test
        case .stage:
            config = Config.stage
        case .online:
            config = Config.online
        case .custom:
            break
        }
    }

    public var config: Config {
        didSet {
            guard config != oldValue else { return }
            pri_save()

            if config.rpcUseOnlineUrl != oldValue.rpcUseOnlineUrl || config.rpcCustomUrl != oldValue.rpcCustomUrl {
                updateRPCServerProvider()
            }

            if config.configEnvironment != oldValue.configEnvironment {
                DispatchQueue.main.async {
                    AppUpdateService.checkUpdate()
                    AppSettingsService.instance.start()
                }
            }
        }
    }

    public struct Config: Mappable, Equatable {

        var useBigDifficulty = true
        var rpcUseOnlineUrl = false
        var rpcCustomUrl = ""
        var browserUseOnlineUrl = false
        var browserCustomUrl = ""
        var configEnvironment = ConfigEnvironment.test
        var showStatisticsToast = false
        var reportEventInDebug = false

        init(useBigDifficulty: Bool,
             rpcUseOnlineUrl: Bool,
             rpcCustomUrl: String?,
             browserUseOnlineUrl: Bool,
             browserCustomUrl: String?,
             configEnvironment: ConfigEnvironment,
             showStatisticsToast: Bool?,
             reportEventInDebug: Bool?) {

            self.useBigDifficulty = useBigDifficulty
            self.rpcUseOnlineUrl = rpcUseOnlineUrl
            if let rpcCustomUrl = rpcCustomUrl {
                self.rpcCustomUrl = rpcCustomUrl
            }
            self.browserUseOnlineUrl = browserUseOnlineUrl
            if let browserCustomUrl = browserCustomUrl {
                self.browserCustomUrl = browserCustomUrl
            }
            self.configEnvironment = configEnvironment
            if let showStatisticsToast = showStatisticsToast {
                self.showStatisticsToast = showStatisticsToast
            }
            if let reportEventInDebug = reportEventInDebug {
                self.reportEventInDebug = reportEventInDebug
            }
        }

        static var test: Config {
            return Config(useBigDifficulty: true,
                          rpcUseOnlineUrl: false,
                          rpcCustomUrl: "",
                          browserUseOnlineUrl: false,
                          browserCustomUrl: "",
                          configEnvironment: .test,
                          showStatisticsToast: nil,
                          reportEventInDebug: nil)
        }

        static var stage: Config {
            return Config(useBigDifficulty: true,
                          rpcUseOnlineUrl: true,
                          rpcCustomUrl: nil,
                          browserUseOnlineUrl: true,
                          browserCustomUrl: nil,
                          configEnvironment: .stage,
                          showStatisticsToast: nil,
                          reportEventInDebug: nil)
        }

        static var online: Config {
            return Config(useBigDifficulty: true,
                          rpcUseOnlineUrl: true,
                          rpcCustomUrl: nil,
                          browserUseOnlineUrl: true,
                          browserCustomUrl: nil,
                          configEnvironment: .online,
                          showStatisticsToast: nil,
                          reportEventInDebug: nil)
        }

        public var appEnvironment: AppEnvironment {
            get {
                let test = Config.test
                let stage = Config.stage
                let online = Config.online

                if useBigDifficulty == test.useBigDifficulty &&
                    rpcUseOnlineUrl == test.rpcUseOnlineUrl &&
                    browserUseOnlineUrl == test.browserUseOnlineUrl &&
                    configEnvironment == test.configEnvironment &&
                    rpcCustomUrl == test.rpcCustomUrl &&
                    browserCustomUrl == test.browserCustomUrl {
                    return .test
                } else if useBigDifficulty == stage.useBigDifficulty &&
                    rpcUseOnlineUrl == stage.rpcUseOnlineUrl &&
                    browserUseOnlineUrl == stage.browserUseOnlineUrl &&
                    configEnvironment == stage.configEnvironment {
                    return .stage
                } else if useBigDifficulty == online.useBigDifficulty &&
                    rpcUseOnlineUrl == online.rpcUseOnlineUrl &&
                    browserUseOnlineUrl == online.browserUseOnlineUrl &&
                    configEnvironment == online.configEnvironment {
                    return .online
                } else {
                    return .custom
                }
            }
        }

        public init?(map: Map) { }

        mutating public func mapping(map: Map) {
            useBigDifficulty <- map["useBigDifficulty"]
            rpcUseOnlineUrl <- map["rpcUseOnlineUrl"]
            rpcCustomUrl <- map["rpcCustomUrl"]
            browserUseOnlineUrl <- map["browserUseOnlineUrl"]
            browserCustomUrl <- map["browserCustomUrl"]
            configEnvironment <- map["configEnvironment"]
            showStatisticsToast <- map["showStatisticsToast"]
            reportEventInDebug <- map["reportEventInDebug"]
        }
    }

    private func updateRPCServerProvider() {
        if config.rpcUseOnlineUrl {
            Provider.default.update(server: ViteWallet.RPCServer.shared)
        } else {
            if let url = URL(string: config.rpcCustomUrl) {
                Provider.default.update(server: ViteWallet.RPCServer(url: url))
            } else {
                Provider.default.update(server: ViteWallet.RPCServer(url: rpcDefaultTestEnvironmentUrl))
            }
        }
    }

    private init() {

        if let data = self.fileHelper.contentsAtRelativePath(type(of: self).saveKey),
            let jsonString = String(data: data, encoding: .utf8),
            let config = Config(JSONString: jsonString) {
            self.config = config
        } else {
            self.config = Config.test
        }

        updateRPCServerProvider()
    }

    fileprivate func pri_save() {
        if let data = config.toJSONString()?.data(using: .utf8) {
            if let error = fileHelper.writeData(data, relativePath: type(of: self).saveKey) {
                assert(false, error.localizedDescription)
            }
        }
    }

    var debugViewControllers: [(String, () -> UIViewController)] = []
}

public extension DebugService {
    func addDebugViewController(title: String, viewController: @autoclosure @escaping () -> UIViewController) {
        for (t, _) in debugViewControllers {
            if t == title {
                return
            }
        }
        debugViewControllers.append((title, viewController))
    }
}
