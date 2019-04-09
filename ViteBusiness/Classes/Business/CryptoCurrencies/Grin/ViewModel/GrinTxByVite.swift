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

    static let instance = GrinTxByViteService()

    fileprivate let transactionProvider = MoyaProvider<GrinTransaction>(stubClosure: MoyaProvider.neverStub)

    func getGateWay() -> Promise<String> {
        guard let address = HDWalletManager.instance.accounts.first?.address.description else {
            fatalError()
        }
        if let gateWay = gateWayMap[address] {
            return Promise { seal in seal.fulfill(gateWay) }
        } else {
            return self.reportViteAddress()
        }
    }

    func sentGrin(amount: UInt64, to toAddress: String) -> Promise<Void> {
        return creatSentSlate(amount: amount)
            .map { (slate) -> (Slate, URL) in
                do {
                    let url = try self.save(slate: slate, isResponse: false)
                    return (slate, url)
                } catch {
                    throw error
                }
            }
            .then { (sentSlate, url) ->  Promise<String> in
                return self.encrypteAndUploadSlate(toAddress: toAddress, slate: sentSlate , type: .sent)
            }
            .then { (fname) ->  Promise<Void> in
                return self.sentViteTx(toAddress: toAddress, fileName: fname)
        }
    }

    func handle(fileName: String, fromAddress: String)  -> Promise<Void> {
        let isResponse = fileName.components(separatedBy: ".").last == "response"
        if isResponse {
            return self.handle(receiveFile: fileName, fromAddress: fromAddress)
        } else {
            return self.handle(sentFile: fileName, fromAddress: fromAddress)
        }
    }

    func handle(sentFile fileName: String, fromAddress: String) -> Promise<Void> {
        let isResponse = fileName.components(separatedBy: ".").last == "response"
        return downlodEncryptedSlateData(fileName: fileName)
            .then { (data) -> Promise<Data> in
                return self.cryptoAesCTRXOR(peerAddress: fromAddress, data: data)
            }
            .then { (data) -> Promise<(Slate, URL)> in
                return self.transformAndSaveSlateData(data, isResponse: isResponse)
            }
            .then { (sentSlate, url) -> Promise<Slate> in
                return self.receiveSentSlate(with: url)
            }
            .then { (receivedSlate) -> Promise<String> in
                return self.encrypteAndUploadSlate(toAddress: fromAddress, slate: receivedSlate , type: .response)
            }
            .then { fname -> Promise<Void> in
                return self.sentViteTx(toAddress: fromAddress, fileName: fname)
        }
    }

    func handle(receiveFile fileName: String, fromAddress: String) -> Promise<Void> {
        let isResponse = fileName.components(separatedBy: ".").last == "response"
        var slateId: String!
        return downlodEncryptedSlateData(fileName: fileName)
            .then { (data) -> Promise<Data> in
                return self.cryptoAesCTRXOR(peerAddress: fromAddress, data: data)
            }
            .then { (data) -> Promise<(Slate, URL)> in
                return self.transformAndSaveSlateData(data, isResponse: isResponse)
            }
            .then { (responseSlate, url) ->  Promise<Void> in
                slateId = responseSlate.id
                return self.finalizeResponseSlate(with: url)
            }
            .then { () -> Promise<Void> in
                return self.reportFinalization(slateId: slateId)
        }
    }

    func reportViteAddress() -> Promise<String> {
        return Promise { seal in
            guard let fromAddress = HDWalletManager.instance.accounts.first?.address.description,
                let sAddress = fromAddress.components(separatedBy: "_").last,
                let signature = HDWalletManager.instance.accounts.first?.sign(hash: sAddress.hex2Bytes).toHexString() else {
                    seal.reject(grinError)
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
                            seal.reject(grinError)
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
            guard let fromAddress = HDWalletManager.instance.account?.address.description,
                let sAddress = fromAddress.components(separatedBy: "_").last,
                let s = HDWalletManager.instance.account?.sign(hash: sAddress.hex2Bytes).toHexString() else {
                    seal.reject(grinError)
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
                            seal.reject(grinError)
                        }
                    } catch {
                        seal.reject(error)
                    }
            }
        }
    }

    fileprivate func downlodEncryptedSlateData(fileName:String) -> Promise<Data> {
        return Promise { seal in
            guard let toAddress = HDWalletManager.instance.account?.address.description,
                let sAddress = toAddress.components(separatedBy: "_").last,
                let signature = HDWalletManager.instance.account?.sign(hash: sAddress.hex2Bytes).toHexString() else {
                    seal.reject(grinError)
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
                            seal.reject(grinError)
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
                        throw grinError
                    }
                    pkMap[address] = pk
                    return pk
            }
        }
    }

    fileprivate func cryptoAesCTRXOR(peerAddress:String, data: Data?) -> Promise< Data> {
        return getPK(address: peerAddress)
            .map { (peerPK)  in
                guard let data = data,
                    let sk = HDWalletManager.instance.account?.secretKey,
                    let pk = HDWalletManager.instance.account?.publicKey,
                    let xkey = IoscryptoX25519ComputeSecret(IoscryptoEd25519PrivToCurve25519(Data(hex: sk+pk)),IoscryptoEd25519PubToCurve25519(Data(hex: peerPK)),nil),
                    let aes = IoscryptoAesCTRXOR(xkey, data, iv, nil) else {
                        throw grinError
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
            guard let currentAddress = HDWalletManager.instance.account?.address,
                let firstAddress = HDWalletManager.instance.accounts.first?.address,
                currentAddress == firstAddress else {
                    seal.reject(grinError)
                    return
            }
            DispatchQueue.global().async {
                let result = GrinManager.default.txCreate(amount: amount, selectionStrategyIsUseAll: false, message: "Sent")
                do {
                    let slate = try result.dematerialize()
                    seal.fulfill(slate)
                } catch {
                    seal.reject(error)
                }
            }
        }
    }

    fileprivate func receiveSentSlate(with url: URL) -> Promise<Slate> {
        return Promise { seal in
            DispatchQueue.main.async {
                let result = GrinManager.default.txReceive(slatePath: url.path, message: "Received")
                do {
                    let slate = try result.dematerialize()
                    seal.fulfill(slate)
                } catch {
                    seal.reject(error)
                }
            }
        }
    }

    fileprivate func finalizeResponseSlate(with url: URL) -> Promise<Void> {
        return Promise { seal in
            DispatchQueue.global().async {
                let result = GrinManager.default.txFinalize(slatePath: url.path)
                do {
                    let slate = try result.dematerialize()
                    seal.fulfill(())
                } catch {
                    seal.reject(error)
                }
            }
        }
    }

    fileprivate func transformAndSaveSlateData(_ data: Data, isResponse: Bool) -> Promise<(Slate, URL)> {
        return Promise { seal in
            guard let slateString = String.init(data: data, encoding: .utf8),
                let slate = Slate(JSONString: slateString) else {
                    seal.reject(grinError)
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
            guard let fromAddress = HDWalletManager.instance.account?.address.description,
                let sAddress = fromAddress.components(separatedBy: "_").last,
                let signature = HDWalletManager.instance.account?.sign(hash: sAddress.hex2Bytes).toHexString() else {
                    seal.reject(grinError)
                    return
            }
            self.transactionProvider
                .request(.reportFinalization(from: fromAddress, s: signature, id: slateId), completion: { (result) in
                    do {
                        let response = try result.dematerialize()
                        if JSON(response.data)["code"].int == 0 {
                            seal.fulfill(())
                        } else {
                            seal.reject(grinError)
                        }
                    } catch {
                        seal.reject(error)
                    }
            })
        }
    }

    fileprivate func sentViteTx(toAddress: String, fileName: String) -> Promise<Void> {
        testFname = fileName
        guard let payload = fileName.data(using: .utf8),
            let account = HDWalletManager.instance.account else {
                return Promise(error: grinError)
        }

        let dataHeader = Data(Bytes(arrayLiteral: 0x80, 0x01))
        let data = (dataHeader + payload)
        return sendRawTx(toAddress: toAddress, data: data)
    }

    fileprivate func sendRawTx(toAddress: String, data: Data?) -> Promise<Void> {

        guard let account = HDWalletManager.instance.account else {
            return Promise(error: grinError)
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

    func test()  {
        reportViteAddress()
            .done { _ in
                print("done")
            }
            .catch { (error) in
                print(error.localizedDescription)
        }

        let address = HDWalletManager.instance.account!.address.description
        sentGrin(amount: 1, to: address)
            .then {
                self.handle(sentFile: testFname, fromAddress: address)
            }
            .then {
                self.handle(receiveFile: testFname, fromAddress: address)
            }
            .done {
                print("done")
            }
            .catch { (error) in
                print(error.localizedDescription)
        }
    }

}

extension Int {
    fileprivate static let sent = -1
    fileprivate static let response = 1
}

private let grinError = NSError(domain: "Grin", code: 1, userInfo: [NSLocalizedDescriptionKey: "grin  error"])
private let iv = "(grin)tx?iv@vite".data(using: .utf8)
private var pkMap = [String: String]()
private var gateWayMap = [String: String]()
private var testFname: String!

