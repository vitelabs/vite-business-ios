//
//  MarketCache.swift
//  Action
//
//  Created by haoshenyang on 2019/10/12.
//

import UIKit
import SwiftyJSON

public class MarketCache {

    public static let fileHelper = FileHelper.createForApp(appending: "market")

    public class func saveTickerCache(data: Any) {
        guard let data = try? JSON(data).rawData() else {
            return
        }
        fileHelper.writeData(data, relativePath: "marketcache")
    }

    public class func readTickerCache() -> [[String: Any]] {
        guard let data = fileHelper.contentsAtRelativePath("marketcache") else {
            return []
        }
        return JSON(data).arrayObject as? [[String: Any]] ?? []
    }

    public class func saveRateCache(data: Any) {
        guard let data = try? JSON(data).rawData() else {
            return
        }
        fileHelper.writeData(data, relativePath: "ratecache")
    }

    public class func readRateCache() -> [[String: Any]] {
        guard let data = fileHelper.contentsAtRelativePath("ratecache") else {
            return []
        }
        return JSON(data).arrayObject as? [[String: Any]]  ?? []
    }

    public class func saveMiningCache(data: Any) {
        guard let data = try? JSON(data).rawData() else {
            return
        }
        fileHelper.writeData(data, relativePath: "miningcache")
    }

    public class func readMiningCache() -> [String: Any] {
        guard let data = fileHelper.contentsAtRelativePath("miningcache") else {
            return [:]
        }
        return JSON(data).dictionaryObject as? [String: Any] ?? [:]
    }

    public class func saveFavourite(data: String) {
        var favourite = self.readFavourite()
        if !favourite.contains(data) {
            favourite.append(data)

            guard let data = try? JSON(favourite).rawData() else {
                return
            }
            fileHelper.writeData(data, relativePath: "favourite")
        }
    }

    public class func readFavourite() -> [String] {
        guard let data = fileHelper.contentsAtRelativePath("favourite") else {
            return []
        }
        return JSON(data).arrayObject as? [String] ?? []
    }

    public class func deletFavourite(data: String) {
        var favourite = self.readFavourite()
        favourite.removeAll{ $0 == data }
        guard let data = try? JSON(favourite).rawData() else {
            return
        }
        fileHelper.writeData(data, relativePath: "favourite")
    }

    public class func saveSearchHistory(data: String) {
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

    public class func readSearchHistory() -> [String] {
        guard let data = fileHelper.contentsAtRelativePath("searchhistory") else {
            return []
        }
        return JSON(data).arrayObject as? [String] ?? []
    }

    public class func deletSearchHistory() {
        guard let data = try? JSON([String]()).rawData() else {
            return
        }
        fileHelper.writeData(data, relativePath: "searchhistory")
    }
}
