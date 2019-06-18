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
    func getStorageConfig() -> StorageConfig
}

public extension Storageable {

    func save(data: Data) {
        let config = getStorageConfig()
        let fileHelper = config.createFileHelper()

        if let error = fileHelper.writeData(data, relativePath: config.name) {
            assert(false, error.localizedDescription)
            plog(level: .error, log: "\(fileHelper.rootPath)/\(config.name) writeData error: \(error.localizedDescription)", tag: .base)
        }
    }

    func save(string: String) {
        guard let data = string.data(using: .utf8) else {
            assert(false)
            plog(level: .error, log: "\(type(of: self)) convert to data failed", tag: .base)
            return
        }
        save(data: data)
    }

    func save(mappable: BaseMappable) {
        guard let string = mappable.toJSONString() else {
            assert(false)
            plog(level: .error, log: "\(type(of: mappable)) toJSONString failed", tag: .base)
            return
        }
        save(string: string)
    }

    func save<E: BaseMappable>(mappable: Array<E>) {
        guard let string = mappable.toJSONString() else {
            assert(false)
            plog(level: .error, log: "\(type(of: mappable)) toJSONString failed", tag: .base)
            return
        }
        save(string: string)
    }

    func readData() -> Data? {
        let config = getStorageConfig()
        let fileHelper = config.createFileHelper()
        return fileHelper.contentsAtRelativePath(config.name)
    }

    func readString() -> String? {
        guard let data = readData() else { return nil }
        return String(data: data, encoding: .utf8)
    }



    func readMappableAndHash<M: BaseMappable>() -> (M, String)? {
        guard let JSONString = readString() else { return nil }
        guard let ret = M(JSONString: JSONString) else {
            assert(false)
            plog(level: .error, log: "\(M.self) serialize  failed", tag: .base)
            return nil
        }

        return (ret, JSONString.md5())
    }

    func readMappable<M: BaseMappable>() -> M? {
        return readMappableAndHash().map { $0.0 }
    }
}


public extension FileHelper {

    #if DAPP
    static var appPathComponent = "app"
    static var walletPathComponent: String {
        return HDWalletManager.instance.walletBehaviorRelay.value?.uuid ?? "uuid"
    }
    #elseif DEBUG || TEST
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

