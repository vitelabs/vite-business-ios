//
//  UserDefaultsService.swift
//  Vite
//
//  Created by Stone on 2018/10/22.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation

public class UserDefaultsService {
    public static let instance = UserDefaultsService()
    typealias DictionaryType = [String: Any]
    fileprivate let queue = DispatchQueue(label: "net.vite.user.defaults")
    fileprivate static let userDefaultsKey = "com.vite.user.defaults"
    fileprivate var dic: DictionaryType = [:]

    private init() {
        queue.sync {
            if let dic = UserDefaults.standard.object(forKey: type(of: self).userDefaultsKey) as? DictionaryType {
                self.dic = dic
            }
        }
    }

    public func setObject(_ object: Any, forKey key: String, inCollection collection: String) {
        queue.sync {
            var collectionDic = DictionaryType()
            if let dic = dic[collection] as? DictionaryType {
                collectionDic = dic
            }

            collectionDic[key] = object
            dic[collection] = collectionDic

            UserDefaults.standard.set(dic, forKey: type(of: self).userDefaultsKey)
            UserDefaults.standard.synchronize()
        }
    }

    public func objectForKey(_ key: String, inCollection collection: String) -> Any? {
        var ret: Any?
        queue.sync {
            if let dic = dic[collection] as? DictionaryType {
                ret = dic[key]
            }
        }
        return ret
    }
}
