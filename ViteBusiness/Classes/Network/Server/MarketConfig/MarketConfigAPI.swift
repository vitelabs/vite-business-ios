//
//  MarketConfigAPI.swift
//  Vite
//
//  Created by Stone on 2018/11/5.
//  Copyright © 2018 vite labs. All rights reserved.
//

import Foundation
import Moya

enum MarketConfigAPI {
    case marketBanners
}

extension MarketConfigAPI: TargetType {

    var baseURL: URL {
        return URL(string: "http://129.226.74.210:1337")!
    }

    var path: String {
        switch self {
        case .marketBanners:
            return "/marketbanners"
        }
    }   

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        return .requestParameters(parameters: ["language": LocalizationService.sharedInstance.currentLanguage.rawValue,
                                               "_sort": "position:asc"], encoding: URLEncoding.queryString)
    }

    var sampleData: Data {
        return Data()
    }

    var headers: [String: String]? {
        return nil
    }
}
