//
//  MarketWebSocket.swift
//  Action
//
//  Created by haoshenyang on 2019/10/10.
//

import UIKit
import Starscream

typealias MarketTopic = String
typealias SubId = String
typealias TickerBlock = (Data) -> ()

class MarketWebSocket: NSObject {

    struct Topic {
        static let btc = "market.quoteTokenCategory.BTC.tickers"
        static let eth = "market.quoteTokenCategory.ETH.tickers"
        static let vite = "market.quoteTokenCategory.VITE.tickers"
        static let usdt = "market.quoteTokenCategory.USDT.tickers"
    }

    private var socket: WebSocket
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

    func reStart() {
        socket.disconnect()
        socket = WebSocket(url: URL.init(string: ViteConst.instance.market.vitexWS)!)
        socket.delegate = self
        socket.pongDelegate = self
        socket.connect()
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
//            //plog(level: .debug, log: "websocketSubError:\(error.localizedDescription)", tag: .market)
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
//                //plog(level: .debug, log: "websocketSendPing", tag: .market)
            } catch  {
//                //plog(level: .debug, log: "websocketPingError:\(error.localizedDescription)", tag: .market)
            }
        } else {
            socket.connect()
        }
    }

    private func handle(_ data: Data) {
        do {
            let dexProtocol = try Protocol.DexProtocol.parseFrom(data: data)
            let topic = dexProtocol.topics ?? ""
            if dexProtocol.opType == "push", dexProtocol.clientId == clientId, let messageData = dexProtocol.message {
                if topices.contains(topic) {
                    let tickerStatisticsProto = try Protocol.TickerStatisticsProto.parseFrom(data: messageData)
                    self.onNewTickerStatistics?(tickerStatisticsProto)
                } else {
                    guard let array = blockMap[topic] else { return }
                    array.forEach { $0.block(messageData) }
                }
            }
        } catch  {
            print(error.localizedDescription)
        }
    }

    var blockMap: [MarketTopic: [(id: SubId, block: TickerBlock)]] = [:]
    var topicMap: [SubId: MarketTopic] = [:]
}



extension MarketWebSocket {
//    func subMarketPair(pairId: String, ticker: @escaping (Data) -> ()) -> SubId {
//        let topic = "market.\(pairId).tickers"
//        return sub(topic: topic, ticker: ticker)
//    }

    func sub(topic: MarketTopic, ticker: @escaping (Data) -> ()) -> SubId {
        plog(level: .debug, log: "sub \(topic)", tag: .market)
        let subId = UUID().uuidString
        var array = blockMap[topic] ?? []

        // need sub
        if array.isEmpty {
            plog(level: .debug, log: "sub \(topic) from socket", tag: .market)
            do {
                let originalBuilder = Protocol.DexProtocol.Builder()
                    .setClientId(clientId)
                    .setOpType("sub")
                    .setTopics(topic)
                    .setMessage(Data())
                    .setErrorCode(0)
                let original = try originalBuilder.build()
                let jsonData = original.data()
                socket.write(data: jsonData)
            } catch  {
                plog(level: .debug, log: "websocketSubError:\(error.localizedDescription)", tag: .market)
            }
        }
        array.append((subId, ticker))
        blockMap[topic] = array
        topicMap[subId] = topic
        return subId
    }

    func unsub(subId: SubId) {
        guard let topic = topicMap[subId] else { return }
        topicMap[subId] = nil
        plog(level: .debug, log: "unsub \(topic)", tag: .market)
        guard var array = blockMap[topic] else { return }
        for (index, item) in array.enumerated() where item.id == subId {
            array.remove(at: index)
            break
        }
        blockMap[topic] = array.isEmpty ? nil : array

        // need unsub
        if array.isEmpty {
            do {
                plog(level: .debug, log: "unsub \(topic) from socket", tag: .market)
                let originalBuilder = Protocol.DexProtocol.Builder()
                    .setClientId(clientId)
                    .setOpType("un_sub")
                    .setTopics(topic)
                    .setMessage(Data())
                    .setErrorCode(0)
                let original = try originalBuilder.build()
                let jsonData = original.data()
                socket.write(data: jsonData)
            } catch  {
                plog(level: .debug, log: "websocketSubError:\(error.localizedDescription)", tag: .market)
            }
        }
    }
}



extension MarketWebSocket: WebSocketDelegate, WebSocketPongDelegate {

    func websocketDidConnect(socket: WebSocketClient) {
//        //plog(level: .debug, log: "websocketDidConnect,clientId:\(clientId)", tag: .market)
        self.ping()
        self.sub()
    }

    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
//        //plog(level: .debug, log: "websocketDidDisconnect, clientId:\(clientId),error: \(error?.localizedDescription)", tag: .market)
    }

    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
//        //plog(level: .debug, log: "websocketDidReceiveMessage", tag: .market)
    }

    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
//        //plog(level: .debug, log: "websocketDidReceiveData", tag: .market)
        self.handle(data)
    }

    func websocketDidReceivePong(socket: WebSocketClient, data: Data?) {
//        //plog(level: .debug, log: "websocketDidReceivePong", tag: .market)
    }

}
