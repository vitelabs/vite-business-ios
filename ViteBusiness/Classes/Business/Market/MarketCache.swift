//
//  MarketCache.swift
//  Action
//
//  Created by haoshenyang on 2019/10/12.
//

import UIKit
import SwiftyJSON

class MarketCache {

    static let fileHelper = FileHelper.createForApp(appending: "market")

    class func saveTickerCache(data: Any) {
        guard let data = try? JSON(data).rawData() else {
            return
        }
        fileHelper.writeData(data, relativePath: "marketcache")
    }

    class func readTickerCache() -> [[String: Any]] {
        guard let data = fileHelper.contentsAtRelativePath("marketcache") else {
            return []
        }
        return JSON(data).arrayObject as? [[String: Any]] ?? []
    }

    class func saveRateCache(data: Any) {
        guard let data = try? JSON(data).rawData() else {
            return
        }
        fileHelper.writeData(data, relativePath: "ratecache")
    }

    class func readRateCache() -> [[String: Any]] {
        guard let data = fileHelper.contentsAtRelativePath("ratecache") else {
            return []
        }
        return JSON(data).arrayObject as? [[String: Any]]  ?? []
    }

    class func saveMiningCache(data: Any) {
        guard let data = try? JSON(data).rawData() else {
            return
        }
        fileHelper.writeData(data, relativePath: "miningcache")
    }

    class func readMiningCache() -> [String: Any] {
        guard let data = fileHelper.contentsAtRelativePath("miningcache") else {
            return [:]
        }
        return JSON(data).dictionaryObject as? [String: Any] ?? [:]
    }

    class func saveFavourite(data: String) {
        var favourite = self.readFavourite()
        if !favourite.contains(data) {
            favourite.append(data)

            guard let data = try? JSON(favourite).rawData() else {
                return
            }
            fileHelper.writeData(data, relativePath: "favourite")
        }
    }

    class func readFavourite() -> [String] {
        guard let data = fileHelper.contentsAtRelativePath("favourite") else {
            return []
        }
        return JSON(data).arrayObject as? [String] ?? []
    }

    class func deletFavourite(data: String) {
        var favourite = self.readFavourite()
        favourite.removeAll{ $0 == data }
        guard let data = try? JSON(favourite).rawData() else {
            return
        }
        fileHelper.writeData(data, relativePath: "favourite")
    }

    class func saveSearchHistory(data: String) {
        var favourite = self.readFavourite()
        if !favourite.contains(data) {
            favourite.append(data)
            if favourite.count > 50 {
                favourite.remove(at: 0)
            }
            guard let data = try? JSON(favourite).rawData() else {
                return
            }
            fileHelper.writeData(data, relativePath: "searchhistory")
        }
    }

    class func readSearchHistory() -> [String] {
        guard let data = fileHelper.contentsAtRelativePath("searchhistory") else {
            return []
        }
        return JSON(data).arrayObject as? [String] ?? []
    }

    class func deletSearchHistory() {
        guard let data = try? JSON([String]()).rawData() else {
            return
        }
        fileHelper.writeData(data, relativePath: "searchhistory")
    }
}
