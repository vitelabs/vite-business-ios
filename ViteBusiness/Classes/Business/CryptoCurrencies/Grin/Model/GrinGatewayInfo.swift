//
//  File.swift
//  Pods
//
//  Created by haoshenyang on 2019/4/28.
//

import Foundation
import ObjectMapper
import Vite_GrinWallet
import SwiftyJSON

class GrinGatewayInfo: NSObject, Mappable {

    var address: String = ""
    var slatedId: String = ""
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

    var stepDetail = [AnyHashable: Any]()

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
        stepDetail <- map["stepDetail"]
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


    func historyReceivedSendSlate() -> Slate? {

        guard self.gatewayInfo == nil && self.txLogEntry == nil else {
            return nil
        }
        guard let localInfo = self.localInfo, let slateId = localInfo.slateId, localInfo.type == "Receive" else {
            return nil
        }
        let url = GrinManager.default.getSlateUrl(slateId: slateId, isResponse: false)

        guard let data = JSON(FileManager.default.contents(atPath: url.path)).rawValue as? [String: Any],
            let slate = Slate(JSON:data) else { return nil }
        return slate
        return nil
    }


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
        if let slateId = self.localInfo?.slateId, let type = self.localInfo?.type {
            if type == "Send" {
                let url = GrinManager.default.getSlateUrl(slateId: slateId, isResponse: false)
            } else if type == "Receive" {
                let url = GrinManager.default.getSlateUrl(slateId: slateId, isResponse: true)
            }
        }
        return Date().timeIntervalSince1970
    }

    var isHistoryReceivedSendSlate: Bool {
        guard self.gatewayInfo == nil && self.txLogEntry == nil else {
            return false
        }
        guard let localInfo = self.localInfo, let slateId = localInfo.slateId, localInfo.type == "Receive" else {
            return false
        }
        return true
    }

    var historyReceivedSendSlateUrl: URL? {
        if isHistoryReceivedSendSlate {
            return GrinManager.default.getSlateUrl(slateId: self.localInfo!.slateId!, isResponse: false)
        } else {
            return nil
        }
    }
}
