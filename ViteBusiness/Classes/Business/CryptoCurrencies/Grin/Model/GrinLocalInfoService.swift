//
//  GrinTxLocalInfoService.swift
//  Action
//
//  Created by haoshenyang on 2019/4/26.
//

import Foundation

class GrinLocalInfoService {

    static let shared = GrinLocalInfoService()

    var db: FMDatabase!

    func creatDBIfNeeded() {

        let url = GrinManager.getWalletUrl().appendingPathComponent("grin_tx_local_info.db")
        db = FMDatabase.init(url: url)

        guard db.open() else {
            return
        }

        do {
            try  db.executeUpdate("create table if not exists tx_send(slateid text primary key,method text, type text, status interger,creattime integer,sharesendfiletime integer,getresponsefiletime integer,finalizetime integer, canclesendtime integer);", values: nil)
            try  db.executeUpdate("create table if not exists tx_receive(slateid text primary key,method text,type text, status interger,getsendfiletime integer,receivetime integer,shareresponsefiletime integer, canclereceivetime integer);", values: nil)
        } catch {
            print(error)
        }

        getAllInfo()
    }

    func addSendInfo(slateId: String, method: String, creatTime: Int) {
        do {
            try db.executeUpdate("insert into tx_send(slateid, method, creattime) values (?,?,?)", values: [slateId, method, creatTime])
        } catch {

        }

    }

    func addReceiveInfo(slateId: String, method: String, getSendFileTime: Int)  {
        do {
            try db.executeUpdate("insert into tx_receive(slateid, method, getsendfiletime) values (?,?,?)", values: [slateId, method, getSendFileTime])
        } catch {

        }
    }

    func set(shareSendFileTime: Int,with slateId: String )  {
        do {
            try  db.executeUpdate("update tx_send set sharesendfiletime = ? where slateid = ? ", values: [shareSendFileTime,slateId])
        } catch {

        }
    }

    func set(getResponseFileTime: Int,with slateId: String )  {
        do {
            try  db.executeUpdate("update tx_send set getresponsefiletime = ? where slateid = ? ", values: [getResponseFileTime,slateId])
        } catch {

        }
    }

    func set(finalizeTime: Int,with slateId: String )  {
        do {
            try  db.executeUpdate("update tx_send set finalizetime = ? where slateid = ? ", values: [finalizeTime,slateId])
        } catch {

        }
    }

    func set(cancleSendTime: Int,with slateId: String )  {
        do {
            try  db.executeUpdate("update tx_send set canclesendtime = ? where slateid = ? ", values: [cancleSendTime,slateId])
        } catch {

        }
    }


    func set(getSendFileTime: Int,with slateId: String )  {
        do {
            try  db.executeUpdate("update tx_receive set getsendfiletime = ? where slateid = ? ", values: [getSendFileTime,slateId])
        } catch {

        }
    }

    func set(receiveTime: Int,with slateId: String )  {
        do {
            try  db.executeUpdate("update tx_receive set receivetime = ? where slateid = ? ", values: [receiveTime,slateId])
        } catch {

        }

    }

    func set(shareResponseFileTime: Int,with slateId: String )  {
        do {
            try  db.executeUpdate("update tx_receive set shareresponsefiletime = ? where slateid = ? ", values: [shareResponseFileTime,slateId])
        } catch {

        }
    }

    func set(cancleReceiveTime: Int,with slateId: String )  {
        do {
            try  db.executeUpdate("update tx_receive set canclereceivetime = ? where slateid = ? ", values: [cancleReceiveTime,slateId])
        } catch {

        }
    }



    func getAllInfo() -> [GrinLocalInfo] {
        var result = [GrinLocalInfo]()
        do {
            db.beginTransaction()
            let a = try db.executeQuery("select * from tx_send where 1 = 1 ORDER by creattime limit 1000" ,values: nil)
            let b = try db.executeQuery("select * from tx_receive where 1 = 1 ORDER by receivetime limit 1000" ,values: nil)
            db.commit()

            while a.next() {
                var info = GrinLocalInfo()
                info.slateId = a.string(forColumn: "slateid")
                info.method = a.string(forColumn: "method")
                info.type = "Send"

                info.creatTime = Double(a.longLongInt(forColumn: "creattime"))
                info.shareSendFileTime = Double(a.longLongInt(forColumn: "sharesendfiletime"))
                info.getResponseFileTime = Double(a.longLongInt(forColumn: "getresponsefiletime"))
                info.finalizeTime = Double(a.longLongInt(forColumn: "finalizetime"))
                info.cancleSendTime = Double(a.longLongInt(forColumn: "canclesendtime"))
                result.append(info)
            }
            while b.next() {
                var info = GrinLocalInfo()
                info.slateId = b.string(forColumn: "slateid")
                info.method = b.string(forColumn: "method")
                info.type = "Receive"

                info.getSendFileTime = Double(b.longLongInt(forColumn: "getsendfiletime"))
                info.receiveTime = Double(b.longLongInt(forColumn: "receivetime"))
                info.shareResponseFileTime = Double(b.longLongInt(forColumn: "shareresponsefiletime"))
                info.cancleReceiveTime = Double(b.longLongInt(forColumn: "canclereceivetime"))
                result.append(info)
            }
        } catch {

        }
        return result
    }

    func getSendInfo(slateId: String) -> GrinLocalInfo? {
        var result = [GrinLocalInfo]()
        do {
            let a = try db.executeQuery("select * from tx_send where slateid = ?" ,values: [slateId])
            while a.next() {
                var info = GrinLocalInfo()
                info.slateId = a.string(forColumn: "slateid")
                info.method = a.string(forColumn: "method")
                info.type = "Send"

                info.creatTime = Double(a.longLongInt(forColumn: "creattime"))
                info.shareSendFileTime = Double(a.longLongInt(forColumn: "sharesendfiletime"))
                info.getResponseFileTime = Double(a.longLongInt(forColumn: "getresponsefiletime"))
                info.finalizeTime = Double(a.longLongInt(forColumn: "finalizetime"))
                info.cancleSendTime = Double(a.longLongInt(forColumn: "canclesendtime"))
                result.append(info)
            }
        } catch {

        }

        return result.first

    }

    func getReceiveInfo(slateId: String) -> GrinLocalInfo? {
        var result = [GrinLocalInfo]()
        do {
            let a = try db.executeQuery("select * from tx_receive where slateid = ?" ,values: [slateId])
            while a.next() {
                var info = GrinLocalInfo()
                info.slateId = a.string(forColumn: "slateid")
                info.method = a.string(forColumn: "method")
                info.type = "Receive"

                info.getSendFileTime = Double(a.longLongInt(forColumn: "getsendfiletime"))
                info.receiveTime = Double(a.longLongInt(forColumn: "receivetime"))
                info.shareResponseFileTime = Double(a.longLongInt(forColumn: "shareresponsefiletime"))
                info.cancleReceiveTime = Double(a.longLongInt(forColumn: "canclereceivetime"))
                result.append(info)
            }
        } catch {

        }
        return result.first
    }

}

class GrinLocalInfo {
    var slateId: String?
    var method: String?
    var type:  String?

    var creatTime: TimeInterval?
    var shareSendFileTime: TimeInterval?
    var getResponseFileTime: TimeInterval?
    var finalizeTime: TimeInterval?
    var cancleSendTime: TimeInterval?

    var getSendFileTime: TimeInterval?
    var receiveTime: TimeInterval?
    var shareResponseFileTime: TimeInterval?
    var cancleReceiveTime: TimeInterval?
}
