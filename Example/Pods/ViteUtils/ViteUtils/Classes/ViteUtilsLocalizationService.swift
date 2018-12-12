//
//  LocalizationService.swift
//  Pods
//
//  Created by Stone on 2018/12/5.
//

import Foundation

extension Notification.Name {
    public static let localizedStringChanged = NSNotification.Name(rawValue: "net.vite.localized.string.changed")
}

public class ViteUtilsLocalizationService: NSObject {

    static let  sharedInstance = ViteUtilsLocalizationService()
    @objc public static func ocSharedInstance() -> ViteUtilsLocalizationService {
        return sharedInstance
    }

    fileprivate var currentLanguage: ViteLanguage = .base
    fileprivate var cacheTextDic: [String: String] = [:]

    private override init() {
        super.init()
        object_setClass(Bundle(for: ViteUtilsLanguageBundle.self), ViteUtilsLanguageBundle.self)
        NotificationCenter.default.addObserver(forName: .localizedStringChanged, object: nil, queue: nil) { [weak self] notification in
            guard let `self` = self else { return }
            guard let userInfo = notification.userInfo,
                let language = userInfo["language"] as? ViteLanguage,
                let cacheTextDic = userInfo["cacheTextDic"] as? [String: String] else {
                    return
            }

            let prefix = "ViteUtils."
            let dic = NSMutableDictionary()
            for (key, value) in cacheTextDic where key.hasPrefix(prefix) {
                dic[(key as NSString).substring(from: prefix.count) as String] = value
            }
            self.cacheTextDic = dic as! [String : String]
            self.currentLanguage = language
        }
    }
}

private class ViteUtilsLanguageBundle: Bundle {
    
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {

        if let ret = ViteUtilsLocalizationService.sharedInstance.cacheTextDic[key] {
            return ret
        }

        var bundle = Bundle(for: ViteUtilsLanguageBundle.classForCoder())
        if let resourcePath = bundle.path(forResource: "ViteUtils", ofType: "bundle"),
            let resourcesBundle = Bundle(path: resourcePath) {
            bundle = resourcesBundle
        }

        if let path = bundle.path(forResource: ViteUtilsLocalizationService.sharedInstance.currentLanguage.rawValue, ofType: "lproj"),
            let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: key, value: value, table: tableName)
        }

        return super.localizedString(forKey: key, value: value, table: tableName)
    }
}
