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
import web3swift
import Vite_GrinWallet
import PromiseKit
import Result
import Vite_HDWalletKit


class GrinTxByViteService {

    fileprivate let transactionProvider = MoyaProvider<GrinTransaction>(stubClosure: MoyaProvider.neverStub)

    func getGateWay() -> Promise<String> {
        guard let address = HDWalletManager.instance.accounts.first?.address.description else {
            return Promise(error: grinError("get first address failed"))
        }
        if let gateWay = gateWayMap[address] {
            return Promise { seal in seal.fulfill(gateWay) }
        } else {
            return self.reportViteAddress()
        }
    }

    func sendGrin(amount: UInt64, to toAddress: String) -> Promise<Void> {
        return creatSentSlate(amount: amount)
            .map { (slate) -> (Slate, URL) in
                plog(level: .info, log: "grin-0-sentGrin-creatSentSlateSuccess.amount:\(amount),toAddress:\(toAddress)", tag: .grin)
                do {
                    let url = try self.save(slate: slate, isResponse: false)
                    return (slate, url)
                } catch {
                    throw error
                }
            }
            .then { (sentSlate, url) ->  Promise<String> in
                plog(level: .info, log: "grin-1-sentGrin-saveSlateSuccess.amount:\(amount),toAddress:\(toAddress)", tag: .grin)
                return self.encrypteAndUploadSlate(toAddress: toAddress, slate: sentSlate , type: .sent)
            }
            .then { (fname) ->  Promise<Void> in
                plog(level: .info, log: "grin-2-sentGrin-saveSlateSuccess.amount:\(amount),toAddress:\(toAddress)", tag: .grin)
                return self.sentViteTx(toAddress: toAddress, fileName: fname)
        }
    }

    func handle(fileName: String, fromAddress: String)  -> Promise<Void> {
        let isResponse = fileName.contains("response")
        if isResponse {
            return self.handle(receiveFile: fileName, fromAddress: fromAddress)
        } else {
            return self.handle(sentFile: fileName, fromAddress: fromAddress)
        }
    }

    func handle(sentFile fileName: String, fromAddress: String) -> Promise<Void> {
        plog(level: .info, log: "grin-4-handleSentFileStart.fname:\(fileName),fromAddress:\(fromAddress)", tag: .grin)
        let isResponse = false
        return downlodEncryptedSlateData(fileName: fileName)
            .then { (data) -> Promise<Data> in
                plog(level: .info, log: "grin-5-handleSentFile-downlodEncryptedSlateDataSuccess.fname:\(fileName),fromAddress:\(fromAddress)", tag: .grin)
                return self.cryptoAesCTRXOR(peerAddress: fromAddress, data: data)
            }
            .then { (data) -> Promise<(Slate, URL)> in
                plog(level: .info, log: "grin-6-handleSentFile-cryptoAesCTRXORSuccess.fname:\(fileName),fromAddress:\(fromAddress)", tag: .grin)
                return self.transformAndSaveSlateData(data, isResponse: isResponse)
            }
            .then { (sentSlate, url) -> Promise<Slate> in
                plog(level: .info, log: "grin-7-handleSentFile-transformAndSaveSlateDataSuccess.fname:\(fileName),fromAddress:\(fromAddress)", tag: .grin)
                return self.receiveSentSlate(with: url)
            }
            .then { (receivedSlate) -> Promise<String> in
                plog(level: .info, log: "grin-8-handleSentFile-receiveSentSlateSuccess.fname:\(fileName),fromAddress:\(fromAddress)", tag: .grin)
                return self.encrypteAndUploadSlate(toAddress: fromAddress, slate: receivedSlate , type: .response)
            }
            .then { fname -> Promise<Void> in
                plog(level: .info, log: "grin-9-handleSentFile-encrypteAndUploadSlateSuccess.fname:\(fileName),fromAddress:\(fromAddress)", tag: .grin)
                return self.sentViteTx(toAddress: fromAddress, fileName: fname)
        }
    }

    func handle(receiveFile fileName: String, fromAddress: String) -> Promise<Void> {
        plog(level: .info, log: "grin-4-handleReceiveFileStart.fname:\(fileName),fromAddress:\(fromAddress)", tag: .grin)
        let isResponse = true
        var slateId: String!
        return downlodEncryptedSlateData(fileName: fileName)
            .then { (data) -> Promise<Data> in
                plog(level: .info, log: "grin-5-handleReceiveFile-downlodEncryptedSlateDataSuccess.fname:\(fileName),fromAddress:\(fromAddress)", tag: .grin)
                return self.cryptoAesCTRXOR(peerAddress: fromAddress, data: data)
            }
            .then { (data) -> Promise<(Slate, URL)> in
                plog(level: .info, log: "grin-6-handleReceiveFile-cryptoAesCTRXORSuccess.fname:\(fileName),fromAddress:\(fromAddress)", tag: .grin)
                return self.transformAndSaveSlateData(data, isResponse: isResponse)
            }
            .then { (responseSlate, url) ->  Promise<Void> in
                plog(level: .info, log: "grin-7-handleReceiveFile-transformAndSaveSlateDataSuccess.fname:\(fileName),fromAddress:\(fromAddress)", tag: .grin)
                slateId = responseSlate.id
                return self.finalizeResponseSlate(with: url)
            }
            .then { () -> Promise<Void> in
                plog(level: .info, log: "grin-8-handleReceiveFile-finalizeResponseSlateSuccess.fname:\(fileName),fromAddress:\(fromAddress)", tag: .grin)
                return self.reportFinalization(slateId: slateId)
        }
    }

