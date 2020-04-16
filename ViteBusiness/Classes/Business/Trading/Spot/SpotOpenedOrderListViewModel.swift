//
//  SpotOpenedOrderListViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2020/4/7.
//

import Foundation
import RxSwift
import RxCocoa
import PromiseKit
import ViteWallet

class SpotOpenedOrderListViewModel: ListViewModel<MarketOrder> {
    static let limit = 50
    let address = HDWalletManager.instance.account!.address
    let quoteTokenSymbol: String
    let tradeTokenSymbol: String
    let marketInfo: MarketInfo

    init(tableView: UITableView, marketInfo: MarketInfo) {
        self.tradeTokenSymbol = marketInfo.statistic.tradeTokenSymbol
        self.quoteTokenSymbol = marketInfo.statistic.quoteTokenSymbol
        self.marketInfo = marketInfo
        super.init(tableView: tableView)
        fetch()
        sub()
    }

    override func refresh() -> Promise<(items: [MarketOrder], hasMore: Bool)> {
        return UnifyProvider.vitex.getOpenedOrderlist(address: address, tradeTokenSymbol: tradeTokenSymbol, quoteTokenSymbol: quoteTokenSymbol, offset: 0, limit: type(of: self).limit)
            .map { (items: $0, hasMore: $0.count >= type(of: self).limit) }
    }

    override func loadMore() -> Promise<(items: [MarketOrder], hasMore: Bool)> {
        return UnifyProvider.vitex.getOpenedOrderlist(address: address, tradeTokenSymbol: tradeTokenSymbol, quoteTokenSymbol: quoteTokenSymbol, offset: items.count, limit: type(of: self).limit)
            .map { (items: $0, hasMore: $0.count >= type(of: self).limit) }
    }

    override func clicked(model: MarketOrder) {

    }

    override func cellHeight(model: MarketOrder) -> CGFloat {
        return SpotOrderCell.cellHeight
    }

    override func cellFor(model: MarketOrder, indexPath: IndexPath) -> UITableViewCell {
        let cell: SpotOrderCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(model, tradeTokenInfo: self.pairTokenInfoBehaviorRelay.value?.quoteTokenInfo)
        return cell
    }

    override func merge(items: [MarketOrder]) {
        self.items.append(contentsOf: items)
    }


    deinit {
        unsub()
    }

    let depthListBehaviorRelay: BehaviorRelay<MarketDepthList?> = BehaviorRelay(value: nil)
    private let marketPairDetailInfoBehaviorRelay: BehaviorRelay<MarketPairDetailInfo?> = BehaviorRelay(value: nil)
    let pairTokenInfoBehaviorRelay: BehaviorRelay<(tradeTokenInfo: TokenInfo, quoteTokenInfo: TokenInfo)?> = BehaviorRelay(value: nil)

    let vipStateBehaviorRelay: BehaviorRelay<Bool?> = BehaviorRelay(value: nil)
    let operatorInfoIconUrlStringBehaviorRelay: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let levelBehaviorRelay: BehaviorRelay<Int> = BehaviorRelay(value: 0)

    var depthSubId: SubId? = nil
    var orderSubId: SubId? = nil
}

extension SpotOpenedOrderListViewModel {

    func fetchVIPState() {
        let address = self.address
        fetchUntilSuccess(promise: {
            ViteNode.dex.info.getDexVIPState(address: address)
        }) { [weak self] in
            guard let `self` = self else { return }
            self.vipStateBehaviorRelay.accept($0)
        }
    }

    func fetch() {
        let symbol = self.symbol
        fetchUntilSuccess(promise: {
            UnifyProvider.vitex.getDepth(symbol: symbol)
        }) { [weak self] (depthList) in
            guard let `self` = self else { return }
            plog(level: .debug, log: "getDepth for \(self.symbol)", tag: .market)
            guard self.depthListBehaviorRelay.value == nil else { return }
            self.depthListBehaviorRelay.accept(depthList)
        }

        let tradeToken: String = marketInfo.statistic.tradeToken
        let quoteToken: String = marketInfo.statistic!.quoteToken
        fetchUntilSuccess(promise: {
            UnifyProvider.vitex.getPairDetailInfo(tradeTokenId: tradeToken, quoteTokenId: quoteToken)
        }) { [weak self] (info) in
            guard let `self` = self else { return }
            plog(level: .debug, log: "getPairDetailInfo for \(self.symbol)", tag: .market)
            self.marketPairDetailInfoBehaviorRelay.accept(info)
            self.operatorInfoIconUrlStringBehaviorRelay.accept(info.operatorInfo.icon)
            self.levelBehaviorRelay.accept(info.operatorInfo.level)
            self.tirggerRefresh()
        }

        let tradeTokenId = marketInfo.statistic.tradeToken
        let quoteTokenId = marketInfo.statistic.quoteToken
        fetchUntilSuccess(promise: {
            when(fulfilled:
                TokenInfoCacheService.instance.tokenInfo(forViteTokenId: tradeTokenId),
                TokenInfoCacheService.instance.tokenInfo(forViteTokenId: quoteTokenId))
        }) { [weak self] (tradeTokenInfo, quoteTokenInfo) in
            guard let `self` = self else { return }
            self.pairTokenInfoBehaviorRelay.accept((tradeTokenInfo: tradeTokenInfo, quoteTokenInfo: quoteTokenInfo))
        }

        fetchVIPState()
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

    var symbol: String { marketInfo.statistic.symbol }
    var depthTopic: String { "market.\(symbol).depth" }
    var orderTopic: String { "order.\(address)" }

    func sub() {

        depthSubId = MarketInfoService.shared.marketSocket.sub(topic: depthTopic, ticker: { [weak self] (data) in
            guard let `self` = self else { return }
            guard let depthListProto = try? DepthListProto(serializedData: data) else { return }
            plog(level: .debug, log: "receive new DepthListProto for \(self.symbol) ", tag: .market)
            self.depthListBehaviorRelay.accept(MarketDepthList.generate(proto: depthListProto))
        })

        orderSubId = MarketInfoService.shared.marketSocket.sub(topic: orderTopic, ticker: { [weak self] (data) in
            guard let `self` = self else { return }
            guard let orderProto = try? OrderProto(serializedData: data) else { return }
            let order = MarketOrder(orderProto: orderProto)
            plog(level: .debug, log: "receive new OrderProto for \(order.symbol) ", tag: .market)

            if let first =  self.items.first {
                if order.createTime > first.createTime {
                    if order.status == .open {
                        self.items.insert(order, at: 0)
                        self.tableView.reloadData()
                    }
                } else {
                    var index: Int? = nil
                    for (i, item) in self.items.enumerated() where order.orderId == item.orderId {
                        index = i
                        break
                    }

                    if let index = index {
                        if order.status == .open {
                            self.items.remove(at: index)
                            self.items.insert(order, at: index)
                        } else {
                            self.items.remove(at: index)
                        }
                        self.tableView.reloadData()
                    }
                }
            } else {

                if order.status == .open {
                    self.items.append(order)
                    self.tableView.reloadData()
                }
            }
        })
    }

    func unsub() {
        if let old = self.depthSubId {
            MarketInfoService.shared.marketSocket.unsub(subId: old)
        }

        if let old = self.orderSubId {
            MarketInfoService.shared.marketSocket.unsub(subId: old)
            self.orderSubId = nil
        }
    }
}
