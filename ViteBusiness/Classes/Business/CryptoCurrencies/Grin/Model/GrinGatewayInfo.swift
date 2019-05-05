//
//  File.swift
//  Pods
//
//  Created by haoshenyang on 2019/4/28.
//

import Foundation
import ObjectMapper
import Vite_GrinWallet

struct GrinGatewayInfo: Mappable {

    var address: String = ""
    var slatedId: String  = ""
    var toSlatedId: String  = ""
    var fromAmount: UInt64 = 0
    var fromFee: UInt64 = 0
    var toAmount: UInt64 = 0
    var toFee: UInt64 = 0
    var status: Int = 0
    var confirmInfo: GrinGatewayConfirmInfo?
    var pushViteHash: String = ""
    var pollViteHash: String = ""
    var createTime: Int = 0
    var finishTime: Int = 0
    var redoCount: String = ""
    var ctimeFormat: String = ""
    var mtimeFormat: String = ""

    public init?(map: Map) { }

    public mutating func mapping(map: Map) {
        address <- map["address"]
        slatedId <- map["slatedId"]
        toSlatedId <- map["toSlatedId"]
        fromAmount <- map["fromAmount"]
        toAmount <- map["toAmount"]
        confirmInfo <- map["confirmInfo"]
        pushViteHash <- map["pushViteHash"]
        pollViteHash <- map["pollViteHash"]
        createTime <- map["createTime"]
        finishTime <- map["finishTime"]
        redoCount <- map["redoCount"]
        ctimeFormat <- map["ctimeFormat"]
        mtimeFormat <- map["mtimeFormat"]
    }
}

struct GrinGatewayConfirmInfo: Mappable {
    var confirm: Bool = false
    var message: String = ""
    var confirmType: String = ""
    var curHeight: Int = 0
    var beginHeight: Int = 0

    public init?(map: Map) { }

    public mutating func mapping(map: Map) {
        confirm <- map["confirm"]
        message <- map["message"]
        confirmType <- map["confirmType"]
        curHeight <- map["curHeight"]
        beginHeight <- map["beginHeight"]
    }
}

struct GrinFullTxInfo {
    let txLogEntry: TxLogEntry
    let gatewayInfo: GrinGatewayInfo?
    let localInfo: GrinLocalInfo?
}
