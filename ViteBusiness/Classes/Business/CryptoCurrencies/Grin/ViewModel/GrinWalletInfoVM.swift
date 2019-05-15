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

            let addresses = HDWalletManager.instance.accounts.map { (account) -> [String : String] in
                let addressString = account.address.description
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
                .request(.gatewayTransactionList(addresses: addresses, slateID: nil), completion: { (result) in
                    do {
                        let response = try result.dematerialize()
                        if JSON(response.data)["code"].int == 0,
                            let arr = JSON(response.data)["data"].arrayObject,
                            let gatewayInfos = Mapper<GrinGatewayInfo>().mapArray(JSONObject: arr) {
                            let filtered = gatewayInfos.filter({ (info) -> Bool in
                                info.toFee != nil && info.toAmount != nil && info.toSlatedId != nil
                            })
                            seal.fulfill(filtered)
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
        var localInfoWithGrinTx = [GrinLocalInfo]()

        for localInfo in localInfos {
            let contain = grinTxs.contains(where: { (tx) -> Bool in
                let matchSlateId = (tx.txSlateId != nil && tx.txSlateId == localInfo.slateId)
                let matchSend = ((tx.txType == .txSent || tx.txType == .txSentCancelled) && localInfo.type == "Send")
                let matchReceive = ((tx.txType == .txReceived || tx.txType == .txReceivedCancelled) && localInfo.type == "Receive")
                return matchSlateId && (matchSend || matchReceive)
            })

            if contain {
                localInfoWithGrinTx.append(localInfo)
            } else {
                guard let slateId = localInfo.slateId,
                    let type = localInfo.type else { continue }
                if FileManager.default.fileExists(atPath: GrinManager.default.getSlateUrl(slateId: slateId, isResponse: false).path) || FileManager.default.fileExists(atPath: GrinManager.default.getSlateUrl(slateId: slateId, isResponse: true).path) {
                    let fullInfo = GrinFullTxInfo.init(txLogEntry: nil, gatewayInfo: nil, localInfo: localInfo, openedSalte: nil,openedSalteUrl: nil, openedSalteFlieName: nil)
                    fullTxInfos.append(fullInfo)
                }
            }
        }

        for tx in grinTxs {
            var matchedLocalInfo: GrinLocalInfo?
            localInfoWithGrinTxLoop: for localInfo in localInfoWithGrinTx  {
                let matchSlateId = (tx.txSlateId != nil && tx.txSlateId == localInfo.slateId)
                let matchSend = ((tx.txType == .txSent || tx.txType == .txSentCancelled) && localInfo.type == "Send")
                let matchReceive = ((tx.txType == .txReceived || tx.txType == .txReceivedCancelled) && localInfo.type == "Receive")
                if matchSlateId && (matchSend || matchReceive) {
                    matchedLocalInfo = localInfo
                    break localInfoWithGrinTxLoop
                }
            }
            if let matchedLocalInfo = matchedLocalInfo {
                let fullInfo = GrinFullTxInfo.init(txLogEntry: tx, gatewayInfo: nil, localInfo: matchedLocalInfo, openedSalte: nil,openedSalteUrl: nil, openedSalteFlieName: nil)
                fullTxInfos.append(fullInfo)
            } else {
                let fullInfo = GrinFullTxInfo.init(txLogEntry: tx, gatewayInfo: nil, localInfo: nil, openedSalte: nil, openedSalteUrl: nil,openedSalteFlieName: nil)
                fullTxInfos.append(fullInfo)
            }
        }

        let mirror = fullTxInfos
        for (index, fullInfo) in mirror.enumerated() {
            guard (fullInfo.txLogEntry?.txType == .txReceived || fullInfo.txLogEntry?.txType == .txReceivedCancelled || fullInfo.localInfo?.type == "Receive") else {
                continue
            }
            for gateWayInfo in gateWayInfos {
                if  (gateWayInfo.toSlatedId == fullInfo.txLogEntry?.txSlateId || gateWayInfo.toSlatedId == fullInfo.localInfo?.slateId) {
                    fullTxInfos[index].gatewayInfo = gateWayInfo
                } else {
                    let fullInfo = GrinFullTxInfo.init(txLogEntry: nil, gatewayInfo: gateWayInfo, localInfo: nil, openedSalte: nil, openedSalteUrl: nil,openedSalteFlieName: nil)
                    fullTxInfos.append(fullInfo)
                }
            }
        }

        let sorted = fullTxInfos.sorted { $0.timeStamp > $1.timeStamp }
        return sorted.filter({ (fullinfo) -> Bool in
            fullinfo.txLogEntry != nil || fullinfo.gatewayInfo != nil
        })

//        for gateWayInfo in gateWayInfos  {
//            var grinTxInfo: TxLogEntry?
//            var localInfo: GrinLocalInfo?
//
//            for t in grinTxs where (gateWayInfo.toSlatedId == t.txSlateId && (t.txType == .txReceived || t.txType == .txReceivedCancelled)){
//                grinTxInfo = t
//                break
//            }
//            for l in localInfos where (gateWayInfo.toSlatedId == l.slateId && l.type == "Receive") {
//                localInfo = l; break
//            }
//
//            let fullTxInfo = GrinFullTxInfo(txLogEntry: grinTxInfo, gatewayInfo: gateWayInfo, localInfo: localInfo)
//            fullTxInfos.append(fullTxInfo)
//        }
//
//        let grinTxsWithOutGetWay = grinTxs.filter({ (t) -> Bool in
//            return !fullTxInfos.contains(where: { (fullInfo) -> Bool in
//                fullInfo.txLogEntry?.txSlateId == t.txSlateId
//            })
//        })
//
//        for t in grinTxsWithOutGetWay {
//            var localInfo: GrinLocalInfo?
//            for l in localInfos where t.txSlateId == l.slateId {
//                let matchSend = (t.txType == .txSent || t.txType == .txSentCancelled) && l.type?.contains("Send") ?? false
//                let matchReceive = (t.txType == .txReceived || t.txType == .txReceivedCancelled) && l.type?.contains("Receive") ?? false
//                if  matchSend || matchReceive {
//                    localInfo = l
//                }
//            }
//            let fullTxInfo = GrinFullTxInfo(txLogEntry: t, gatewayInfo: nil, localInfo: localInfo)
//            fullTxInfos.append(fullTxInfo)
//        }
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

