//
//  GrinWalletInfoVM.swift
//  Action
//
//  Created by haoshenyang on 2019/3/8.
//

import UIKit
import RxSwift
import RxCocoa
import Vite_GrinWallet
import ReactorKit
import PromiseKit
import Moya
import SwiftyJSON
import ObjectMapper



final class GrinWalletInfoVM {

    enum Action {
        case getBalance(manually: Bool)
        case getTxs(manually: Bool)
        case checkWallet
        case cancel(TxLogEntry)
        case repost(TxLogEntry)
        case getFullInfoDetail(GrinFullTxInfo)

    }

    var grinManager:GrinManager { return GrinManager.default }
    let action = PublishSubject<GrinWalletInfoVM.Action>()

    
    lazy var txsDriver: Driver<[GrinFullTxInfo]> = self.txs.asDriver()
    lazy var balanceDriver: Driver<GrinBalance> = self.balance.asDriver()
    lazy var messageDriver: Driver<String?> = self.message.asDriver()
    lazy var showLoadingDriver: Driver<Bool> = self.showLoading.asDriver()
    let txs = BehaviorRelay<[GrinFullTxInfo]>(value: [])
    let balance = BehaviorRelay<GrinBalance>(value: GrinBalance())
    let message: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let showLoading: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let txCancelled = PublishSubject<TxLogEntry>()
    let fullInfoDetail = PublishSubject<GrinFullTxInfo>()

    private let bag = DisposeBag()

    fileprivate let transactionProvider = MoyaProvider<GrinTransaction>(stubClosure: MoyaProvider.neverStub)

    init() {
        action.asObservable()
            .subscribe(onNext: { [weak self] (action) in
                switch action {
                case .checkWallet:
                    self?.checkWallet()
                case .getBalance(let manually):
                    self?.getBalance(manually)
                case .getTxs(let manually):
                    self?.getTxs(manually)
                case .cancel(let tx):
                    self?.cancel(tx)
                case .repost(let tx):
                    self?.repost(tx)
                case .getFullInfoDetail(let fullInfo):
                    self?.getFullInfoDetail(fullInfo: fullInfo)
                }
        })
        .disposed(by: bag)

        balance.asObservable()
            .skip(1)
            .distinctUntilChanged { $0.amountCurrentlySpendable == $1.amountCurrentlySpendable }
            .map { _ in  Action.getTxs(manually: false) }
            .bind(to: self.action)
            .disposed(by: bag)

        GrinManager.default.balanceDriver.asObservable()
            .bind(to: self.balance)
            .disposed(by: bag)
    }


    func checkWallet() {
        self.showLoading.accept(true)
        grin_async({ () in
            self.grinManager.walletRestore()
        },  { (result) in
            self.showLoading.accept(false)
            switch result {
            case .success:
                self.action.onNext(.getBalance(manually: true))
            case .failure(let error):
                self.message.accept(error.message)
            }
        })
    }

    func getBalance(_ manually: Bool) {
        grin_async({ () in
            self.grinManager.walletInfo(refreshFromNode: true)
        },  { (result) in
            switch result {
            case .success(let info):
                self.balance.accept(GrinBalance(info))
            case .failure(let error):
                if manually { self.message.accept(error.message) }
            }
        })
    }

    var deleted = false
    func deleteHistoryFile(_ grinTxs: [TxLogEntry])  {
        guard deleted == true else { return }
        deleted = true

        for tx in grinTxs {
            let canDelet = (tx.confirmed == true || tx.txType == .txReceivedCancelled || tx.txType == .txSentCancelled)
            guard canDelet == true ,
                let slateId = tx.txSlateId else {
                    continue
            }

            let receiveFileUrl = GrinManager.default.getSlateUrl(slateId: slateId, isResponse: true)
            let sendFileUrl = GrinManager.default.getSlateUrl(slateId: slateId, isResponse: false)
            for url in [receiveFileUrl, sendFileUrl] {
                if FileManager.default.fileExists(atPath: url.path) {
                    try? FileManager.default.removeItem(at: url)
                }
            }
        }
    }

