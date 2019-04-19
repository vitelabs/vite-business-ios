//
//  Storageable.swift
//  ViteBusiness
//
//  Created by Stone on 2019/4/19.
//

import Foundation
import ObjectMapper

public struct StorageConfig {

    public enum Path {
        case app
        case wallet
    }

    public let name: String
    public let path: Path
    public let appending: String?

    init(name: String, path: Path, appending: String? = nil) {
        self.name = name
        self.path = path
        self.appending = appending
    }

    func createFileHelper() -> FileHelper {
        switch path {
        case .app:
            return FileHelper.createForApp(appending: appending)
        case .wallet:
            return FileHelper.createForWallet(appending: appending)
        }
    }
}

public protocol Storageable {
    associatedtype Storage: Mappable
    func getStorageConfig() -> StorageConfig
}

public extension Storageable {

    func save(storage: Storage) {
        let config = getStorageConfig()
        let fileHelper = config.createFileHelper()

        guard let data = storage.toJSONString()?.data(using: .utf8) else {
            assert(false)
            plog(level: .error, log: "\(type(of: storage)) toJSONString failed", tag: .base)
            return
        }

        if let error = fileHelper.writeData(data, relativePath: config.name) {
            assert(false, error.localizedDescription)
            plog(level: .error, log: "\(type(of: storage)) writeData error: \(error.localizedDescription)", tag: .base)
        }
    }

    func readAndGetHash() -> (Storage, String)? {
        let config = getStorageConfig()
        let fileHelper = config.createFileHelper()

        guard let data = fileHelper.contentsAtRelativePath(config.name) else { return nil }
        guard let JSONString = String(data: data, encoding: .utf8) else {
            assert(false)
            plog(level: .error, log: "\(fileHelper.rootPath)/\(config.name) is not UTF-8 String", tag: .base)
            return nil
        }
        guard let ret = Storage(JSONString: JSONString) else {
            assert(false)
            plog(level: .error, log: "serialize \(Storage.self) failed", tag: .base)
            return nil
        }

        return (ret, JSONString.md5())
    }

    func read() -> Storage? {
        return readAndGetHash().map { $0.0 }
    }
}


public extension FileHelper {

    #if DEBUG || TEST
    static func path() -> String {
        return (DebugService.instance.config.appEnvironment == .online) ? "" : DebugService.instance.config.appEnvironment.name + "/"
    }
    static var appPathComponent: String {
        return path() + "app"
    }
    static var walletPathComponent: String {
        return path() + (HDWalletManager.instance.walletBehaviorRelay.value?.uuid ?? "uuid")
    }
    #else
    static var appPathComponent = "app"
    static var walletPathComponent: String {
        return HDWalletManager.instance.walletBehaviorRelay.value?.uuid ?? "uuid"
    }
    #endif

    static func createForApp(appending: String? = nil) -> FileHelper {
        var path = FileHelper.appPathComponent
        if let appending = appending {
            path = path + "/" + appending
        }
        return FileHelper(.library, appending: path)
    }

    static func createForWallet(appending: String? = nil) -> FileHelper {
        var path = FileHelper.walletPathComponent
        if let appending = appending {
            path = path + "/" + appending
        }
        return FileHelper(.library, appending: path)
    }
}

