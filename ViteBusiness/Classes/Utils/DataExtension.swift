//
//  DataExtension.swift
//  Action
//
//  Created by Stone on 2019/1/2.
//

import Foundation

public extension Data {
    init?(base64EncodedWithURLSafe base64String: String) {
        var string = base64String

        if base64String.count % 4 == 3 {
            string.append("=")
        } else if base64String.count % 4 == 2 {
            string.append("==")
        } else if base64String.count % 4 == 1 {
            return nil
        }

        string = string.replacingOccurrences(of: "_", with: "/")
        string = string.replacingOccurrences(of: "-", with: "+")
        self.init(base64Encoded: string)
    }

    func base64EncodedWithURLSafeString() -> String {
        var string = base64EncodedString()
        string = string.replacingOccurrences(of: "/", with: "_")
        string = string.replacingOccurrences(of: "+", with: "-")
        string = string.replacingOccurrences(of: "=", with: "")
        return string
    }
}
