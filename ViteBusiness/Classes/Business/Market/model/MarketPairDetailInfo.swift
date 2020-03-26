//
//  MarketPairDetailInfo.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/25.
//

import ObjectMapper

struct MarketPairDetailInfo : Mappable {
    var tradeTokenDetail : TokenDetail = TokenDetail()
    var quoteTokenDetail : TokenDetail = TokenDetail()
    var operatorInfo : OperatorInfo = OperatorInfo()

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        tradeTokenDetail <- map["tradeTokenDetail"]
        quoteTokenDetail <- map["quoteTokenDetail"]
        operatorInfo <- map["operatorInfo"]
    }
}


extension MarketPairDetailInfo {

    struct Overview : Mappable {
        var en : String = ""
        var zh : String = ""

        init() {}

        init?(map: Map) {

        }

        mutating func mapping(map: Map) {
            en <- map["en"]
            zh <- map["zh"]
        }

        var value: String { LocalizationService.sharedInstance.currentLanguage == .chinese ? zh : en }
    }

    struct Links : Mappable {
        var website : [String] = []
        var whitepaper : [String] = []
        var explorer : [String] = []
        var github : [String] = []

        var facebook : [String] = []
        var telegram : [String] = []
        var reddit : [String] = []
        var twitter : [String] = []
        var discord : [String] = []

        init() {}

        init?(map: Map) {

        }

        mutating func mapping(map: Map) {

            website <- map["website"]
            whitepaper <- map["whitepaper"]
            explorer <- map["explorer"]

            facebook <- map["facebook"]
            telegram <- map["telegram"]
            reddit <- map["reddit"]
            twitter <- map["twitter"]
            discord <- map["discord"]
        }

    }

    struct Gateway : Mappable {
        var name : String = ""
        var icon : String = ""
        var policy : Overview = Overview()
        var overview : Overview = Overview()
        var links : Links = Links()
        var support : String = ""
        var serviceSupport : String = ""
        var isOfficial : Bool = false
        var level : Int = 0
        var website : String = ""
        var mappedToken : MappedTokenInfo?
        var url : String = ""

        init?(map: Map) {

        }

        init() { }

        mutating func mapping(map: Map) {

            name <- map["name"]
            icon <- map["icon"]
            policy <- map["policy"]
            overview <- map["overview"]
            links <- map["links"]
            support <- map["support"]
            serviceSupport <- map["serviceSupport"]
            isOfficial <- map["isOfficial"]
            level <- map["level"]
            website <- map["website"]
            mappedToken <- map["mappedToken"]
            url <- map["url"]
        }

    }

    struct OperatorInfo : Mappable {
        var address : String = ""
        var name : String = ""
        var icon : String = ""
        var overview : Overview = Overview()
        var links : Links = Links()
        var tradePairs : [String: [String]] = [:]
        var support : String = ""
        var gateway : String = ""
        var level : Int = 0

        init() {}
        
        init?(map: Map) {

        }

        mutating func mapping(map: Map) {

            address <- map["address"]
            name <- map["name"]
            icon <- map["icon"]
            overview <- map["overview"]
            links <- map["links"]
            tradePairs <- map["tradePairs"]
            support <- map["support"]
            gateway <- map["gateway"]
            level <- map["level"]
        }

    }

    struct TokenDetail : Mappable {
        var tokenId : String = ""
        var name : String = ""
        var symbol : String = ""
        var originalSymbol : String = ""
        var totalSupply : String = ""
        var publisher : String = ""
        var tokenDecimals : Int = 0
        var tokenAccuracy : String = ""
        var publisherDate : Int = 0
        var reissue : Int = 0
        var urlIcon : String = ""
        var gateway : Gateway?
        var links : Links = Links()
        var overview : Overview = Overview()

        init() {}

        init?(map: Map) {

        }

        mutating func mapping(map: Map) {

            tokenId <- map["tokenId"]
            name <- map["name"]
            symbol <- map["symbol"]
            originalSymbol <- map["originalSymbol"]
            totalSupply <- map["totalSupply"]
            publisher <- map["publisher"]
            tokenDecimals <- map["tokenDecimals"]
            tokenAccuracy <- map["tokenAccuracy"]
            publisherDate <- map["publisherDate"]
            reissue <- map["reissue"]
            urlIcon <- map["urlIcon"]
            gateway <- map["gateway"]
            links <- map["links"]
            overview <- map["overview"]
        }

    }
}

