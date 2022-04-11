//
//  GrinTxByViteChain.swift
//  Action
//
//  Created by haoshenyang on 2019/3/21.
//

import Foundation
import ViteWallet
//import Ioscrypto
import CryptoSwift
import Moya
import SwiftyJSON
import web3swift
//import Vite_GrinWallet
import PromiseKit
import Result
import Vite_HDWalletKit


var handelSendFileSuccess_createdResponeseFile = [String: String]()

class GrinTxByViteService {

    fileprivate let transactionProvider = MoyaProvider<GrinTransaction>(stubClosure: MoyaProvider.neverStub)

    func getGateWay() -> Promise<String> {
        return Promise(error: grinError("get address failed"))
//        guard let address = HDWalletManager.instance.account?.address else {
//            return Promise(error: grinError("get address failed"))
//        }
//        if let gateWay = gateWayMap[address] {
//            return Promise { seal in seal.fulfill(gateWay) }
//        } else {
//            return self.reportViteAddress()
//        }
    }

    func sendGrin(amount: UInt64, to toAddress: ViteAddress) -> Promise<Void> {
        return Promise(error: grinError("get address failed"))
//        guard let account = HDWalletManager.instance.account else {
//            return Promise(error: grinError("get account failed"))
//        }
//        var slateId: String!
//        return creatSentSlate(amount: amount)
//            .map { (slate, rawData) -> (Slate, URL,Data) in
//                plog(level: .info, log: "grin-0-sentGrin-creatSentSlateSuccess.amount:\(amount),toAddress:\(toAddress),accountAddress:\(account.address)", tag: .grin)
//                do {
//                    GrinLocalInfoService.shared.addSendInfo(slateId: slate.id, method: "Vite", creatTime: Int(Date().timeIntervalSince1970))
//                    slateId = slate.id
//                    let url = try self.save(slateId: slate.id, isResponse: false,rawData: rawData)
//                    return (slate, url, rawData)
//                } catch {
//                    throw error
//                }
//            }
//            .then { (sentSlate, url, rawData) ->  Promise<String> in
//                plog(level: .info, log: "grin-1-sentGrin-saveSlateSuccess.amount:\(amount),toAddress:\(toAddress),accountAddress:\(account.address)", tag: .grin)
//                return self.encrypteAndUploadSlate(toAddress: toAddress, slate: sentSlate , type: .sent, account: account,rawData: rawData)
//            }
//            .then { (fname) ->  Promise<Void> in
//                plog(level: .info, log: "grin-2-sentGrin-saveSlateSuccess.amount:\(amount),toAddress:\(toAddress),accountAddress:\(account.address)", tag: .grin)
//                return self.sentViteTx(toAddress: toAddress, fileName: fname,account: account)
//                    .map {
//                        GrinLocalInfoService.shared.set(shareSendFileTime: Int(Date().timeIntervalSince1970), with: slateId)
//                }
//        }
    }

    func handle(fileName: String, fromAddress: ViteAddress, account: Wallet.Account)  -> Promise<Void> {
        return Promise(error: grinError("get address failed"))
//        let isResponse = fileName.contains("response")
//        if isResponse {
//            return self.handle(receiveFile: fileName, fromAddress: fromAddress, account: account)
//        } else {
//            return self.handle(sentFile: fileName, fromAddress: fromAddress, account: account )
//        }
    }

