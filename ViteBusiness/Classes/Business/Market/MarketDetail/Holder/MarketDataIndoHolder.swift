//
//  MarketDataIndoHolder.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/20.
//

import Foundation
import RxSwift
import RxCocoa
import PromiseKit

class MarketDataIndoHolder: NSObject {
    let marketInfo: MarketInfo


    let depthListBehaviorRelay: BehaviorRelay<(MarketDepthList?, [MarketOrder])> = BehaviorRelay(value: (nil, []))
    let tradesBehaviorRelay: BehaviorRelay<[MarketTrade]> = BehaviorRelay(value: [])
    let marketPairDetailInfoBehaviorRelay: BehaviorRelay<MarketPairDetailInfo?> = BehaviorRelay(value: nil)

    var depthSubId: SubId? = nil
    var tradesSubId: SubId? = nil
    var symbol: String { marketInfo.statistic.symbol }
    var depthTopic: String { "market.\(symbol).depth" }
    var tradesTopic: String { "market.\(symbol).trade" }

    var tmpTradeItems: [MarketTrade] = []

    init(marketInfo: MarketInfo) {
        self.marketInfo = marketInfo
        super.init()

        self.fetchDepth()
        self.fetchPairDetailInfo()
        
        MarketInfoService.shared.marketSocket.isConnectedBehaviorRelay.filter { $0 }.skip(1).bind { [weak self] _ in
            guard let `self` = self else { return }
            self.fetchDepth()
            self.fetchTrades()
        }.disposed(by: rx.disposeBag)

        self.depthSubId = MarketInfoService.shared.marketSocket.sub(topic: depthTopic, ticker: { [weak self] (data) in
            guard let `self` = self else { return }
            guard let depthListProto = try? DepthListProto(serializedData: data) else { return }
            plog(level: .debug, log: "receive new DepthListProto for \(self.symbol) ", tag: .market)
            let orders = self.depthListBehaviorRelay.value.1
            self.depthListBehaviorRelay.accept((MarketDepthList.generate(proto: depthListProto, count: 20), orders))
        })

        self.tradesSubId = MarketInfoService.shared.marketSocket.sub(topic: tradesTopic, ticker: { [weak self] (data) in
            guard let `self` = self else { return }
            guard let tradeListProto = try? TradeListProto(serializedData: data) else { return }
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
        }) { [weak self] _ in
            self?.fetchTrades()
        }
    }


    func fetchUntilSuccess<T>(promise: @escaping () -> Promise<T>, success: @escaping (T) -> Void) {
        promise().done {
            success($0)
        }.catch { [weak self] (e) in
            guard let `self` = self else {
                return
            }
            plog(level: .debug, log: "fetchUntilSuccess error", tag: .market)
            GCD.delay(1) {[weak self] in
                guard let `self` = self else {
                    return
                }
                self.fetchUntilSuccess(promise: promise, success: success)
            }
        }
    }

    func fetchPairDetailInfo() {
        let tradeToken: String = marketInfo.statistic.tradeToken
        let quoteToken: String = marketInfo.statistic!.quoteToken
        fetchUntilSuccess(promise: {
            UnifyProvider.vitex.getPairDetailInfo(tradeTokenId: tradeToken, quoteTokenId: quoteToken)
        }) { [weak self] (info) in
            guard let `self` = self else { return }
            plog(level: .debug, log: "getPairDetailInfo for \(self.symbol)", tag: .market)
            self.marketPairDetailInfoBehaviorRelay.accept(info)
        }
    }

    func fetchDepth() {
        let symbol = self.symbol
        fetchUntilSuccess(promise: {
            UnifyProvider.vitex.getDepth(symbol: symbol, limit: 20)
        }) { [weak self] (depthList) in
            guard let `self` = self else { return }
            plog(level: .debug, log: "getDepth for \(self.symbol)", tag: .market)
            let orders = self.depthListBehaviorRelay.value.1
            self.depthListBehaviorRelay.accept((depthList, orders))
        }

        let address = HDWalletManager.instance.account!.address
        let tradeTokenSymbol = marketInfo.statistic.tradeTokenSymbol
        let quoteTokenSymbol = marketInfo.statistic.quoteTokenSymbol

        fetchUntilSuccess(promise: {
            UnifyProvider.vitex.getOpenedOrderlist(address: address, tradeTokenSymbol: tradeTokenSymbol, quoteTokenSymbol: quoteTokenSymbol, offset: 0, limit: 50)
        }) { [weak self] (orders) in
            guard let `self` = self else { return }
            plog(level: .debug, log: "getOrder for \(self.symbol)", tag: .market)
            let depthList = self.depthListBehaviorRelay.value.0
            self.depthListBehaviorRelay.accept((depthList, orders))
        }
    }

    func fetchTrades() {
        let symbol = self.symbol
        fetchUntilSuccess(promise: {
            UnifyProvider.vitex.getTrades(symbol: symbol)
        }) { [weak self] (trades) in
            guard let `self` = self else { return }
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