    func getTxs(_ manually: Bool) {
        let grinTxs = Promise<[TxLogEntry]> { seal in
            grin_async({ () in
                self.grinManager.txsGet(refreshFromNode: true)
            },  { (result) in
                switch result {
                case .success((_, let txs)):
                    self.deleteHistoryFile(txs)
                    seal.fulfill(txs.reversed())
                case .failure(let error):
                    seal.reject(error)
                }
            })
        }

        let gateWayInfos =  Promise<[GrinGatewayInfo]> { seal in

            let addressesAndSignature = HDWalletManager.instance.accounts.map { (account) -> [String : String] in
                let addressString = account.address
                if let sAddress = addressString.components(separatedBy: "_").last {
                    let s = account.sign(hash: sAddress.hex2Bytes).toHexString()
                    return [
                            "address": addressString,
                            "signature": s
                    ]
                }
                return [String:String]()
            }
            
            transactionProvider
                .request(.gatewayTransactionList(addressesAndSignature: addressesAndSignature), completion: { (result) in
                    do {
                        let response = try result.dematerialize()
                        if JSON(response.data)["code"].int == 0,
                            let arr = JSON(response.data)["data"].arrayObject,
                            let gatewayInfos = Mapper<GrinGatewayInfo>().mapArray(JSONObject: arr) {
//                            let filtered = gatewayInfos.filter({ (info) -> Bool in
//                                info.toFee != nil && info.toAmount != nil && info.toSlatedId != nil
//                            })
                            seal.fulfill(gatewayInfos)
                        } else {
                            seal.reject(grinError(JSON(response.data)["message"].string ?? "gatewayTransactionList failed"))
                        }
                    } catch {
                        seal.reject(error)
                    }
                })
        }

        let localInfos =  Promise<[GrinLocalInfo]> { seal in
            let localInfos = GrinLocalInfoService.shared.getAllInfo()
            seal.fulfill(localInfos)
        }

        when(fulfilled: grinTxs, gateWayInfos,localInfos)
            .done { (arg0) in
                let (grinTxs, gateWayInfos, localInfos) = arg0
                var fullTxInfos = self.mergeTxInfos(grinTxs: grinTxs, gateWayInfos: gateWayInfos, localInfos: localInfos)
                self.txs.accept(fullTxInfos)
            }
            .catch { (error) in
                self.message.accept(error.localizedDescription)
        }
    }

    func mergeTxInfos(grinTxs: [TxLogEntry], gateWayInfos: [GrinGatewayInfo], localInfos: [GrinLocalInfo]) -> [GrinFullTxInfo] {
        var fullTxInfos = [GrinFullTxInfo]()

        var sendIndexMap = [String: Int]()
        var receiveIndexMap = [String: Int]()

        for localInfo in localInfos {
            guard let slateId = localInfo.slateId else { continue }
            let fullInfo = GrinFullTxInfo.init(txLogEntry: nil, gatewayInfo: nil, localInfo: localInfo, openedSalte: nil,openedSalteUrl: nil, openedSalteFlieName: nil)
            if localInfo.type == "Send" {
                fullTxInfos.append(fullInfo)
                sendIndexMap[slateId] = fullTxInfos.count - 1
            } else if localInfo.type == "Receive" {
                receiveIndexMap[slateId] = fullTxInfos.count - 1
            }
        }

        for gateWayInfo in gateWayInfos {
            var slateIDKey = ""
            if !gateWayInfo.toSlatedId.isEmpty {
                slateIDKey = gateWayInfo.toSlatedId
            } else if !gateWayInfo.slatedId.isEmpty {
                slateIDKey = gateWayInfo.slatedId
            }
            guard !slateIDKey.isEmpty else { continue }

            if let index = receiveIndexMap[slateIDKey] {
                fullTxInfos[index].gatewayInfo = gateWayInfo
            } else {
                let fullInfo = GrinFullTxInfo.init(txLogEntry: nil, gatewayInfo: gateWayInfo, localInfo: nil, openedSalte: nil,openedSalteUrl: nil, openedSalteFlieName: nil)
                fullTxInfos.append(fullInfo)
                receiveIndexMap[slateIDKey] = fullTxInfos.count - 1
            }
        }

        for tx in grinTxs {
            guard let slateID = tx.txSlateId else { continue }
            if (tx.txType == .txSent || tx.txType == .txSentCancelled) {
                if let index = sendIndexMap[slateID] {
                    fullTxInfos[index].txLogEntry = tx
                } else {
                    let fullInfo = GrinFullTxInfo.init(txLogEntry: tx, gatewayInfo: nil, localInfo: nil, openedSalte: nil,openedSalteUrl: nil, openedSalteFlieName: nil)
                    fullTxInfos.append(fullInfo)
                    sendIndexMap[slateID] = fullTxInfos.count - 1
                }
            } else if (tx.txType == .txReceived || tx.txType == .txReceivedCancelled) {
                if let index = receiveIndexMap[slateID] {
                    fullTxInfos[index].txLogEntry = tx
                } else {
                    let fullInfo = GrinFullTxInfo.init(txLogEntry: tx, gatewayInfo: nil, localInfo: nil, openedSalte: nil,openedSalteUrl: nil, openedSalteFlieName: nil)
                    fullTxInfos.append(fullInfo)
                    receiveIndexMap[slateID] = fullTxInfos.count - 1
                }
            } else {
                let fullInfo = GrinFullTxInfo.init(txLogEntry: tx, gatewayInfo: nil, localInfo: nil, openedSalte: nil,openedSalteUrl: nil, openedSalteFlieName: nil)
                fullTxInfos.append(fullInfo)
            }
        }

        let sorted = fullTxInfos.sorted { $0.timeStamp > $1.timeStamp }
        return sorted
            .filter({ (fullinfo) -> Bool in
                (fullinfo.txLogEntry != nil || fullinfo.gatewayInfo != nil) || fullinfo.localInfo?.type == "Receive"
            })
    }