    func handle(sentFile fileName: String, fromAddress: ViteAddress, account: Wallet.Account) -> Promise<Void> {
        return Promise(error: grinError("get address failed"))
//        let isResponse = false
//        var path =  GrinManager.default.get_handleSendFileSuccess_createdResponeseFilePath(fileName:fileName)
//        if let path = path,
//            let data =  FileManager.default.contents(atPath: path),
//            let string = String.init(data: data, encoding: .utf8),
//            let slate = Slate.init(JSONString: string) {
//            plog(level: .info, log: "grin-4-handleSentFileStart-fromSavedResponseSlate.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(account.address)", tag: .grin)
//            return self.encrypteAndUploadSlate(toAddress: fromAddress, slate: slate , type: .response, account:
//                    account, rawData: data)
//                    .then { fname -> Promise<Void> in
//                        plog(level: .info, log: "grin-9-handleSentFile-fromSavedResponseSlate-encrypteAndUploadSlateSuccess.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(account.address)", tag: .grin)
//                        return self.sentViteTx(toAddress: fromAddress, fileName: fname, account: account).map {
//                            GrinLocalInfoService.shared.set(shareResponseFileTime: Int(Date().timeIntervalSince1970), with: slate.id)
//                        }
//            }
//        }
//
//        var slateId: String!
//        plog(level: .info, log: "grin-4-handleSentFileStart.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(account.address)", tag: .grin)
//
//        return downlodEncryptedSlateData(fileName: fileName, account: account)
//            .then { (data) -> Promise<Data> in
//                plog(level: .info, log: "grin-5-handleSentFile-downlodEncryptedSlateDataSuccess.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(account.address)", tag: .grin)
//                return self.cryptoAesCTRXOR(peerAddress: fromAddress, data: data, account: account)
//            }
//            .then { (data) -> Promise<(Slate, URL, Data)> in
//                plog(level: .info, log: "grin-6-handleSentFile-cryptoAesCTRXORSuccess.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(account.address)", tag: .grin)
//                return self.transformAndSaveSlateData(data, isResponse: isResponse)
//            }
//            .then { (sentSlate, url, rawData) -> Promise<(Slate,Data)> in
//                plog(level: .info, log: "grin-7-handleSentFile-transformAndSaveSlateDataSuccess.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(account.address),slateString:\(String(data: rawData, encoding: .utf8))", tag: .grin)
//                GrinLocalInfoService.shared.addReceiveInfo(slateId: sentSlate.id, method: "Vite", getSendFileTime:  Int(Date().timeIntervalSince1970))
//                return self.receiveSentSlate(with: url)
//            }
//            .then { (responseSlate,rawData) -> Promise<String> in
//                slateId = responseSlate.id
//                GrinLocalInfoService.shared.set(receiveTime: Int(Date().timeIntervalSince1970), with: responseSlate.id)
//                do {
//                    let url = try self.save(slateId: responseSlate.id, isResponse: true,rawData:rawData)
//                    GrinManager.default.set_handleSendFileSuccess_createdResponeseFile(fileName: fileName, slateId: responseSlate.id)
//                    plog(level: .info, log: "grin-8-handleSentFile-createdResponeseFileSuccess.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(account.address),url:\(responseSlate.id) slateString:\(String(data: rawData, encoding: .utf8))", tag: .grin)
//
//                } catch {
//                    plog(level: .info, log: "grin-8-handleSentFile-createdResponeseFileFailed.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(account.address)", tag: .grin)
//                }
//
//                plog(level: .info, log: "grin-8-handleSentFile-receiveSentSlateSuccess.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(account.address)", tag: .grin)
//                return self.encrypteAndUploadSlate(toAddress: fromAddress, slate: responseSlate , type: .response, account: account, rawData: rawData)
//            }
//            .then { fname -> Promise<String> in
//                return after(seconds: 1).map { fname }
//            }
//            .then { fname -> Promise<Void> in
//                plog(level: .info, log: "grin-9-handleSentFile-encrypteAndUploadSlateSuccess.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(account.address)", tag: .grin)
//                return self.sentViteTx(toAddress: fromAddress, fileName: fname, account: account)
//                    .map {
//                        GrinLocalInfoService.shared.set(shareResponseFileTime: Int(Date().timeIntervalSince1970), with: slateId)
//                }
//        }
    }

    func handle(receiveFile fileName: String, fromAddress: ViteAddress, account: Wallet.Account) -> Promise<Void> {
        return Promise(error: grinError("get address failed"))
//        plog(level: .info, log: "grin-4-handleReceiveFileStart.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(account.address)", tag: .grin)
//        let isResponse = true
//        var slateId: String!
//        return downlodEncryptedSlateData(fileName: fileName, account: account)
//            .then { (data) -> Promise<Data> in
//                plog(level: .info, log: "grin-5-handleReceiveFile-downlodEncryptedSlateDataSuccess.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(account.address)", tag: .grin)
//                return self.cryptoAesCTRXOR(peerAddress: fromAddress, data: data, account: account)
//            }
//            .then { (data) -> Promise<(Slate, URL, Data)> in
//                plog(level: .info, log: "grin-6-handleReceiveFile-cryptoAesCTRXORSuccess.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(account.address) ", tag: .grin)
//                return self.transformAndSaveSlateData(data, isResponse: isResponse)
//            }
//            .then { (responseSlate, url, rawData) ->  Promise<Void> in
//                plog(level: .info, log: "grin-7-handleReceiveFile-transformAndSaveSlateDataSuccess.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(account.address) responseSlate:\(String(data: rawData, encoding: .utf8))", tag: .grin)
//                slateId = responseSlate.id
//                GrinLocalInfoService.shared.set(getResponseFileTime: Int(Date().timeIntervalSince1970), with: slateId)
//                return self.finalizeResponseSlate(with: url)
//            }
//            .then { () -> Promise<Void> in
//                plog(level: .info, log: "grin-8-handleReceiveFile-finalizeResponseSlateSuccess.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(account.address)", tag: .grin)
//
//                GrinLocalInfoService.shared.set(finalizeTime: Int(Date().timeIntervalSince1970), with: slateId)
//
//                let receiveFileUrl = GrinManager.default.getSlateUrl(slateId: slateId, isResponse: true)
//                let sendFileUrl = GrinManager.default.getSlateUrl(slateId: slateId, isResponse: false)
//                for url in [receiveFileUrl, sendFileUrl] {
//                    if FileManager.default.fileExists(atPath: url.path) {
//                        try? FileManager.default.removeItem(at: url)
//                    }
//                }
//                return self.reportFinalization(slateId: slateId,account: account)
//        }
    }

