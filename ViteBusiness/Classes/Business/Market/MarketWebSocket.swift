//
//  MarketWebSocket.swift
//  Action
//
//  Created by haoshenyang on 2019/10/10.
//

import UIKit
import Starscream

class MarketWebSocket: NSObject {

    struct Topic {
        static let btc = "market.quoteTokenCategory.BTC.tickers"
        static let eth = "market.quoteTokenCategory.ETH.tickers"
        static let vite = "market.quoteTokenCategory.VITE.tickers"
        static let usdt = "market.quoteTokenCategory.USDT.tickers"
    }

    private let socket: WebSocket
    private var timer: Timer!
    private let clientId = "vx_i_\(UUID().uuidString)"
    private let topices = [Topic.btc, Topic.eth, Topic.vite, Topic.usdt]

    var onNewTickerStatistics: ((Protocol.TickerStatisticsProto)->())?

    override init() {
        socket = WebSocket(url: URL.init(string: ViteConst.instance.market.vitexWS)!)
        super.init()
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(ping), userInfo: nil, repeats: true)
        socket.delegate = self
        socket.pongDelegate = self
    }

    func start() {
        socket.connect()
    }

    private func sub() {
        var originalBuilder = Protocol.DexProtocol.Builder()
        originalBuilder
            .setClientId(clientId)
            .setOpType("sub")
            .setTopics(topices.joined(separator: ","))
            .setMessage(Data())
            .setErrorCode(0)
        do {
            let original = try originalBuilder.build()
            let jsonData = try original.data()
            socket.write(data: jsonData)
        } catch  {
            plog(level: .debug, log: "websocketSubError:\(error.localizedDescription)", tag: .market)
        }
    }

    @objc private func ping()  {
        if socket.isConnected {
            var originalBuilder = Protocol.DexProtocol.Builder()
            originalBuilder
                .setClientId(clientId)
                .setOpType("ping")
                .setTopics("")
                .setMessage(Data())
                .setErrorCode(0)
            do {
                let original = try originalBuilder.build()
                let jsonData = try original.data()
                socket.write(data: jsonData)
//                plog(level: .debug, log: "websocketSendPing", tag: .market)
            } catch  {
                plog(level: .debug, log: "websocketPingError:\(error.localizedDescription)", tag: .market)
            }
        } else {
            socket.connect()
        }
    }

    private func handle(_ data: Data) {
        do {
            var dexProtocol = try Protocol.DexProtocol.parseFrom(data: data)
            if dexProtocol.opType == "push" ,
                dexProtocol.clientId == clientId,
                topices.contains(dexProtocol.topics ?? ""),
                let messageData = dexProtocol.message {
                let tickerStatisticsProto = try Protocol.TickerStatisticsProto.parseFrom(data: messageData)
                self.onNewTickerStatistics?(tickerStatisticsProto)
            }
        } catch  {
            print(error.localizedDescription)
        }
    }

    deinit {
        socket.disconnect()
    }
}

extension MarketWebSocket: WebSocketDelegate, WebSocketPongDelegate {

    func websocketDidConnect(socket: WebSocketClient) {
        plog(level: .debug, log: "websocketDidConnect,clientId:\(clientId)", tag: .market)
        GCD.delay(2) {
            self.ping()
            self.sub()
        }
    }

    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        plog(level: .debug, log: "websocketDidDisconnect, clientId:\(clientId),error: \(error?.localizedDescription)", tag: .market)
    }

    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        plog(level: .debug, log: "websocketDidReceiveMessage", tag: .market)
    }

    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        plog(level: .debug, log: "websocketDidReceiveData", tag: .market)
        self.handle(data)
    }

    func websocketDidReceivePong(socket: WebSocketClient, data: Data?) {
        plog(level: .debug, log: "websocketDidReceivePong", tag: .market)
    }

}
