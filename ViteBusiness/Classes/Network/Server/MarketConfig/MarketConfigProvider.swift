//
//  MarketConfigProvider.swift
//  Vite
//
//  Created by Stone on 2018/11/5.
//  Copyright © 2018 vite labs. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import Moya
import SwiftyJSON
import ObjectMapper
import enum Alamofire.Result

class MarketConfigProvider: MoyaProvider<MarketConfigAPI> {
    static let instance = MarketConfigProvider(manager: Manager(
        configuration: {
            var configuration = URLSessionConfiguration.default
            configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
            return configuration
    }(),
        serverTrustPolicyManager: ServerTrustPolicyManager(policies: [:])
    ))
}

extension MarketConfigProvider {

    func getMarketBanner(completion: @escaping (Result<[MarketBannerItem]>) -> Void) {
            request(.marketBanners) { (result) in
               switch result {
               case .success(let response):
                   let array = JSON(response.data).array ?? []
                   let ret = array.compactMap { json -> MarketBannerItem? in
                       if let imageUrl = json["image"]["url"].string,
                           let linkUrl = json["link"].string {
                            let url = MarketConfigAPI.marketBanners.baseURL.appendingPathComponent(imageUrl).absoluteString
                            return MarketBannerItem(imageUrl: url, linkUrl: linkUrl)
                       } else {
                            return nil
                       }
                   }
                   completion(Result.success(ret))
                case .failure(let error):
                    completion(Result.failure(error))
                }
            }
        }
}