    func reportViteAddress() -> Promise<String> {
        return Promise { seal in
            guard let fromAddress = HDWalletManager.instance.accounts.first?.address.description else {
                seal.reject(grinError("get first address error"))
                return
            }
            guard let sAddress = fromAddress.components(separatedBy: "_").last else {
                seal.reject(grinError("get s address error"))
                return
            }
            guard let signature = HDWalletManager.instance.accounts.first?.sign(hash: sAddress.hex2Bytes).toHexString() else {
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
    fileprivate func encrypteAndUploadSlate(toAddress:String, slate: Slate, type: Int) -> Promise<String> {
        return cryptoAesCTRXOR(peerAddress: toAddress, data: slate.toJSONString()?.data(using: .utf8))
            .then({ (d) -> Promise<String> in
                return self.uploadSlateData(d, slateId: slate.id, toAddress: toAddress, type: type)
            })
    }

    fileprivate func uploadSlateData(_ slateData: Data, slateId: String, toAddress:String, type: Int) -> Promise<String> {
        return Promise {seal in
            guard let fromAddress = HDWalletManager.instance.account?.address.description else {
                seal.reject(grinError("get current address error"))
                return
            }
            guard let sAddress = fromAddress.components(separatedBy: "_").last else {
                seal.reject(grinError("get s address error"))
                return
            }
            guard let s = HDWalletManager.instance.account?.sign(hash: sAddress.hex2Bytes).toHexString() else {
                seal.reject(grinError("get signature error"))
                return
            }
            let encryptedData = slateData.base64EncodedString()
            var fileName = encryptedData.digest(using: .sha256)
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

    fileprivate func downlodEncryptedSlateData(fileName:String) -> Promise<Data> {
        return Promise { seal in
            guard let toAddress = HDWalletManager.instance.account?.address.description else {
                seal.reject(grinError("get current address error"))
                return
            }
            guard let sAddress = toAddress.components(separatedBy: "_").last else {
                seal.reject(grinError("get sAddress error"))
                return
            }
            guard let signature = HDWalletManager.instance.account?.sign(hash: sAddress.hex2Bytes).toHexString() else {
                seal.reject(grinError("get signature error"))
                return
            }
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

    fileprivate func cryptoAesCTRXOR(peerAddress:String, data: Data?) -> Promise< Data> {
        return getPK(address: peerAddress)
            .map { (peerPK)  in
                guard let data = data else {
                    throw grinError("wrong  data")
                }
                guard let sk = HDWalletManager.instance.account?.secretKey,
                    let pk = HDWalletManager.instance.account?.publicKey else {
                        throw grinError("get sk pk failed")
                }
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

     func reportFinalization(slateId: String) ->  Promise<Void> {
        return Promise { seal in
            guard let fromAddress = HDWalletManager.instance.account?.address.description else {
                seal.reject(grinError("get current address failed"))
                return
            }
            guard let sAddress = fromAddress.components(separatedBy: "_").last else {
                seal.reject(grinError("get s address failed"))
                return
            }
            guard let signature = HDWalletManager.instance.account?.sign(hash: sAddress.hex2Bytes).toHexString() else {
                seal.reject(grinError("get signature failed"))
                return
            }
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

    fileprivate func sentViteTx(toAddress: String, fileName: String) -> Promise<Void> {
        guard let payload = fileName.data(using: .utf8) else {
            return Promise(error: grinError("creat payload failed. fileName:\(fileName)"))
        }
        guard let account = HDWalletManager.instance.account else {
            return Promise(error: grinError("get current account failed"))
        }
        let dataHeader = Data(Bytes(arrayLiteral: 0x80, 0x01))
        let data = (dataHeader + payload)
        return sendRawTx(toAddress: toAddress, data: data)
    }

    fileprivate func sendRawTx(toAddress: String, data: Data?) -> Promise<Void> {
        guard let account = HDWalletManager.instance.account else {
            return Promise(error: grinError("get current account failed"))
        }

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
                plog(level: .info, log: "grin-10-sendRawTx-recovertoAddress:\(toAddress),error:\(e),ecode:\(code)", tag: .grin)
                if code == ViteErrorCode.rpcRefrenceSnapshootBlockIllegal ||
                    code == ViteErrorCode.rpcRefrencePrevBlockFailed ||
                    code == ViteErrorCode.rpcRefrenceBlockIsPending ||
                    code.type == .st_con ||
                    code.type == .st_req ||
                    code.type == .st_res {
                    return after(seconds: 5).then({ (Void) -> Promise<Void> in
                        return self.sendRawTx(toAddress: toAddress, data: data)
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

