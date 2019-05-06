//
//  File.swift
//  Pods
//
//  Created by haoshenyang on 2019/4/28.
//

import Foundation
import ObjectMapper
import Vite_GrinWallet

class GrinGatewayInfo: Mappable {

    var address: String = ""
    var slatedId: String  = ""
    var toSlatedId: String  = ""
    var fromAmount: String  = ""
    var fromFee: String  = ""
    var toAmount: String  = ""
    var toFee: String  = ""
    var status: Int = 0
    var confirmInfo: GrinGatewayConfirmInfo?
    var pushViteHash: String = ""
    var pollViteHash: String = ""
    var createTime: Int = 0
    var finishTime: Int = 0
    var redoCount: String = ""
    var ctimeFormat: String = ""
    var mtimeFormat: String = ""

    required public init?(map: Map) { }

    public func mapping(map: Map) {
        address <- map["address"]
        slatedId <- map["slatedId"]
        toSlatedId <-  map["toSlatedId"]
        fromAmount <- map["fromAmount"]
        fromFee <- map["fromAmount"]
        toAmount <- map["toAmount"]
        toFee <- map["toFee"]
        status <- map["status"]
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

class GrinGatewayConfirmInfo: Mappable {
    var confirm: Bool = false
    var message: String = ""
    var confirmType: String = ""
    var curHeight: Int = 0
    var beginHeight: Int = 0

    required public init?(map: Map) { }

    public func mapping(map: Map) {
        confirm <- map["confirm"]
        message <- map["message"]
        confirmType <- map["confirmType"]
        curHeight <- map["curHeight"]
        beginHeight <- map["beginHeight"]
    }
}

struct GrinFullTxInfo {
    var txLogEntry: TxLogEntry?
    var gatewayInfo: GrinGatewayInfo?
    var localInfo: GrinLocalInfo?

}

extension GrinFullTxInfo {

    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        return dateFormatter
    }()
    
    var isHttpTx: Bool {
        return gatewayInfo != nil || localInfo?.method == "Http"
    }

    var isViteTx: Bool {
        return localInfo?.method == "Vite"
    }

    var isFileTx: Bool {
        return localInfo?.method == "File"
    }

    var unkonwMethd: Bool{
        return !(isHttpTx || isFileTx || isViteTx)
    }

    var timeStamp: TimeInterval {
        if let timeString = self.txLogEntry?.creationTs,
            let creationTs = timeString.components(separatedBy: ".").first?.replacingOccurrences(of: "-", with: "/").replacingOccurrences(of: "T", with: " "),
            let date = GrinFullTxInfo.dateFormatter.date(from: creationTs) {
            return date.timeIntervalSince1970
        }
        if let gatewayCreatTime = self.gatewayInfo?.createTime {
            return TimeInterval(gatewayCreatTime/1000)
        }
        return Date().timeIntervalSince1970
    }
}
