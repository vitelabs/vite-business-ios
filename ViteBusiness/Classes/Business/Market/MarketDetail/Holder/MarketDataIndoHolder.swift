//
//  MarketDataIndoHolder.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/20.
//

import Foundation
import RxSwift
import RxCocoa

class MarketDataIndoHolder: NSObject {
    fileprivate(set) var marketInfo: MarketInfo


    let depthListBehaviorRelay: BehaviorRelay<MarketDepthList?> = BehaviorRelay(value: nil)
    let tradesBehaviorRelay: BehaviorRelay<[MarketTrade]> = BehaviorRelay(value: [])

    var depthSubId: SubId? = nil
    var tradesSubId: SubId? = nil
    var symbol: String { marketInfo.statistic.symbol }
    var depthTopic: String { "market.\(symbol).depth.step6" }
    var tradesTopic: String { "market.\(symbol).trade" }

    var tmpTradeItems: [MarketTrade] = []

    init(marketInfo: MarketInfo) {
        self.marketInfo = marketInfo
        super.init()

        self.fetchDepth()
        self.fetchTrades()

        self.depthSubId = MarketInfoService.shared.marketSocket.sub(topic: depthTopic, ticker: { [weak self] (data) in
            guard let `self` = self else { return }
            guard let depthListProto = try? Protocol.DepthListProto.parseFrom(data: data) else { return }
            plog(level: .debug, log: "receive new DepthListProto for \(self.symbol) ", tag: .market)
            self.depthListBehaviorRelay.accept(MarketDepthList.generate(proto: depthListProto))
        })

        self.tradesSubId = MarketInfoService.shared.marketSocket.sub(topic: tradesTopic, ticker: { [weak self] (data) in
            guard let `self` = self else { return }
            guard let tradeListProto = try? Protocol.TradeListProto.parseFrom(data: data) else { return }
            plog(level: .debug, log: "receive new TradeListProto for \(self.symbol) ", tag: .market)
            let trades = tradeListProto.trade.map { MarketTrade.generate(proto: $0) }

            if let first = self.tradesBehaviorRelay.value.first {
                guard let last = trades.last, last.date > first.date else {
                    return
                }
                var array = self.tradesBehaviorRelay.value
                array = trades + array
                self.tradesBehaviorRelay.accept(array)
            } else {
                if let first = self.tmpTradeItems.first {
                    guard let last = trades.last, last.date > first.date else {
                        return
                    }
                    self.tmpTradeItems = trades + self.tmpTradeItems
                } else {
                    self.tmpTradeItems = trades
                }
            }
        })
    }

    func fetchDepth() {
        UnifyProvider.vitex.getDepth(symbol: symbol).done { [weak self] (depthList) in
            guard let `self` = self else {
                return
            }
            plog(level: .debug, log: "getDepth for \(self.symbol)", tag: .market)
            guard self.depthListBehaviorRelay.value == nil else { return }
            self.depthListBehaviorRelay.accept(depthList)
        }.catch { [weak self] (e) in
            plog(level: .debug, log: e, tag: .market)
            guard let `self` = self else {
                return
            }
            GCD.delay(1) { self.fetchDepth() }
        }
    }

    func fetchTrades() {
        UnifyProvider.vitex.getTrades(symbol: symbol).done { [weak self] (trades) in
            guard let `self` = self else {
                return
            }
            plog(level: .debug, log: "getTrades for \(self.symbol)", tag: .market)

            if self.tmpTradeItems.isEmpty {
                self.tradesBehaviorRelay.accept(trades)
            } else {
                var array: [MarketTrade] = trades
                for new in self.tmpTradeItems.reversed() {
                    if let first = array.first, first.date >= new.date {
                        continue
                    }
                    array.insert(new, at: 0)
                }
                self.tradesBehaviorRelay.accept(array)
                self.tmpTradeItems = []
            }
        }.catch { [weak self](e) in
            guard let `self` = self else {
                return
            }
            plog(level: .debug, log: e, tag: .market)
            GCD.delay(1) { self.fetchTrades() }
        }
    }

    deinit {
        unsub()
    }


    func unsub() {
        if let old = self.depthSubId {
            MarketInfoService.shared.marketSocket.unsub(subId: old)
        }

        if let old = self.tradesSubId {
            MarketInfoService.shared.marketSocket.unsub(subId: old)
        }
    }

}