    func reportViteAddress() -> Promise<String> {
        return Promise(error: grinError("get address failed"))
//        return Promise { seal in
//            let account = HDWalletManager.instance.account
//            guard let fromAddress = account?.address else {
//                seal.reject(grinError("get address error"))
//                return
//            }
//            guard let sAddress = fromAddress.components(separatedBy: "_").last else {
//                seal.reject(grinError("get s address error"))
//                return
//            }
//            guard let signature = account?.sign(hash: sAddress.hex2Bytes).toHexString() else {
//                    seal.reject(grinError("get signature error"))
//                    return
//            }
//
//            self.transactionProvider
//                .request(.reportViteAddress(address: fromAddress, signature: signature), completion: { (result) in
//                    do {
//                        let response = try result.dematerialize()
//                        if JSON(response.data)["code"].int == 0,
//                            let value = JSON(response.data)["data"].string {
//                            gateWayMap[fromAddress] = value
//                            seal.fulfill((value))
//                        } else {
//                            seal.reject(grinError(JSON(response.data)["message"].string ?? "reportViteAddress failed"))
//                        }
//                    } catch {
//                        seal.reject(error)
//                    }
//                })
//        }
    }
}

extension GrinTxByViteService {
    fileprivate func encrypteAndUploadSlate(toAddress:String, slate: Slate, type: Int, account: Wallet.Account,rawData: Data) -> Promise<String> {
        return Promise(error: grinError("get address failed"))
//        return cryptoAesCTRXOR(peerAddress: toAddress, data: rawData, account: account)
//            .then({ (d) -> Promise<String> in
//                return self.uploadSlateData(d, slateId: slate.id, toAddress: toAddress, type: type, account: account)
//            })
    }

    fileprivate func uploadSlateData(_ slateData: Data, slateId: String, toAddress:String, type: Int, account: Wallet.Account) -> Promise<String> {
        return Promise(error: grinError("get address failed"))
//        return Promise {seal in
//            let fromAddress = account.address
//
//            guard let sAddress = fromAddress.components(separatedBy: "_").last else {
//                seal.reject(grinError("get s address error"))
//                return
//            }
//            let s = account.sign(hash: sAddress.hex2Bytes).toHexString()
//
//            let encryptedData = slateData.base64EncodedString()
//            var fileName = encryptedData.sha256()
//            if type == .sent {
//                fileName = fileName + ".encrypted.grinslate"
//            } else if type == .response {
//                fileName = fileName + ".encrypted.grinslate.response"
//            }
//            let txRequest = GrinTransaction.uploadSlate(from: fromAddress, to: toAddress, fname: fileName, data: encryptedData, id: slateId, type: type, s: s)
//            self.transactionProvider
//                .request(txRequest)
//                { (result) in
//                    do {
//                        let response = try result.dematerialize()
//                        if JSON(response.data)["code"].int == 0 {
//                            seal.fulfill(fileName)
//                        } else {
//                            seal.reject(grinError(JSON(response.data)["message"].string ?? "uploadSlate failed"))
//                        }
//                    } catch {
//                        seal.reject(error)
//                    }
//            }
//        }
    }

