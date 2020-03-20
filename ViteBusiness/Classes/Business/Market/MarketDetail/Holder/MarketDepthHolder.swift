//
//  MarketDepthHolder.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/20.
//

import Foundation
import RxSwift
import RxCocoa

class MarketDepthHolder: NSObject {
    fileprivate(set) var marketInfo: MarketInfo

    let depthListBehaviorRelay: BehaviorRelay<MarketDepthList?> = BehaviorRelay(value: nil)
    var subId: SubId? = nil
    var symbol: String { marketInfo.statistic.symbol }
    var topic: String { "market.\(symbol).depth.step6" }

    init(marketInfo: MarketInfo) {
        self.marketInfo = marketInfo
        super.init()

        UnifyProvider.vitex.getDepth(symbol: symbol).done { (depthList) in
            plog(level: .debug, log: "getDepth for \(self.symbol)", tag: .market)
            guard self.depthListBehaviorRelay.value == nil else { return }
            self.depthListBehaviorRelay.accept(depthList)
        }.catch { (e) in
            plog(level: .debug, log: e, tag: .market)
        }


        self.subId = MarketInfoService.shared.marketSocket.sub(topic: topic, ticker: { [weak self] (data) in
            guard let `self` = self else { return }
            guard let depthListProto = try? Protocol.DepthListProto.parseFrom(data: data) else { return }
            plog(level: .debug, log: "receive new DepthListProto for \(self.symbol) ", tag: .market)
            self.depthListBehaviorRelay.accept(MarketDepthList.generate(proto: depthListProto))
        })
    }

    deinit {
        unsub()
    }


    func unsub() {
        if let old = self.subId {
            MarketInfoService.shared.marketSocket.unsub(subId: old)
        }
    }

}
