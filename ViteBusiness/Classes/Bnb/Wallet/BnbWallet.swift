//
//  BnbWallet.swift
//  Vite
//
//  Created by Water on 2018/12/20.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import RxSwift
import RxCocoa
import Foundation
import NSObject_Rx
import ObjectMapper
import BinanceChain
import PromiseKit

import BigInt


extension Balance : Mappable {
    public mutating func mapping(map: Map) {
        symbol <- map["symbol"]
        free <- map["free"]
        locked <- map["locked"]
        frozen <- map["frozen"]
    }

    public init?(map: Map) {
        return nil
    }
}

extension BnbWallet: Storageable {
    public func getStorageConfig() -> StorageConfig {
        return StorageConfig(name: "BnbWalletBalance", path: .wallet ,appending: self.appending)
    }
}

//cache
extension BnbWallet {
    private func pri_save(balances: [Balance]) {
        if let data = balances.toJSONString()?.data(using: .utf8) {
            if let error = self.fileHelper.writeData(data, relativePath: type(of: self).saveKey) {
                assert(false, error.localizedDescription)
            }
        }
    }

    private func read() -> BNBBalanceInfoMap {
        var map = BNBBalanceInfoMap()

        if let data = self.fileHelper.contentsAtRelativePath(type(of: self).saveKey),
            let jsonString = String(data: data, encoding: .utf8),
            let balanceInfos = [Balance](JSONString: jsonString) {

            // filter deleted balanceInfo
            for balanceInfo in balanceInfos where MyTokenInfosService.instance.containsTokenInfo(for: balanceInfo.symbol) {
                map[balanceInfo.symbol] = balanceInfo
            }
        }
        return map
    }
}

public typealias BNBBalanceInfoMap = [String: Balance]
public class BnbWallet {
    public static let shared = BnbWallet()

    fileprivate var appending = "noAddress"
    fileprivate var fileHelper: FileHelper! = nil
    fileprivate static let saveKey = "BnbWalletBalance"
    
    let binance = BinanceChain(endpoint: .mainnet)
    var wallet : Wallet? = nil
    var fromAddress : String? = nil
    var fee = 0.000375

    fileprivate let disposeBag = DisposeBag()
    //signal
    public lazy var balanceDriver: Driver<[Balance]> = self.balanceBehaviorRelay.asDriver()
    private var balanceBehaviorRelay: BehaviorRelay<[Balance]> = BehaviorRelay(value: [Balance]())

    public lazy var commonBalanceInfoDriver: Driver<[CommonBalanceInfo]> = self.commonBalanceInfoBehaviorRelay.asDriver()
    private var commonBalanceInfoBehaviorRelay: BehaviorRelay<[CommonBalanceInfo]> = BehaviorRelay(value: [CommonBalanceInfo]())


    private var webSocket: WebSocket?

    public func loginWallet(_ mnemonic:String) {
        self.wallet = Wallet(mnemonic: mnemonic,endpoint: .mainnet)

        // Access keys
        let privateKey = wallet!.privateKey
        let publicKey = wallet!.publicKey
        let account = wallet!.account
        self.fromAddress = wallet!.account
        self.appending = wallet!.account

        self.fileHelper = FileHelper.createForWallet(appending: self.appending)

        //fetch balance
        self.fetchBalance()
        // make socket
        self.setupWebSocket()
    }

    public func logoutWallet() {
        self.wallet = nil
        self.fromAddress = nil
        self.fileHelper = nil
        //disconnect websocket
        self.webSocket?.close()
        self.webSocket = nil
    }

    private func setupWebSocket() {
        guard let address = self.fromAddress else {
            return
        }
        let webSocket = WebSocket(delegate: self,endpoint: .mainnet)
        self.webSocket = webSocket
        webSocket.connect() {
                //Return account updates.
                webSocket.subscribe(accounts: address)
               //Return transfer updates if userAddress is involved (as sender or receiver) in a transfer. Multisend is also covered
                webSocket.subscribe(transfer: address)
//                webSocket.subscribe(blockheight: .all)
        }
    }

    public func fetchBalance() {
        guard let address = self.fromAddress else {
            return
        }
        binance.account(address: address) { (response) in
            self.balanceBehaviorRelay.accept(response.account.balances)
            self.pri_save(balances: response.account.balances)
            self.output("account", response.account, response.error)

            let balances = response.account.balances
            var balanceInfos : [CommonBalanceInfo] = []
            for b in balances {
                let temp = MyTokenInfosService.instance.tokenInfo(forBnbSymbol: b.symbol)

                if temp != nil {
                    let amount = Int64(b.free * 100000000)
                    let bigDecimal = BigDecimal.init("\(amount)")
                    var balanceInfo = CommonBalanceInfo.init(tokenCode: temp!.tokenCode, balance: bigDecimal!.number)
                    balanceInfos.append(balanceInfo)
                }
            }
            self.commonBalanceInfoBehaviorRelay.accept(balanceInfos)
        }
    }

    func balanceInfoDriver(symbol: String) -> Driver<Balance?> {
        return balanceDriver.map({ [weak self] map -> Balance? in
            for model in map where model.symbol == symbol {
                return model
            }
            return nil
        })
    }

