//
//  MarketKlineHolder.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/17.
//

import Foundation
import RxSwift
import RxCocoa

class MarketKlineHolder: NSObject {
    fileprivate(set) var marketInfo: MarketInfo
    fileprivate(set) var kineType: MarketKlineType

    let klinesBehaviorRelay: BehaviorRelay<[KlineItem]> = BehaviorRelay(value: [])

    var symbol: String { marketInfo.statistic.symbol }
    var klineSubId: SubId? = nil
    var tmpItems: [KlineItem] = []

    init(marketInfo: MarketInfo, kineType: MarketKlineType) {
        self.marketInfo = marketInfo
        self.kineType = kineType
        super.init()

        self.fetchKlines()

        self.klineSubId = MarketInfoService.shared.marketSocket.sub(topic: kineType.topic(symbol: symbol), ticker: { [weak self] (data) in
            guard let `self` = self else { return }
            guard let klineProto = try? KlineProto(serializedData: data) else { return }
            plog(level: .debug, log: "receive new kline for \(self.symbol) \(self.kineType.requestParameter) \(Date.init(timeIntervalSince1970: TimeInterval(klineProto.t)).format())", tag: .market)
            let item = KlineItem(klineProto: klineProto)
            if let last = self.klinesBehaviorRelay.value.last {
                guard klineProto.t >= last.t else { return }
                var array = self.klinesBehaviorRelay.value

                if klineProto.t == last.t {
                    array.removeLast()
                }

                array.append(item)
                self.klinesBehaviorRelay.accept(array)
            } else {
                if let last = self.tmpItems.last {
                    guard klineProto.t > last.t else { return }
                }
                self.tmpItems.append(item)
            }
        })
    }

    func fetchKlines() {
        UnifyProvider.vitex.getKlines(symbol: symbol, type: kineType).done { [weak self] (items) in
            guard let `self` = self else {
                return
            }
            plog(level: .debug, log: "get \(items.count) klines for \(self.symbol) \(self.kineType.requestParameter)", tag: .market)
            if self.tmpItems.isEmpty {
                self.klinesBehaviorRelay.accept(items)
            } else {
                guard let last = items.last else { return }
                var array = items
                self.tmpItems.forEach { (item) in
                    if item.t > last.t {
                        array.append(item)
                    }
                }
                self.klinesBehaviorRelay.accept(array)
            }
        }.catch { [weak self] (e) in
            plog(level: .debug, log: e, tag: .market)
            guard let `self` = self else {
                return
            }
            GCD.delay(1) { self.fetchKlines() }
        }
    }

    deinit {
        unsub()
    }
    
    func unsub() {
        if let old = self.klineSubId {
            MarketInfoService.shared.marketSocket.unsub(subId: old)
        }
    }

}
