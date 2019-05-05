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


    func getTxs(_ manually: Bool) {

        let grinTxs = Promise<[TxLogEntry]> { seal in
            grin_async({ () in
                self.grinManager.txsGet(refreshFromNode: true)
            },  { (result) in
                switch result {
                case .success((_, let txs)):
                    seal.fulfill(txs.reversed())
//                    self.txs.accept(txs.reversed())
                case .failure(let error):
                    seal.reject(error)
//                    if manually { self.message.accept(error.message) }
                }
            })
        }

        let gateWayInfos =  Promise<[GrinGatewayInfo]> { seal in
            let addresses = HDWalletManager.instance.accounts
                .map({ (account) in
                    account.address.description
                })
            transactionProvider
                .request(.gatewayTransactionList(addresses: addresses), completion: { (result) in
                    do {
                        let response = try result.dematerialize()
                        if JSON(response.data)["code"].int == 0,
                            let arr = JSON(response.data)["data"].arrayObject,
                            let gatewayInfos = Mapper<GrinGatewayInfo>().mapArray(JSONObject: arr) {
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
            seal.fulfill([GrinLocalInfo()])
        }

        when(fulfilled: grinTxs, gateWayInfos,localInfos)
            .done { (arg0) in
                let (grinTxs, gateWayInfos, localInfos) = arg0
                let fullTxInfo = grinTxs.map({ (tx) -> GrinFullTxInfo in
                    var gatewayInfo: GrinGatewayInfo?
                    var localInfo: GrinLocalInfo?

                    if tx.txType == .txReceived || tx.txType == .txReceivedCancelled {
                        for gateWay in gateWayInfos where gateWay.slatedId == tx.txSlateId {
                            gateWay.slatedId == tx.txSlateId
                            break
                        }
                    }

                    for localInfo in localInfos {

                    }
                    return GrinFullTxInfo(txLogEntry: tx, gatewayInfo: gatewayInfo, localInfo: localInfo)
                })

                self.txs.accept(fullTxInfo)
            }
            .catch { (error) in
                self.message.accept(error.localizedDescription)
        }

    }

    func cancel(_ tx: TxLogEntry) {
        grin_async({ () in
            return self.grinManager.txCancel(id: UInt32(tx.id))
        },  { (result) in
            switch result {
            case .success(_):
                self.action.onNext(.getBalance(manually: false))
                GrinTxByViteService().reportFinalization(slateId: tx.txSlateId ?? "", account:  HDWalletManager.instance.account!)
                    .done { }
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

