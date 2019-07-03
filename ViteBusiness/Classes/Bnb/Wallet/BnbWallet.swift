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

extension Transactions : Mappable {
    public mutating func mapping(map: Map) {
        total <- map["total"]
        tx <- map["tx"]
    }

    public init?(map: Map) {
        return nil
    }
}

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
    private func pri_save() {
        save(mappable: balanceBehaviorRelay.value)
    }

    private func save(balances: [Balance]) {
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


    fileprivate let disposeBag = DisposeBag()
    //signal
    public lazy var balanceDriver: Driver<[Balance]> = self.balanceBehaviorRelay.asDriver()
    private var balanceBehaviorRelay: BehaviorRelay<[Balance]> = BehaviorRelay(value: [Balance]())
    //signal
    public lazy var transactionsDriver: Driver<Transactions> = self.transactionsBehaviorRelay.asDriver()
    private var transactionsBehaviorRelay: BehaviorRelay<Transactions> = BehaviorRelay(value: Transactions())

    private var webSocket: WebSocket?

    private let addressTwo = "tbnb10a6kkxlf823w9lwr6l9hzw4uyphcw7qzrud5rr"
    private let symbol = "BNB"
    private let hashId = "5CAA5E0C6266B3BB6D66C00282DFA0A6A2F9F5A705E6D9049F619B63E1BE43FF"
    private let orderId = "7F756B1BE93AA2E2FDC3D7CB713ABC206F877802-43"
    private let amount: Double = 200
    private let mnemonic: String = ""

    public func loginWallet(_ mnemonic:String) {
        self.wallet = Wallet(mnemonic: mnemonic,endpoint: .mainnet)

        // Access keys
        let privateKey = wallet!.privateKey
        let publicKey = wallet!.publicKey
        let account = wallet!.account
        self.fromAddress = wallet!.account
        self.appending = wallet!.account


        self.fileHelper = FileHelper.createForWallet(appending: self.appending)

        //
        self.fetchBalance()



        // make socket
        self.setupWebSocket()
    }

    public func logoutWallet() {
        self.wallet = nil
        self.fromAddress = nil
        self.fileHelper = nil
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
                webSocket.subscribe(blockheight: .all)
        }
    }

    public func fetchBalance() {
        guard let address = self.fromAddress else {
            return
        }
        binance.account(address: address) { (response) in
            self.balanceBehaviorRelay.accept(response.account.balances)
            self.pri_save()
            self.output("account", response.account, response.error)
        }
    }

    func balanceInfoDriver(for tokenCode: String) -> Driver<Balance?> {
        return balanceDriver.map({ [weak self] map -> Balance? in
            for model in map where model.symbol == tokenCode {
                return model
            }
            return nil
        })
    }

    public func fetchTransactions() {
        guard let address = self.fromAddress else {
            return
        }
        binance.transactions(address: address) { (response) in
            self.transactionsBehaviorRelay.accept(response.transactions)
            self.output("transactions", response.transactions, response.error)
        }
    }

    public func testFunc() {
        guard let address = self.fromAddress else {
            return
        }

        let group = DispatchGroup()

        group.enter()
        binance.sequence(address: address) { (response) in
            self.output("addresssequence", response.sequence, response.error)
            group.leave()
        }

//        group.enter()
//        binance.tx(hash: hashId) { (response) in
//            self.output("tx", response.tx, response.error)
//            group.leave()
//        }

//        group.enter()
//        binance.tokens(limit: .fiveHundred, offset: 0) { (response) in
//            self.output("tokens", response.tokens, response.error)
//            group.leave()
//        }

//        group.enter()
//        binance.markets(limit: .oneHundred, offset: 0) { (response) in
//            self.output("markets", response.markets, response.error)
//            group.leave()
//        }

        group.enter()
        binance.fees() { (response) in
            self.output("fees", response.fees, response.error)
            group.leave()
        }

//        group.enter()
//        binance.marketDepth(symbol: symbol) { (response) in
//            self.output("marketdepths", response.marketDepth, response.error)
//            group.leave()
//        }

//        group.enter()
//        binance.broadcast(message: Data()) { (response) in
//            self.output("broadcast", "error is expected", response.error)
//            group.leave()
//        }

//        group.enter()
//        binance.klines(symbol: symbol, interval: .fiveMinutes) { (response) in
//            self.output("klines", response.candlesticks, response.error)
//            group.leave()
//        }

//        group.enter()
//        binance.closedOrders(address: address) { (response) in
//            self.output("closedorders", response.orderList, response.error)
//            group.leave()
//        }
//
//        group.enter()
//        binance.openOrders(address: address) { (response) in
//            self.output("openorders", response.orderList, response.error)
//            group.leave()
//        }

//        group.enter()
//        binance.order(id: orderId) { (response) in
//            self.output("order", response.order, response.error)
//            group.leave()
//        }

//        group.enter()
//        binance.ticker(symbol: symbol) { (response) in
//            self.output("ticker", response.ticker, response.error)
//            group.leave()
//        }

//        group.enter()
//        binance.trades() { (response) in
//            self.output("trades", response.trades, response.error)
//            group.leave()
//        }

//        group.enter()
//        binance.transactions(address: address) { (response) in
//            self.output("transactions", response.transactions, response.error)
//            group.leave()
//        }

        group.notify(queue: .main) {
//            completion()
        }

    }


    private init() {

    }

    // MARK: - Utils

    private func output(_ label: String, _ property: Any, _ error: Error? = nil) {
        // Console
        print(String(format: "bnb===%@:", label))
        if let error = error {
            print("error: \(error.localizedDescription)\n")
            return
        }
        print(property)
        print("\n")
    }
}

extension BnbWallet : WebSocketDelegate {
    public func webSocketDidConnect(webSocket: WebSocket) {
        self.output("websocket.didConnect", "")
    }

    public func webSocketDidDisconnect(webSocket: WebSocket) {
        self.output("websocket.didDisconnect", "")
    }

    public func webSocketDidFail(webSocket: WebSocket, with error: Error) {
        self.output("websocket.didFail", "", error)
    }

    public func webSocket(webSocket: WebSocket, orders: [Order]) {
        self.output("websocket.orders", orders)
    }

    public func webSocket(webSocket: WebSocket, account: Account) {
        self.output("websocket.accounts", account)
    }

    public func webSocket(webSocket: WebSocket, transfer: Transfer) {
        self.output("websocket.transfers", transfer)
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

