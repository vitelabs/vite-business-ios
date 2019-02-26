//
//  TokenInfoAPI.swift
//  ViteBusiness
//
//  Created by Water on 2019/2/25.
//

import Foundation
import ViteBusiness
import Moya

enum TokenInfoAPI {
    case getAllList
}

extension TokenInfoAPI: TargetType {

    var baseURL: URL {
        return COSServer.baseURL.appendingPathComponent("discover")
    }

    var path: String {
        switch self {
        case .getAllList:
            let languageCode = LocalizationService.sharedInstance.currentLanguage.languageCode
            return String(format:"/discover_%@.json" , languageCode)
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        return .requestParameters(parameters: [:], encoding: URLEncoding())
    }

    var sampleData: Data {
        return Data()
    }

    var headers: [String: String]? {
        return nil
    }
}

