//
//  GrinTxByViteChain.swift
//  Action
//
//  Created by haoshenyang on 2019/3/21.
//

import Foundation
import ViteWallet
import Ioscrypto
import CryptoSwift
import Moya
import SwiftyJSON
import Web3swift
import Vite_GrinWallet
import PromiseKit
import Result
import Vite_HDWalletKit


var handelSendFileSuccess_createdResponeseFile = [String: String]()

class GrinTxByViteService {

    fileprivate let transactionProvider = MoyaProvider<GrinTransaction>(stubClosure: MoyaProvider.neverStub)

    func getGateWay() -> Promise<String> {
        guard let address = HDWalletManager.instance.account?.address.description else {
            return Promise(error: grinError("get address failed"))
        }
        if let gateWay = gateWayMap[address] {
            return Promise { seal in seal.fulfill(gateWay) }
        } else {
            return self.reportViteAddress()
        }
    }

    func sendGrin(amount: UInt64, to toAddress: String) -> Promise<Void> {
        guard let account = HDWalletManager.instance.account else {
            return Promise(error: grinError("get account failed"))
        }
        return creatSentSlate(amount: amount)
            .map { (slate) -> (Slate, URL) in
                plog(level: .info, log: "grin-0-sentGrin-creatSentSlateSuccess.amount:\(amount),toAddress:\(toAddress),accountAddress:\(account.address.description)", tag: .grin)
                do {
                    let url = try self.save(slate: slate, isResponse: false)
                    return (slate, url)
                } catch {
                    throw error
                }
            }
            .then { (sentSlate, url) ->  Promise<String> in
                plog(level: .info, log: "grin-1-sentGrin-saveSlateSuccess.amount:\(amount),toAddress:\(toAddress),accountAddress:\(account.address.description)", tag: .grin)
                return self.encrypteAndUploadSlate(toAddress: toAddress, slate: sentSlate , type: .sent, account: account)
            }
            .then { (fname) ->  Promise<Void> in
                plog(level: .info, log: "grin-2-sentGrin-saveSlateSuccess.amount:\(amount),toAddress:\(toAddress),accountAddress:\(account.address.description)", tag: .grin)
                return self.sentViteTx(toAddress: toAddress, fileName: fname,account: account)
        }
    }

    func handle(fileName: String, fromAddress: String, account: Wallet.Account)  -> Promise<Void> {
        let isResponse = fileName.contains("response")
        if isResponse {
            return self.handle(receiveFile: fileName, fromAddress: fromAddress, account: account)
        } else {
            return self.handle(sentFile: fileName, fromAddress: fromAddress, account: account )
        }
    }

    func handle(sentFile fileName: String, fromAddress: String, account: Wallet.Account) -> Promise<Void> {
        let isResponse = false
        var path =  GrinManager.default.get_handleSendFileSuccess_createdResponeseFilePath(fileName:fileName)
        if let path = path,
            let data =  FileManager.default.contents(atPath: path),
            let string = String.init(data: data, encoding: .utf8),
            let slate = Slate.init(JSONString: string) {
            plog(level: .info, log: "grin-4-handleSentFileStart-fromSavedResponseSlate.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(account.address.description)", tag: .grin)
            return self.encrypteAndUploadSlate(toAddress: fromAddress, slate: slate , type: .response, account:
                    account)
                    .then { fname -> Promise<Void> in
                        plog(level: .info, log: "grin-9-handleSentFile-fromSavedResponseSlate-encrypteAndUploadSlateSuccess.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(account.address.description)", tag: .grin)
                        return self.sentViteTx(toAddress: fromAddress, fileName: fname, account: account)
            }
        }

        plog(level: .info, log: "grin-4-handleSentFileStart.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(account.address.description)", tag: .grin)

        return downlodEncryptedSlateData(fileName: fileName, account: account)
            .then { (data) -> Promise<Data> in
                plog(level: .info, log: "grin-5-handleSentFile-downlodEncryptedSlateDataSuccess.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(account.address.description)", tag: .grin)
                return self.cryptoAesCTRXOR(peerAddress: fromAddress, data: data, account: account)
            }
            .then { (data) -> Promise<(Slate, URL)> in
                plog(level: .info, log: "grin-6-handleSentFile-cryptoAesCTRXORSuccess.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(account.address.description)", tag: .grin)
                return self.transformAndSaveSlateData(data, isResponse: isResponse)
            }
            .then { (sentSlate, url) -> Promise<Slate> in
                plog(level: .info, log: "grin-7-handleSentFile-transformAndSaveSlateDataSuccess.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(account.address.description)", tag: .grin)
                return self.receiveSentSlate(with: url)
            }
            .then { (responseSlate) -> Promise<String> in
                do {
                    let url = try self.save(slate: responseSlate, isResponse: true)
                    GrinManager.default.set_handleSendFileSuccess_createdResponeseFile(fileName: fileName, slateId: responseSlate.id)
                    plog(level: .info, log: "grin-8-handleSentFile-createdResponeseFileSuccess.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(account.address.description),url:\(responseSlate.id)", tag: .grin)

                } catch {
                    plog(level: .info, log: "grin-8-handleSentFile-createdResponeseFileFailed.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(account.address.description)", tag: .grin)
                }

                plog(level: .info, log: "grin-8-handleSentFile-receiveSentSlateSuccess.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(account.address.description)", tag: .grin)
                return self.encrypteAndUploadSlate(toAddress: fromAddress, slate: responseSlate , type: .response, account:
                 account)
            }
            .then { fname -> Promise<Void> in
                plog(level: .info, log: "grin-9-handleSentFile-encrypteAndUploadSlateSuccess.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(account.address.description)", tag: .grin)
                return self.sentViteTx(toAddress: fromAddress, fileName: fname, account: account)
        }
    }

