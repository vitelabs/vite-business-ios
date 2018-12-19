//
//  GetUnconfirmedInfoRequest.swift
//  Vite
//
//  Created by Stone on 2018/9/10.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import ViteWallet
import JSONRPCKit

class GetUnconfirmedInfosRequest: JSONRPCKit.Request {
    typealias Response = [OnroadInfo]

    let address: String

    var method: String {
        return "onroad_getAccountOnroadInfo"
    }

    var parameters: Any? {
        return [address]
    }

    init(address: String) {
        self.address = address
    }

    func response(from resultObject: Any) throws -> [OnroadInfo] {

        if let _ = resultObject as? NSNull {
            return []
        }

        guard let response = resultObject as? [String: Any] else {
            throw ViteError.JSONTypeError()
        }

        var onroadInfoArray = [[String: Any]]()
        if let map = response["tokenBalanceInfoMap"] as?  [String: Any],
            let array = Array(map.values) as? [[String: Any]] {
            onroadInfoArray = array
        }

        let onroadInfos = onroadInfoArray.map({ OnroadInfo(JSON: $0) })
        let ret = onroadInfos.compactMap { $0 }
        return ret
    }
}
