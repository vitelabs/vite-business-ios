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
    var slatedId: String?
    var toSlatedId: String  = ""
    var fromAmount: String?  = nil
    var fromFee: String?  = nil
    var toAmount: String?  = nil
    var toFee: String?  = nil
    var status: Int = 0
    var confirmInfo: GrinGatewayConfirmInfo?
    var pushViteHash: String = ""
    var pollViteHash: String = ""
    var createTime: Int = 0
    var finishTime: Int = 0
    var redoCount: String = ""
    var ctimeFormat: String = ""
    var mtimeFormat: String = ""

    var stepDetailList: [Int: Int] = [0: 1557813789000,
                                      1 :1557813828000,
                                      2: 1557813830000]

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

class GrinFullTxInfo {

    init() {
        
    }


    init(txLogEntry: TxLogEntry?, gatewayInfo: GrinGatewayInfo?, localInfo: GrinLocalInfo?, openedSalte: Slate?,openedSalteUrl: URL?, openedSalteFlieName: String?)
    {
         self.txLogEntry =  txLogEntry
         self.gatewayInfo =  gatewayInfo
         self.localInfo =  localInfo
         self.openedSalte =  openedSalte
         self.openedSalteUrl =  openedSalteUrl
         self.openedSalteFlieName =  openedSalteFlieName
    }


    var txLogEntry: TxLogEntry?
    var gatewayInfo: GrinGatewayInfo?
    var localInfo: GrinLocalInfo?

    var openedSalte: Slate? = nil
    var openedSalteUrl: URL? = nil
    var openedSalteFlieName: String? = nil

    var confirmInfo: GrinHeightInfo?

}

extension GrinFullTxInfo {

    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        return dateFormatter
    }()

    var isGatewayTx: Bool {
         return gatewayInfo != nil
    }
    
    var isHttpTx: Bool {
        return isGatewayTx || localInfo?.method == "Http"
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

    var isSend: Bool {
        return txLogEntry?.txType == .txSent
            || txLogEntry?.txType == .txSentCancelled
            || localInfo?.type == "Send"
    }

    var isReceive: Bool {
        return txLogEntry?.txType == .txReceived
            || txLogEntry?.txType == .txReceivedCancelled
            || gatewayInfo != nil
            || localInfo?.type == "Receive"
    }

    var isSentCancelled: Bool {
        return txLogEntry?.txType == .txSentCancelled
    }

    var isReceivedCancelled: Bool {
        return txLogEntry?.txType == .txReceivedCancelled
    }

    var isCancelled: Bool {
        return isSentCancelled || isReceivedCancelled
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
