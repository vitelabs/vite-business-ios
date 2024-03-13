//
//  MarketWebSocket.swift
//  Action
//
//  Created by haoshenyang on 2019/10/10.
//

import UIKit
import Starscream
import PromiseKit
import RxSwift
import RxCocoa

typealias MarketTopic = String
typealias SubId = String
typealias TickerBlock = (Data) -> ()
typealias SucessSubBlock = (SubId) -> ()

class MarketWebSocket: NSObject {
    
    let isConnectedBehaviorRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)

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

    var onNewTickerStatistics: ((TickerStatisticsProto)->())?

    override init() {
        socket = WebSocket(url: URL.init(string: ViteConst.instance.market.vitexWS)!)
        super.init()
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(ping), userInfo: nil, repeats: true)
        socket.delegate = self
        socket.pongDelegate = self
    }

    func reStart() {
        socket.delegate = nil
        socket.pongDelegate = nil
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
        socketWriteSub(topic: topices.joined(separator: ","))
        blockMap.keys.forEach { (topic) in
            socketWriteSub(topic: topic)
        }
    }

    @objc private func ping()  {
        guard socket.isConnected else { return }
        let dexProtocol = DexProtocol.with {
            $0.clientID = clientId
            $0.opType = "ping"
            $0.topics = ""
            $0.message = Data()
            $0.errorCode = 0
        }
        
        do {
            let jsonData = try dexProtocol.serializedData()
            socket.write(data: jsonData)
//            plog(level: .debug, log: "websocketSendPing", tag: .market)
        } catch  {
            plog(level: .debug, log: "websocketPingError:\(error.localizedDescription)", tag: .market)
        }
    }

    private func handle(_ data: Data) {
        do {
            let dexProtocol = try DexProtocol(serializedData: data)
            let topic = dexProtocol.topics
            let messageData = dexProtocol.message
            if dexProtocol.opType == "push", dexProtocol.clientID == clientId {
                if topices.contains(topic) {
                    let tickerStatisticsProto = try TickerStatisticsProto(serializedData: messageData)
                    self.onNewTickerStatistics?(tickerStatisticsProto)
                } else {
                    guard let array = blockMap[topic] else { return }
                    array.forEach { $0.block(messageData) }
                }
            } else if dexProtocol.opType == "sub" {
                guard let array = blockMap[topic] else { return }

                var newArray: [(id: SubId, block: TickerBlock, successSubBlock: SucessSubBlock?)] = []
                array.forEach { (id, tickerBlock, successSubBlock) in
                    if let block = successSubBlock {
                        block(id)
                    }
                    newArray.append((id: id, block: tickerBlock, successSubBlock: nil))
                }
                blockMap[topic] = newArray
            } else {
//                plog(level: .debug, log: "opType: \(dexProtocol.opType)", tag: .market)
            }
        } catch  {
            print(error.localizedDescription)
        }
    }

    var blockMap: [MarketTopic: [(id: SubId, block: TickerBlock, successSubBlock: SucessSubBlock?)]] = [:]
    var topicMap: [SubId: MarketTopic] = [:]
}



extension MarketWebSocket {

    fileprivate func socketWriteSub(topic: String) {
//        plog(level: .debug, log: "sub \(topic) from socket", tag: .market)
        do {
            let dexProtocol = DexProtocol.with {
                $0.clientID = clientId
                $0.opType = "sub"
                $0.topics = topic
                $0.message = Data()
                $0.errorCode = 0
            }

            let jsonData = try dexProtocol.serializedData()
            socket.write(data: jsonData)
        } catch  {
            plog(level: .debug, log: "websocketSubError:\(error.localizedDescription)", tag: .market)
        }
    }

    func sub(topic: MarketTopic, ticker: @escaping TickerBlock, sucessSub: SucessSubBlock? = nil) -> SubId {
//        plog(level: .debug, log: "sub \(topic)", tag: .market)
        let subId = UUID().uuidString
        var array = blockMap[topic] ?? []

        let needSub = array.isEmpty
        
        if needSub {
            array.append((subId, ticker, sucessSub))
            blockMap[topic] = array
            topicMap[subId] = topic
            socketWriteSub(topic: topic)
        } else {
            array.append((subId, ticker, nil))
            blockMap[topic] = array
            topicMap[subId] = topic
            DispatchQueue.main.async {
                sucessSub?(subId)
            }
        }

        return subId
    }

    func unsub(subId: SubId) {
        guard let topic = topicMap[subId] else { return }
        topicMap[subId] = nil
//        plog(level: .debug, log: "unsub \(topic)", tag: .market)
        guard var array = blockMap[topic] else { return }
        for (index, item) in array.enumerated() where item.id == subId {
            array.remove(at: index)
            break
        }
        blockMap[topic] = array.isEmpty ? nil : array

        // need unsub
        if array.isEmpty {
            do {
//                plog(level: .debug, log: "unsub \(topic) from socket", tag: .market)
                let dexProtocol = DexProtocol.with {
                    $0.clientID = clientId
                    $0.opType = "un_sub"
                    $0.topics = topic
                    $0.message = Data()
                    $0.errorCode = 0
                }

                let jsonData = try dexProtocol.serializedData()
                socket.write(data: jsonData)
            } catch  {
                plog(level: .debug, log: "websocketUnSubError:\(error.localizedDescription)", tag: .market)
            }
        }
    }
}



extension MarketWebSocket: WebSocketDelegate, WebSocketPongDelegate {

    func websocketDidConnect(socket: WebSocketClient) {
        self.isConnectedBehaviorRelay.accept(true)
        plog(level: .info, log: "websocketDidConnect,clientId:\(self.clientId)", tag: .market)
        self.ping()
        self.sub()
    }

    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        self.isConnectedBehaviorRelay.accept(false)
        plog(level: .info, log: "websocketDidDisconnect, clientId:\(self.clientId), error: \(String(describing: error?.localizedDescription))", tag: .market)
        GCD.delay(1) {
            self.socket.connect()
        }
    }

    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
//        plog(level: .debug, log: "websocketDidReceiveMessage", tag: .market)
    }

    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
//        plog(level: .debug, log: "websocketDidReceiveData", tag: .market)
        self.handle(data)
    }

    func websocketDidReceivePong(socket: WebSocketClient, data: Data?) {
//        plog(level: .debug, log: "websocketDidReceivePong", tag: .market)
    }

}
