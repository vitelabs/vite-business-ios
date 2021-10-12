//
//  PowManager.swift
//  ViteBusiness
//
//  Created by stone on 2021/3/31.
//

import Foundation
import ObjectMapper

public class PowManager {
    public static let instance = PowManager()
    
    fileprivate var storage: Storage = Storage()
    
    private init() {
        if let s: Storage = readMappable() {
            self.storage = s
        }
    }
    
    var isOfficial: Bool { AppSettingsService.instance.appSettings.powConfig.current == nil }
    var delay: Int { isOfficial ? AppConfigService.instance.pDelay : 0 }
    
    func canGetPow(address: String) -> Bool {
        
        if !isOfficial {
            return true
        }
        
        if AppConfigService.instance.getPowTimesPreDay == 0 {
            return false
        }
        
        if let info = storage.addressPowMap[address] {
            let date = Date(timeIntervalSince1970: info.timestamp)
            if Calendar.current.isDate(date, inSameDayAs: Date()) {
                if info.times < AppConfigService.instance.getPowTimesPreDay {
                    return true
                } else {
                    return false
                }
            } else {
                return true
            }
        } else {
            return true
        }
    }
    
    func update(address: String) {
        guard isOfficial else {
            return
        }
        
        if let info = storage.addressPowMap[address] {
            let date = Date(timeIntervalSince1970: info.timestamp)
            if Calendar.current.isDate(date, inSameDayAs: Date()) {
                storage.addressPowMap[address] = Storage.Info(timestamp: info.timestamp, times: info.times + 1)
            } else {
                storage.addressPowMap[address] = Storage.Info(timestamp: Date().timeIntervalSince1970, times: 1)
            }
        } else {
            storage.addressPowMap[address] = Storage.Info(timestamp: Date().timeIntervalSince1970, times: 1)
        }
        self.save(mappable: storage)
    }
}

extension PowManager {

    struct Storage: Mappable {
        fileprivate(set) var addressPowMap: [String: Info] = [:]

        public init?(map: Map) { }
        
        init() {}

        public mutating func mapping(map: Map) {
            addressPowMap <- map["addressPowMap"]
        }
        
        struct Info: Mappable {
            var timestamp: TimeInterval = 0
            var times: Int = 0
            
            init(timestamp: TimeInterval, times: Int) {
                self.timestamp = timestamp
                self.times = times
            }
            
            public init?(map: Map) { }

            public mutating func mapping(map: Map) {
                timestamp <- map["timestamp"]
                times <- map["times"]
            }
        }
    }
}
extension PowManager: Storageable {
    public func getStorageConfig() -> StorageConfig {
        return StorageConfig(name: "PowManager", path: .app)
    }
}
