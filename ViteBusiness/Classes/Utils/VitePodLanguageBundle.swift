//
//  VitePodLanguageBundle.swift
//  Pods
//
//  Created by Stone on 2018/12/5.
//

import Foundation

extension Notification.Name {
    public static let localizedStringChanged = NSNotification.Name(rawValue: "net.vite.localized.string.changed")
}

open class VitePodLocalizationService: NSObject {

    fileprivate var currentLanguage: ViteLanguage = .base
    fileprivate var cacheTextDic: [String: String] = [:]

    fileprivate var bundleName: String = ""
    public func setBundleName(_ bundleName: String) {
        self.bundleName = bundleName
    }

    public override init() {
        super.init()

        func update(language: ViteLanguage, cacheTextDic: [String: String]) {
            let prefix = "\(self.bundleName)."
            let dic = NSMutableDictionary()
            for (key, value) in cacheTextDic where key.hasPrefix(prefix) {
                dic[(key as NSString).substring(from: prefix.count) as String] = value
            }
            self.cacheTextDic = dic as! [String: String]
            self.currentLanguage = language

        }

        NotificationCenter.default.addObserver(forName: .localizedStringChanged, object: nil, queue: nil) { [weak self] notification in
            guard let `self` = self else { return }
            guard let userInfo = notification.userInfo,
                let language = userInfo["language"] as? ViteLanguage,
                let cacheTextDic = userInfo["cacheTextDic"] as? [String: String] else {
                    return
            }

            update(language: language, cacheTextDic: cacheTextDic)
        }

        update(language: LocalizationService.sharedInstance.currentLanguage, cacheTextDic: LocalizationService.sharedInstance.cacheTextDic)
    }
}

open class VitePodLanguageBundle: Bundle {

    open class func podLocalizationServicesharedInstance() -> VitePodLocalizationService {
        fatalError()
    }

    override open func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {

        let serviceSharedInstance = type(of: self).podLocalizationServicesharedInstance()
        if let ret = serviceSharedInstance.cacheTextDic[key] {
            return ret
        }

        var appBundle = Bundle(for: type(of: self).self)
        if let resourcePath = appBundle.path(forResource: serviceSharedInstance.bundleName, ofType: "bundle"),
            let resourcesBundle = Bundle(path: resourcePath) {
            appBundle = resourcesBundle
        }

        if let path = appBundle.path(forResource: serviceSharedInstance.currentLanguage.resourceName, ofType: "lproj"),
           let bundle = Bundle(path: path),
           let basePath = appBundle.path(forResource: ViteLanguage.base.resourceName, ofType: "lproj"),
           let baseBundle = Bundle(path: basePath) {
            let baseValue = baseBundle.localizedString(forKey: key, value: value, table: tableName)
            return bundle.localizedString(forKey: key, value: baseValue, table: tableName)
        }

        return super.localizedString(forKey: key, value: value, table: tableName)
    }
}
