//
//  DeFiLoanUsageOption.swift
//  ViteBusiness
//
//  Created by Stone on 2019/12/23.
//

import Foundation
import ObjectMapper
import BigInt
import ViteWallet

struct DeFiLoanUsageOption: Mappable {

    fileprivate(set) var optionCode: String = ""
    fileprivate var optionCnName: String = ""
    fileprivate var optionEnName: String = ""
    fileprivate var unusableCnReason: String = ""
    fileprivate var unusableEnReason: String = ""
    fileprivate(set) var usable: Bool = true


    public init?(map: Map) {}

    public mutating func mapping(map: Map) {
        optionCode <- map["optionCode"]
        optionCnName <- map["optionCnName"]
        optionEnName <- map["optionEnName"]
        unusableCnReason <- map["unusableCnReason"]
        unusableEnReason <- map["unusableEnReason"]
        usable <- map["usable"]
    }

    var name: String {
        return LocalizationService.sharedInstance.currentLanguage == .chinese ? optionCnName : optionEnName
    }

    var unusableReason: String {
        return LocalizationService.sharedInstance.currentLanguage == .chinese ? unusableCnReason : unusableEnReason
    }
}