    fileprivate func downlodEncryptedSlateData(fileName:String, account: Wallet.Account) -> Promise<Data> {
        return Promise(error: grinError("get address failed"))
//        return Promise { seal in
//            let toAddress = account.address
//            guard let sAddress = toAddress.components(separatedBy: "_").last else {
//                seal.reject(grinError("get sAddress error"))
//                return
//            }
//            let signature = account.sign(hash: sAddress.hex2Bytes).toHexString()
//            transactionProvider
//                .request(.getSlate(to: toAddress, s: signature, fname: fileName))
//                { (result) in
//                    do {
//                        let response = try result.dematerialize()
//                        if JSON(response.data)["code"].int == 0,
//                            let base64String = JSON(response.data)["data"]["data"].string,
//                            let data = Data(base64Encoded: base64String) {
//                            seal.fulfill(data)
//                        } else {
//                            seal.reject(grinError(JSON(response.data)["message"].string ?? "downlodEncryptedSlateData failed"))
//                        }
//                    } catch {
//                        seal.reject(error)
//                    }
//            }
//        }
    }

    fileprivate func getPK(address: ViteAddress) -> Promise<String> {
        return Promise(error: grinError("get address failed"))
//        if let pk = pkMap[address] {
//            return Promise { $0.fulfill(pk) }
//        } else {
//            return ViteNode.ledger.getAccountBlocks(address: address, hash: nil, count: 1)
//                .map{ (accountBlocks, nextHash)  in
//                    guard let pk = accountBlocks.first?.publicKey else {
//                        throw grinError("get peer Key failed")
//                    }
//                    pkMap[address] = pk
//                    return pk
//            }
//        }
    }

    fileprivate func cryptoAesCTRXOR(peerAddress:String, data: Data?, account: Wallet.Account) -> Promise< Data> {
        return Promise(error: grinError("get address failed"))
//        return getPK(address: peerAddress)
//            .map { (peerPK)  in
//                guard let data = data else {
//                    throw grinError("wrong  data")
//                }
//                let sk = account.secretKey
//                let pk = account.publicKey
//                 guard let xkey = IoscryptoX25519ComputeSecret(IoscryptoEd25519PrivToCurve25519(Data(hex: sk+pk)),IoscryptoEd25519PubToCurve25519(Data(hex: peerPK)),nil),
//                    let aes = IoscryptoAesCTRXOR(xkey, data, iv, nil) else {
//                        throw grinError("cryptoAesCTRXOR failed")
//                }
//                return aes
//        }
    }

    fileprivate func save(slateId: String, isResponse: Bool,rawData: Data?) throws -> URL {
        return URL(fileURLWithPath: "")
//        let slateUrl = GrinManager.default.getSlateUrl(slateId: slateId, isResponse: isResponse)
//        do {
//            if let rawData = rawData {
//                try rawData.write(to: slateUrl)
//            }
////            else {
////                try slate.toJSONString()?.write(to: slateUrl, atomically: true, encoding: .utf8)
////            }
//            return slateUrl
//        } catch {
//            throw error
//        }
    }

    fileprivate func creatSentSlate(amount: UInt64) -> Promise<(Slate,Data)> {
        return Promise(error: grinError("get address failed"))
//        return Promise { seal in
//            grin_async({ () in
//                GrinManager.default.txCreate(amount: amount, selectionStrategyIsUseAll: false, message: "Sent")
//            }, { (result) in
//                do {
//                    let slate = try result.dematerialize()
//                    seal.fulfill(slate)
//                } catch {
//                    seal.reject(error)
//                }
//            })
//        }
    }

    fileprivate func receiveSentSlate(with url: URL) -> Promise<(Slate,Data)> {
        return Promise(error: grinError("get address failed"))
//        return Promise { seal in
//            grin_async({ () in
//                GrinManager.default.txReceive(slatePath: url.path, message: "Received")
//            }, { (result) in
//                do {
//                    let slate = try result.dematerialize()
//                    seal.fulfill(slate)
//                } catch {
//                    seal.reject(error)
//                }
//            })
//        }
    }

    fileprivate func finalizeResponseSlate(with url: URL) -> Promise<Void> {
        return Promise(error: grinError("get address failed"))
//        return Promise { seal in
//            grin_async({ () in
//                GrinManager.default.txFinalize(slatePath: url.path)
//            }, { (result) in
//                do {
//                    let slate = try result.dematerialize()
//                    let result = GrinManager.default.txRepost(slateID: slate.id)
//                    switch result {
//                    case .success:
//                        seal.fulfill(())
//                    case .failure(let error):
//                        seal.reject(error)
//                    }
//                } catch {
//                    seal.reject(error)
//                }
//            })
//        }
    }

