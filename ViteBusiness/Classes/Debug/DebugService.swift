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
import ViteEthereum
import web3swift

#if DEBUG || TEST
extension Notification.Name {
    public static let appEnvironmentDidChange = NSNotification.Name(rawValue: "Vite_appEnvironmentDidChange")
}
#endif


public class DebugService {
    public static let instance = DebugService()
    fileprivate let fileHelper = FileHelper(.library, appending: FileHelper.appPathComponent)
    fileprivate static let saveKey = "DebugService"

//    let rpcDefaultTestEnvironmentUrl = URL(string: "http://45.40.197.46:48132")!
    let rpcDefaultTestEnvironmentUrl = URL(string: "http://148.70.30.139:48132")!
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
        #if DEBUG || TEST
        NotificationCenter.default.post(name: NSNotification.Name.appEnvironmentDidChange, object: nil)
        #endif
        updateETHServer()
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
                    AppConfigService.instance.start()
                    MyTokenInfosService.instance.clear()
                    TokenListService.instance.fetchTokenListServerData()
                }
            }
        }
    }

    public struct Config: Mappable, Equatable {

        var rpcUseOnlineUrl = false
        var rpcCustomUrl = ""
        var browserUseOnlineUrl = false
        var browserCustomUrl = ""
        var configEnvironment = ConfigEnvironment.test
        var showStatisticsToast = false
        var reportEventInDebug = false
        var urls: [String] = []
        var ignoreCheckUpdate = true
        public var ignoreWhiteList = true

        init(rpcUseOnlineUrl: Bool,
             rpcCustomUrl: String?,
             browserUseOnlineUrl: Bool,
             browserCustomUrl: String?,
             configEnvironment: ConfigEnvironment,
             showStatisticsToast: Bool?,
             reportEventInDebug: Bool?,
             urls: [String]?,
             ignoreCheckUpdate: Bool?,
             ignoreWhiteList: Bool?) {

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
            if let urls = urls {
                self.urls = urls
            }
            if let ignoreCheckUpdate = ignoreCheckUpdate {
                self.ignoreCheckUpdate = ignoreCheckUpdate
            }
            if let ignoreWhiteList = ignoreWhiteList {
                self.ignoreWhiteList = ignoreWhiteList
            }

        }

        static var test: Config {
            return Config(rpcUseOnlineUrl: false,
                          rpcCustomUrl: "",
                          browserUseOnlineUrl: false,
                          browserCustomUrl: "",
                          configEnvironment: .test,
                          showStatisticsToast: nil,
                          reportEventInDebug: nil,
                          urls: nil,
                          ignoreCheckUpdate: nil,
                          ignoreWhiteList: nil)
        }

        static var stage: Config {
            return Config(rpcUseOnlineUrl: true,
                          rpcCustomUrl: nil,
                          browserUseOnlineUrl: true,
                          browserCustomUrl: nil,
                          configEnvironment: .stage,
                          showStatisticsToast: nil,
                          reportEventInDebug: nil,
                          urls:nil,
                          ignoreCheckUpdate: nil,
                          ignoreWhiteList: nil)
        }

        static var online: Config {
            return Config(rpcUseOnlineUrl: true,
                          rpcCustomUrl: nil,
                          browserUseOnlineUrl: true,
                          browserCustomUrl: nil,
                          configEnvironment: .online,
                          showStatisticsToast: nil,
                          reportEventInDebug: nil,
                          urls:nil,
                          ignoreCheckUpdate: nil,
                          ignoreWhiteList: nil)
        }

        public var appEnvironment: AppEnvironment {
            get {
                let test = Config.test
                let stage = Config.stage
                let online = Config.online

                if rpcUseOnlineUrl == test.rpcUseOnlineUrl &&
                    browserUseOnlineUrl == test.browserUseOnlineUrl &&
                    configEnvironment == test.configEnvironment &&
                    rpcCustomUrl == test.rpcCustomUrl &&
                    browserCustomUrl == test.browserCustomUrl {
                    return .test
                } else if rpcUseOnlineUrl == stage.rpcUseOnlineUrl &&
                    browserUseOnlineUrl == stage.browserUseOnlineUrl &&
                    configEnvironment == stage.configEnvironment {
                    return .stage
                } else if rpcUseOnlineUrl == online.rpcUseOnlineUrl &&
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
            rpcUseOnlineUrl <- map["rpcUseOnlineUrl"]
            rpcCustomUrl <- map["rpcCustomUrl"]
            browserUseOnlineUrl <- map["browserUseOnlineUrl"]
            browserCustomUrl <- map["browserCustomUrl"]
            configEnvironment <- map["configEnvironment"]
            showStatisticsToast <- map["showStatisticsToast"]
            reportEventInDebug <- map["reportEventInDebug"]
            urls <- map["urls"]
            ignoreCheckUpdate <- map["ignoreCheckUpdate"]
            ignoreWhiteList <- map["ignoreWhiteList"]
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

    private func updateETHServer() {
        switch config.appEnvironment {
        case .test:
            EtherWallet.network.changeHost(Web3.Vite_InfuraRopstenWeb3())
        case .stage:
            EtherWallet.network.changeHost(Web3.Vite_InfuraMainnetWeb3())
        case .online:
            EtherWallet.network.changeHost(Web3.Vite_InfuraMainnetWeb3())
        case .custom:
            EtherWallet.network.changeHost(Web3.Vite_InfuraRopstenWeb3())
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
        updateETHServer()
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
