//
//  MarketBannerItem.swift
//  ViteBusiness
//
//  Created by Stone on 2019/11/7.
//

import Foundation
import ObjectMapper

struct MarketBannerItem : Mappable {

    var imageUrl: String!
    var linkUrl: String!

    init(imageUrl: String, linkUrl: String) {
        self.imageUrl = imageUrl
        self.linkUrl = linkUrl
    }

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        imageUrl <- map["image"]
        linkUrl <- map["link"]
    }
}