    func commonBalanceInfo(for tokenCode: String) -> CommonBalanceInfo {
        let commonBalanceInfos = self.commonBalanceInfoBehaviorRelay.value
        for model in commonBalanceInfos where model.tokenCode == tokenCode {
            return model
        }
        return CommonBalanceInfo(tokenCode:tokenCode, balance: BigInt())
    }
    func commonBalanceInfoDriver(for tokenCode: String) -> Driver<CommonBalanceInfo?> {
        return commonBalanceInfoDriver.map({ [weak self] map -> CommonBalanceInfo? in
            for model in map where model.tokenCode == tokenCode {
                return model
            }
            return nil
        })
    }
    //fetch fee
    public func fetchFee(){
        binance.fees { (response) in
            let dd = response.fees
            for f in dd where f.fixedFeeParams != nil{
                self.fee = Double(f.fixedFeeParams?.fee ?? "37500") as! Double / 100000000.0
            }
        }
    }

    //fetch log
    public func fetchTransactions(limit:Limit,offset:Int,txAsset:String,completion: @escaping (Transactions,Error?) -> Void) {
        guard let address = self.fromAddress else {
            return
        }
        let endTime = NSDate().timeIntervalSince1970 * 1000
        let startTime = endTime - 3600*24*30*3*1000

        binance.transactions(address: address, endTime: endTime,limit: limit,offset: offset,startTime:startTime,txAsset:txAsset) { (response) in
            completion(response.transactions,response.error)
        }
    }

    //send Transaction
    public func sendTransactionPromise(toAddress:String,amount:Double,symbol:String) -> Promise<[Transaction]>{
        return Promise { seal in
            sendTransaction(toAddress: toAddress, amount: amount,symbol: symbol) { result, error in
                seal.resolve(result, error)
            }
        }
    }

    public func sendTransaction(toAddress:String,amount:Double,symbol:String,completion: @escaping ([Transaction]?, Error?) -> Void) {
        guard let wallet = self.wallet else {
            //TODO wallet is optional
            completion(nil, nil)
            return
        }
        wallet.synchronise() { [weak self](error) in
            if let synchroniseError = error {
                completion(nil,error)
                return
            }

            guard let `self` = self else {return}
            let msg = Message.transfer(symbol: symbol, amount: amount, to: toAddress, wallet: wallet)
            self.binance.broadcast(message: msg) { (response) in
                if let error = response.error {
                    completion(nil,error)
                }else{
                    completion(response.broadcast,nil)
                }
            }
        }
    }

    private init() {
        fetchFee()
    }
}

extension BnbWallet : WebSocketDelegate {
    public func webSocket(webSocket: WebSocket, account: Account) {
        self.balanceBehaviorRelay.accept(account.balances)
        self.pri_save(balances: account.balances)
        self.output("websocket.accounts", account)
    }

    public func webSocket(webSocket: WebSocket, transfer: Transfer) {
        self.output("websocket.transfers", transfer)
    }

    public func webSocketDidConnect(webSocket: WebSocket) {
        self.output("websocket.didConnect", "")
    }

    public func webSocketDidDisconnect(webSocket: WebSocket) {
        self.output("websocket.didDisconnect", "")
    }

    public func webSocketDidFail(webSocket: WebSocket, with error: Error) {
        self.output("websocket.didFail", "", error)
    }

    //no use api
    public func webSocket(webSocket: WebSocket, orders: [Order]) {
        self.output("websocket.orders", orders)
    }

    public func webSocket(webSocket: WebSocket, trades: [Trade]) {
        self.output("websocket.trades", trades)
    }

    public func webSocket(webSocket: WebSocket, marketDiff: MarketDepthUpdate) {
        self.output("websocket.marketDiff", marketDiff)
    }

    // 买卖 深度图
    public func webSocket(webSocket: WebSocket, marketDepth: MarketDepthUpdate) {
        self.output("websocket.marketDepth", marketDepth)
    }

    //k line
    public func webSocket(webSocket: WebSocket, candlestick: Candlestick) {
        self.output("websocket.candlestick", candlestick)
    }

    //24 h 涨跌
    public func webSocket(webSocket: WebSocket, ticker: [TickerStatistics]) {
        self.output("websocket.ticker", ticker)
    }

    public func webSocket(webSocket: WebSocket, miniTicker: TickerStatistics) {
        self.output("websocket.miniTicker", miniTicker)
    }

    public func webSocket(webSocket: WebSocket, miniTickers: [TickerStatistics]) {
        self.output("websocket.miniTickers", miniTickers)
    }

    // 块高度
    public func webSocket(webSocket: WebSocket, blockHeight: Int) {
        self.output("websocket.blockHeight", blockHeight)
    }
}

extension BnbWallet {
    // MARK: - Utils
    private func output(_ label: String, _ property: Any, _ error: Error? = nil) {
        plog(level: .debug, log: String(format: "bnb===%@:", label), tag: .bnb)
        if let error = error {
            plog(level: .debug, log:"error: \(error.localizedDescription)\n", tag: .bnb)
            return
        }
        plog(level: .debug, log:property, tag: .bnb)
    }
}