    func handle(receiveFile fileName: String, fromAddress: String, account: Wallet.Account) -> Promise<Void> {
        plog(level: .info, log: "grin-4-handleReceiveFileStart.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(account.address.description)", tag: .grin)
        let isResponse = true
        var slateId: String!
        return downlodEncryptedSlateData(fileName: fileName, account: account)
            .then { (data) -> Promise<Data> in
                plog(level: .info, log: "grin-5-handleReceiveFile-downlodEncryptedSlateDataSuccess.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(account.address.description)", tag: .grin)
                return self.cryptoAesCTRXOR(peerAddress: fromAddress, data: data, account: account)
            }
            .then { (data) -> Promise<(Slate, URL)> in
                plog(level: .info, log: "grin-6-handleReceiveFile-cryptoAesCTRXORSuccess.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(account.address.description)", tag: .grin)
                return self.transformAndSaveSlateData(data, isResponse: isResponse)
            }
            .then { (responseSlate, url) ->  Promise<Void> in
                plog(level: .info, log: "grin-7-handleReceiveFile-transformAndSaveSlateDataSuccess.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(account.address.description)", tag: .grin)
                slateId = responseSlate.id
                return self.finalizeResponseSlate(with: url)
            }
            .then { () -> Promise<Void> in
                plog(level: .info, log: "grin-8-handleReceiveFile-finalizeResponseSlateSuccess.fname:\(fileName),fromAddress:\(fromAddress),accountAddress:\(account.address.description)", tag: .grin)
                return self.reportFinalization(slateId: slateId,account: account)
        }
    }

    func reportViteAddress() -> Promise<String> {
        return Promise { seal in
            let account = HDWalletManager.instance.account
            guard let fromAddress = account?.address.description else {
                seal.reject(grinError("get address error"))
                return
            }
            guard let sAddress = fromAddress.components(separatedBy: "_").last else {
                seal.reject(grinError("get s address error"))
                return
            }
            guard let signature = account?.sign(hash: sAddress.hex2Bytes).toHexString() else {
                    seal.reject(grinError("get signature error"))
                    return
            }

            self.transactionProvider
                .request(.reportViteAddress(address: fromAddress, signature: signature), completion: { (result) in
                    do {
                        let response = try result.dematerialize()
                        if JSON(response.data)["code"].int == 0,
                            let value = JSON(response.data)["data"].string {
                            gateWayMap[fromAddress] = value
                            seal.fulfill((value))
                        } else {
                            seal.reject(grinError(JSON(response.data)["message"].string ?? "reportViteAddress failed"))
                        }
                    } catch {
                        seal.reject(error)
                    }
                })
        }
    }
}

extension GrinTxByViteService {
    fileprivate func encrypteAndUploadSlate(toAddress:String, slate: Slate, type: Int, account: Wallet.Account) -> Promise<String> {
        return cryptoAesCTRXOR(peerAddress: toAddress, data: slate.toJSONString()?.data(using: .utf8), account: account)
            .then({ (d) -> Promise<String> in
                return self.uploadSlateData(d, slateId: slate.id, toAddress: toAddress, type: type, account: account)
            })
    }