    func getFullInfoDetail(fullInfo:GrinFullTxInfo) {

        self.showLoading.accept(true)
        let gateWay = self.getGateWayDetail(fullInfo: fullInfo)
        let confirm = self.getConfirmInfo(fullInfo: fullInfo)

        when(fulfilled: gateWay, confirm)
            .done { (arg0) in
                let (gateWayInfo, confirm) = arg0
                fullInfo.gatewayInfo = gateWayInfo
                fullInfo.confirmInfo = confirm
                self.fullInfoDetail.onNext(fullInfo)
            }
            .catch { (error) in
                self.message.accept(error.localizedDescription)
            }
            .finally {
                self.showLoading.accept(false)
        }
    }

    func getGateWayDetail(fullInfo:GrinFullTxInfo) -> Promise<GrinGatewayInfo?> {
        guard let gatewayInfo = fullInfo.gatewayInfo else {
            return Promise { seal in
                seal.fulfill(fullInfo.gatewayInfo)
            }
        }

        let slatedId = gatewayInfo.slatedId
        return Promise { seal in
            self.showLoading.accept(true)
            transactionProvider
                .request(.gatewayTransactionById(slateID: slatedId), completion: { (result) in
                    self.showLoading.accept(false)
                    do {
                        let response = try result.dematerialize()
                        if JSON(response.data)["code"].int == 0,
                            let dict = JSON(response.data)["data"].dictionaryObject,
                            let gatewayInfo = Mapper<GrinGatewayInfo>().map(JSON: dict) {
                            seal.fulfill(gatewayInfo)
                        } else {
                            seal.reject(grinError(JSON(response.data)["message"].string ?? "getGateWayInfo Failed"))
                        }
                    } catch {
                        seal.reject(error)
                    }
                })
        }
    }

    func getConfirmInfo(fullInfo:GrinFullTxInfo) -> Promise<GrinHeightInfo?> {
        if let txLogEntry = fullInfo.txLogEntry {
            return Promise<GrinHeightInfo?> { seal in
                let heightInfo = GrinHeightInfo()
                let outputResult =  GrinManager.default.outputGet(refreshFromNode: true, txId: txLogEntry.id)
                switch outputResult {
                case .success((let refreshed, let outputs)):
                    let h = outputs.sorted(by: { (arg0, arg1) -> Bool in
                        let (outputData0, arr0) = arg0
                        let (outputData1, arr1) = arg1
                        return outputData0.height > outputData1.height
                    })
                    heightInfo.beginHeight = Int(h.first?.0.height ?? 0)
                case .failure(let error):
                    seal.reject(error)
                }

                let walletInfoResult = self.grinManager.walletInfo(refreshFromNode: true)
                switch walletInfoResult {
                case .success(let info):
                    heightInfo.lastConfirmedHeight = info.lastConfirmedHeight
                case .failure(let error):
                    seal.reject(error)
                }
                seal.fulfill(heightInfo)
            }
        } else {
            return Promise<GrinHeightInfo?> { (seal) in
                seal.fulfill(nil)
            }
        }
    }

    func cancel(_ tx: TxLogEntry) {
        grin_async({ () in
            return self.grinManager.txCancel(id: UInt32(tx.id))
        },  { (result) in
            switch result {
            case .success(_):
                GrinLocalInfoService.shared.set(cancleSendTime: Int(Date().timeIntervalSince1970), with: tx.txSlateId ?? "")
                GrinLocalInfoService.shared.set(cancleReceiveTime: Int(Date().timeIntervalSince1970), with: tx.txSlateId ?? "")
                self.action.onNext(.getBalance(manually: false))
                GrinTxByViteService().reportFinalization(slateId: tx.txSlateId ?? "", account:  HDWalletManager.instance.account!)
                    .done { }
                grin_async({
                    return self.grinManager.txGet(refreshFromNode: false, txId: tx.id)
                }, { (result) in
                    switch result {
                    case .success(let tx):
                        self.txCancelled.onNext(tx.txLogEntry)
                    default:
                        break
                    }
                })
            case .failure(let error):
                self.message.accept(error.message)
            }
        })
    }

    func repost(_ tx: TxLogEntry) {
        grin_async({ () in
            self.grinManager.txRepost(txId: UInt32(tx.id))
        },  { (result) in
            switch result {
            case .success(_):
                self.action.onNext(.getBalance(manually: false))
            case .failure(let error):
                self.message.accept(error.message)
            }
        })
    }
}