    fileprivate func transformAndSaveSlateData(_ data: Data, isResponse: Bool) -> Promise<(Slate, URL, Data)> {
        return Promise(error: grinError("get address failed"))
//        return Promise { seal in
//            guard let slateString = String.init(data: data, encoding: .utf8),
//                let slate = Slate(JSONString: slateString) else {
//                    seal.reject(grinError("transform Slate Failed"))
//                    return
//            }
//            do {
//                let url = try self.save(slateId: slate.id, isResponse: isResponse, rawData: data)
//                seal.fulfill((slate, url, data))
//            } catch {
//                seal.reject(error)
//            }
//        }
    }

    func reportFinalization(slateId: String,account: Wallet.Account) ->  Promise<Void> {
        return Promise(error: grinError("get address failed"))
//        return Promise { seal in
//            let fromAddress = account.address
//            guard let sAddress = fromAddress.components(separatedBy: "_").last else {
//                seal.reject(grinError("get s address failed"))
//                return
//            }
//            let signature = account.sign(hash: sAddress.hex2Bytes).toHexString()
//            self.transactionProvider
//                .request(.reportFinalization(from: fromAddress, s: signature, id: slateId), completion: { (result) in
//                    do {
//                        let response = try result.dematerialize()
//                        if JSON(response.data)["code"].int == 0 {
//                            seal.fulfill(())
//                        } else {
//                            seal.reject(grinError(JSON(response.data)["message"].string ?? "reportFinalization failed"))
//                        }
//                    } catch {
//                        seal.reject(error)
//                    }
//            })
//        }
    }

    fileprivate func sentViteTx(toAddress: ViteAddress, fileName: String, account: Wallet.Account) -> Promise<Void> {
        return Promise(error: grinError("get address failed"))
//        guard let payload = fileName.data(using: .utf8) else {
//            return Promise(error: grinError("creat payload failed. fileName:\(fileName)"))
//        }
//        let data = AccountBlockDataFactory.generateCustomData(header: 0x8001, data: payload)
//        return sendRawTx(toAddress: toAddress, data: data,account: account )
    }

    fileprivate func sendRawTx(toAddress: ViteAddress, data: Data?, account: Wallet.Account) -> Promise<Void> {
        return Promise(error: grinError("get address failed"))
//        let tokenId = ViteWalletConst.viteToken.id
//        let amount = Amount()
//        return ViteNode.rawTx.send.withoutPow(account: account,
//                                              toAddress: toAddress,
//                                              tokenId: tokenId,
//                                              amount: amount,
//                                              fee: Amount(0),
//                                              data: data)
//            .map { _ in return Void() }
//            .recover({ (e) -> Promise<Void> in
//                let code = ViteError.conversion(from: e).code
//                plog(level: .info, log: "grin-10-sendRawTx-recovertoAddress:\(toAddress),,accountAddress:\(account.address),error:\(e),ecode:\(code)", tag: .grin)
//                if code == ViteErrorCode.rpcRefrenceSnapshootBlockIllegal ||
//                    code == ViteErrorCode.rpcRefrencePrevBlockFailed ||
//                    code == ViteErrorCode.rpcRefrenceBlockIsPending ||
//                    code.type == .st_con ||
//                    code.type == .st_req ||
//                    code.type == .st_res {
//                    return after(seconds: 5).then({ (Void) -> Promise<Void> in
//                        return self.sendRawTx(toAddress: toAddress, data: data, account: account)
//                    })
//                } else if code == ViteErrorCode.rpcNotEnoughQuota {
//                    return ViteNode.rawTx.send.getPow(account: account,
//                                                      toAddress: toAddress,
//                                                      tokenId: tokenId,
//                                                      amount: amount,
//                                                      fee: Amount(0),
//                                                      data: data)
//                        .then({ (context) -> Promise<Void> in
//                            return ViteNode.rawTx.send.context(context).map { _ in return Void() }
//                        })
//                } else {
//                    return Promise(error: e)
//                }
//            })
    }

}

extension Int {
    fileprivate static let sent = -1
    fileprivate static let response = 1
}

func grinError(_ message: String = "", code: Int = 1, line: Int = #line, function: String = #function ) -> NSError {
    let description = "line:\(line),function:\(function),message:\(message),code:\(code)"
    return  NSError(domain: "Grin", code: code, userInfo: [NSLocalizedDescriptionKey: description])
}

private let iv = "(grin)tx?iv@vite".data(using: .utf8)
private var pkMap = [String: String]()
private var gateWayMap = [String: String]()