    fileprivate func uploadSlateData(_ slateData: Data, slateId: String, toAddress:String, type: Int, account: Wallet.Account) -> Promise<String> {
        return Promise {seal in
            let fromAddress = account.address.description

            guard let sAddress = fromAddress.components(separatedBy: "_").last else {
                seal.reject(grinError("get s address error"))
                return
            }
            let s = account.sign(hash: sAddress.hex2Bytes).toHexString()

            let encryptedData = slateData.base64EncodedString()
            var fileName = encryptedData.sha256()
            if type == .sent {
                fileName = fileName + ".encrypted.grinslate"
            } else if type == .response {
                fileName = fileName + ".encrypted.grinslate.response"
            }
            let txRequest = GrinTransaction.uploadSlate(from: fromAddress, to: toAddress, fname: fileName, data: encryptedData, id: slateId, type: type, s: s)
            self.transactionProvider
                .request(txRequest)
                { (result) in
                    do {
                        let response = try result.dematerialize()
                        if JSON(response.data)["code"].int == 0 {
                            seal.fulfill(fileName)
                        } else {
                            seal.reject(grinError(JSON(response.data)["message"].string ?? "uploadSlate failed"))
                        }
                    } catch {
                        seal.reject(error)
                    }
            }
        }
    }

    fileprivate func downlodEncryptedSlateData(fileName:String, account: Wallet.Account) -> Promise<Data> {
        return Promise { seal in
            let toAddress = account.address.description
            guard let sAddress = toAddress.components(separatedBy: "_").last else {
                seal.reject(grinError("get sAddress error"))
                return
            }
            let signature = account.sign(hash: sAddress.hex2Bytes).toHexString()
            transactionProvider
                .request(.getSlate(to: toAddress, s: signature, fname: fileName))
                { (result) in
                    do {
                        let response = try result.dematerialize()
                        if JSON(response.data)["code"].int == 0,
                            let base64String = JSON(response.data)["data"]["data"].string,
                            let data = Data(base64Encoded: base64String) {
                            seal.fulfill(data)
                        } else {
                            seal.reject(grinError(JSON(response.data)["message"].string ?? "downlodEncryptedSlateData failed"))
                        }
                    } catch {
                        seal.reject(error)
                    }
            }
        }
    }

    fileprivate func getPK(address: String) -> Promise<String> {
        if let pk = pkMap[address] {
            return Promise { $0.fulfill(pk) }
        } else {
            return Provider.default.getTransactions(address: Address(string: address), hash: nil, count: 1)
                .map{ (transactions, nextHash)  in
                    guard let pk = transactions.first?.publicKey else {
                        throw grinError("get peer Key failed")
                    }
                    pkMap[address] = pk
                    return pk
            }
        }
    }

    fileprivate func cryptoAesCTRXOR(peerAddress:String, data: Data?, account: Wallet.Account) -> Promise< Data> {
        return getPK(address: peerAddress)
            .map { (peerPK)  in
                guard let data = data else {
                    throw grinError("wrong  data")
                }
                let sk = account.secretKey
                let pk = account.publicKey
                 guard let xkey = IoscryptoX25519ComputeSecret(IoscryptoEd25519PrivToCurve25519(Data(hex: sk+pk)),IoscryptoEd25519PubToCurve25519(Data(hex: peerPK)),nil),
                    let aes = IoscryptoAesCTRXOR(xkey, data, iv, nil) else {
                        throw grinError("cryptoAesCTRXOR failed")
                }
                return aes
        }
    }

    fileprivate func save(slate: Slate, isResponse: Bool) throws -> URL {
        let slateUrl = GrinManager.default.getSlateUrl(slateId: slate.id, isResponse: isResponse)
        do {
            try slate.toJSONString()?.write(to: slateUrl, atomically: true, encoding: .utf8)
            return slateUrl
        } catch {
            throw error
        }
    }

    fileprivate func creatSentSlate(amount: UInt64) -> Promise<Slate> {
        return Promise { seal in
            grin_async({ () in
                GrinManager.default.txCreate(amount: amount, selectionStrategyIsUseAll: false, message: "Sent")
            }, { (result) in
                do {
                    let slate = try result.dematerialize()
                    seal.fulfill(slate)
                } catch {
                    seal.reject(error)
                }
            })
        }
    }

