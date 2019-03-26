//
//  Bundle.swift
//  Vite
//
//  Created by Water on 2018/9/21.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import ObjectMapper

extension Bundle {
    public var versionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
    }
    public var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "-1"
    }

    public var buildNumberInt: Int {
        return Int(Bundle.main.buildNumber) ?? -1
    }

    public var fullVersion: String {
        let versionNumber = Bundle.main.versionNumber
        let buildNumber = Bundle.main.buildNumber
        return "\(versionNumber) (\(buildNumber))"
    }

    public func getObject<O: Mappable>(forResource name: String?, withExtension ext: String? = nil, subdirectory subpath: String? = nil, localization localizationName: String? = nil) -> O? {
        guard let path = url(forResource: name, withExtension: ext, subdirectory: subpath, localization: localizationName)?.path else {
            return nil
        }
        guard FileManager.default.fileExists(atPath: path) else { return nil }
        guard let string = try? String(contentsOfFile: path) else { return nil }
        guard let ret = O(JSONString: string) else { return nil }
        return ret
    }

    public static func podBundle(for moduleClass: AnyClass, bundleName: String? = nil) -> Bundle? {
        let bundle = Bundle(for: moduleClass)
        if let name = bundleName {
            if let path = bundle.path(forResource: name, ofType: "bundle") {
                return Bundle(path: path)
            } else {
                return nil
            }
        } else {
            return bundle
        }
    }
}

public var isDebug: Bool {
    #if DEBUG
    return true
    #else
    return false
    #endif
}
