//
//  Localizator.swift
//  Vite
//
//  Created by Water on 2018/9/5.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit

extension UIViewController {
    func showChangeLanguageList(isSettingPage: Bool = false) {
        let alertController = UIAlertController.init(title: nil, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .cancel, handler: nil)
        cancelAction.setValue(UIColor(netHex: 0x00BEFF), forKey: "titleTextColor")
        alertController.addAction(cancelAction)
        let languages  = ViteLanguage.allLanguages
        for language in languages {
            let action = UIAlertAction(title: language.name, style: .`default`, handler: {_ in
                guard LocalizationService.sharedInstance.currentLanguage != language else { return }
                LocalizationService.sharedInstance.currentLanguage = language
                if isSettingPage {
                    NotificationCenter.default.post(name: .languageChangedInSetting, object: nil)
                }
                NotificationCenter.default.post(name: .languageChanged, object: nil)
            })
            action.setValue(Colors.descGray, forKey: "titleTextColor")
            alertController.addAction(action)
        }
        DispatchQueue.main.async {
             self.present(alertController, animated: true, completion: nil)
        }
    }
}

public class LocalizationService {

    public static let  sharedInstance = LocalizationService()
    fileprivate enum Key: String {
        case collection = "Localization"
        case language = "Language"
    }

    fileprivate var localizationHash: [String: Any] = [:]
    public fileprivate(set) var cacheTextDic: [String: String] = [:]
    fileprivate let fileHelper = FileHelper.createForApp(appending: "Localization")

    public func updateLocalizableIfNeeded(localizationHash: [String: Any]) {
        let language = currentLanguage
        self.localizationHash = localizationHash
        guard let hash = localizationHash[language.code] as? String else { return }
        guard cacheFileHash(language: language) != hash else { return }

        COSProvider.instance.getLocalizable(language: language) { (result) in
            switch result {
            case .success(let jsonString):
                //plog(level: .debug, log: "get \(language.code) localizable finished", tag: .getConfig)
                if let string = jsonString,
                    let data = string.data(using: .utf8) {
                    if let error = self.fileHelper.writeData(data, relativePath: self.cacheFileName(language: language)) {
                        assert(false, error.localizedDescription)
                    }
                    self.reloadCacheLocalization()
                }
            case .failure(let error):
                plog(level: .warning, log: error.viteErrorMessage, tag: .getConfig)
                GCD.delay(2, task: { self.updateLocalizableIfNeeded(localizationHash: self.localizationHash) })
            }
        }

    }

    public var currentLanguage: ViteLanguage = .base {
        didSet {
            guard currentLanguage != oldValue else { return }
            UserDefaultsService.instance.setObject(currentLanguage.code, forKey: Key.language.rawValue, inCollection: Key.collection.rawValue)
            reloadCacheLocalization()
            updateLocalizableIfNeeded(localizationHash: self.localizationHash)
        }
    }

    private init() {
        if let string = UserDefaultsService.instance.objectForKey(Key.language.rawValue, inCollection: Key.collection.rawValue) as? String,
            let l = ViteLanguage(rawValue: string == "zh-Hans" ? "zh" : string) {
            currentLanguage = l
        } else {
            currentLanguage = getSystemLanguage()
            UserDefaultsService.instance.setObject(currentLanguage.code, forKey: Key.language.rawValue, inCollection: Key.collection.rawValue)
        }
        reloadCacheLocalization()
    }
}

// MARK: private function
extension LocalizationService {
    fileprivate func getSystemLanguage() -> ViteLanguage {
        if let code = UserDefaults.standard.array(forKey: "AppleLanguages")?.first as? String {
            if code.hasPrefix("zh") {
                return .chinese
            }
        }
        return .base
    }

    fileprivate func reloadCacheLocalization() {
        let sandboxPath = fileHelper.rootPath + "/\(cacheFileName(language: currentLanguage))"
        if FileManager.default.fileExists(atPath: sandboxPath),
            let ret = NSDictionary(contentsOfFile: sandboxPath) as? [String: String] {
            ret.forEach { (key, value) in
                if let (build, string) = stripBuildNumber(string: key) {
                    if build >= Bundle.main.buildNumberInt {
                        cacheTextDic[string] = value
                    }
                }
            }
        } else {
            cacheTextDic = [:]
        }

        NotificationCenter.default.post(name: .localizedStringChanged, object: nil, userInfo: ["language": currentLanguage, "cacheTextDic": cacheTextDic])
    }

    fileprivate func stripBuildNumber(string: String) -> (Int, String)? {
        if let range = string.range(of:".", options: .literal) {
            if !range.isEmpty {
                let index = string.distance(from: string.startIndex, to: range.lowerBound)
                let prefix = (string as NSString).substring(to: index) as String
                let string = (string as NSString).substring(from: index + 1) as String
                if let number = Int(prefix) {
                    return (number, string)
                } else {
                    return nil
                }
            }
        }
        return nil
    }

    fileprivate func cacheFileHash(language: ViteLanguage) -> String? {
        if let data = self.fileHelper.contentsAtRelativePath(cacheFileName(language: language)),
            let string = String(data: data, encoding: .utf8) {
            return string.md5()
        } else {
            return nil
        }
    }

    fileprivate func cacheFileName(language: ViteLanguage) -> String {
        return "\(language.code).strings"
    }
}