    fileprivate func receiveSentSlate(with url: URL) -> Promise<Slate> {
        return Promise { seal in
            grin_async({ () in
                GrinManager.default.txReceive(slatePath: url.path, message: "Received")
            }, { (result) in
                do {
                    let slate = try result.dematerialize()
                    seal.fulfill(slate)
                } catch {
                    seal.reject(error)
                }
            })
        }
    }

    fileprivate func finalizeResponseSlate(with url: URL) -> Promise<Void> {
        return Promise { seal in
            grin_async({ () in
                GrinManager.default.txFinalize(slatePath: url.path)
            }, { (result) in
                do {
                    let slate = try result.dematerialize()
                    seal.fulfill(())
                } catch {
                    seal.reject(error)
                }
            })
        }
    }

    fileprivate func transformAndSaveSlateData(_ data: Data, isResponse: Bool) -> Promise<(Slate, URL)> {
        return Promise { seal in
            guard let slateString = String.init(data: data, encoding: .utf8),
                let slate = Slate(JSONString: slateString) else {
                    seal.reject(grinError("transform Slate Failed"))
                    return
            }
            do {
                let url = try self.save(slate: slate, isResponse: isResponse)
                seal.fulfill((slate, url))
            } catch {
                seal.reject(error)
            }
        }
    }

    func reportFinalization(slateId: String,account: Wallet.Account) ->  Promise<Void> {
        return Promise { seal in
            let fromAddress = account.address.description
            guard let sAddress = fromAddress.components(separatedBy: "_").last else {
                seal.reject(grinError("get s address failed"))
                return
            }
            let signature = account.sign(hash: sAddress.hex2Bytes).toHexString()
            self.transactionProvider
                .request(.reportFinalization(from: fromAddress, s: signature, id: slateId), completion: { (result) in
                    do {
                        let response = try result.dematerialize()
                        if JSON(response.data)["code"].int == 0 {
                            seal.fulfill(())
                        } else {
                            seal.reject(grinError(JSON(response.data)["message"].string ?? "reportFinalization failed"))
                        }
                    } catch {
                        seal.reject(error)
                    }
            })
        }
    }

    fileprivate func sentViteTx(toAddress: String, fileName: String, account: Wallet.Account) -> Promise<Void> {
        guard let payload = fileName.data(using: .utf8) else {
            return Promise(error: grinError("creat payload failed. fileName:\(fileName)"))
        }
        let dataHeader = Data(Bytes(arrayLiteral: 0x80, 0x01))
        let data = (dataHeader + payload)
        return sendRawTx(toAddress: toAddress, data: data,account: account )
    }

    fileprivate func sendRawTx(toAddress: String, data: Data?, account: Wallet.Account) -> Promise<Void> {
        let tokenId = ViteWalletConst.viteToken.id
        let amount = Balance()
        
        return Provider.default.sendRawTxWithoutPow(account: account,
                                                    toAddress: Address(string: toAddress),
                                                    tokenId: tokenId,
                                                    amount: amount,
                                                    data: data)
            .map { _ in return Void() }
            .recover({ (e) -> Promise<Void> in
                let code = ViteError.conversion(from: e).code
                plog(level: .info, log: "grin-10-sendRawTx-recovertoAddress:\(toAddress),,accountAddress:\(account.address.description),error:\(e),ecode:\(code)", tag: .grin)
                if code == ViteErrorCode.rpcRefrenceSnapshootBlockIllegal ||
                    code == ViteErrorCode.rpcRefrencePrevBlockFailed ||
                    code == ViteErrorCode.rpcRefrenceBlockIsPending ||
                    code.type == .st_con ||
                    code.type == .st_req ||
                    code.type == .st_res {
                    return after(seconds: 5).then({ (Void) -> Promise<Void> in
                        return self.sendRawTx(toAddress: toAddress, data: data, account: account)
                    })
                } else if code == ViteErrorCode.rpcNotEnoughQuota {
                    return Provider.default.getPowForSendRawTx(account: account,
                                                               toAddress: Address(string: toAddress),
                                                               tokenId: tokenId,
                                                               amount: amount,
                                                               data: data)
                        .then({ (context) -> Promise<Void> in
                            return Provider.default.sendRawTxWithContext(context).map { _ in return Void() }
                        })
                } else {
                    return Promise(error: e)
                }
            })
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

