//
//  GrinTxLocalInfoService.swift
//  Action
//
//  Created by haoshenyang on 2019/4/26.
//

import Foundation

class GrinLocalInfoService {

    static let share = GrinLocalInfoService()

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

            try  db.executeUpdate("insert into tx_receive(slateid, sharetime, finalizetime) values (?,?,?)", values: ["10eb49d5-a1ca-49ab-aca7-1a643edfa6q1",21,21])

//            try  db.executeUpdate("update tx_send set creattime = ?, sharetime = ? where slateid = ? ", values: [21,21,"10eb49d5-a1ca-49ab-aca7-1a643edfa611"])


            let a = try db.executeQuery("select * from tx_send where 1 = 1" ,values: nil)
            print(a)

            while a.next() {
                print(a.string(forColumn: "slateid"))
            }
        } catch {
            print(error)
        }

        getAllInfo()
    }

    func getAllInfo() {

        db.beginTransaction()

        var result = [Any]()

        do {
            let a = try db.executeQuery("select * from tx_send where 1 = 1 ORDER by creattime limit 1000" ,values: nil)
            let b = try db.executeQuery("select * from tx_receive where 1 = 1 ORDER by receivetime limit 1000" ,values: nil)

            db.commit()

            while a.next() {
                print(a.string(forColumn: "slateid"))
                result.append(a.string(forColumn: "slateid"))
            }
            while b.next() {
                print(b.string(forColumn: "slateid"))
                result.append(b.string(forColumn: "slateid"))
            }
        } catch {

        }


    }


}

class GrinLocalInfo {

}
