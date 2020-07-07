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
    let quoteTokenSymbol: String
    let tradeTokenSymbol: String
    let marketInfo: MarketInfo
    let address: ViteAddress

    override var items: [MarketOrder] {
        didSet {
            orderListBehaviorRelay.accept(items)
        }
    }

    init(tableView: UITableView, marketInfo: MarketInfo, address: ViteAddress) {
        self.tradeTokenSymbol = marketInfo.statistic.tradeTokenSymbol
        self.quoteTokenSymbol = marketInfo.statistic.quoteTokenSymbol
        self.marketInfo = marketInfo
        self.address = address
        super.init(tableView: tableView)
        fetch()
        sub()
        
        MarketInfoService.shared.marketSocket.isConnectedBehaviorRelay.filter { $0 }.skip(1).bind { [weak self] _ in
            guard let `self` = self else { return }
            self.fetchDepth()
            self.tirggerRefresh()
        }.disposed(by: rx.disposeBag)
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
        cell.bind(model, tradeTokenInfo: self.spotViewModelBehaviorRelay.value?.quoteTokenInfo)
        return cell
    }

    override func merge(items: [MarketOrder]) {
        self.items.append(contentsOf: items)
    }


    deinit {
        unsub()
    }

    let depthListBehaviorRelay: BehaviorRelay<MarketDepthList?> = BehaviorRelay(value: nil)
    let spotViewModelBehaviorRelay: BehaviorRelay<SpotViewModel?> = BehaviorRelay(value: nil)
    let orderListBehaviorRelay: BehaviorRelay<[MarketOrder]> = BehaviorRelay(value: [])

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
            guard let vm = self.spotViewModelBehaviorRelay.value else { return }
            let spotViewModel = SpotViewModel(marketPairDetailInfo: vm.marketPairDetailInfo,
                                              tradeTokenInfo: vm.tradeTokenInfo,
                                              quoteTokenInfo: vm.quoteTokenInfo,
                                              vipState: $0,
                                              svipState: vm.svipState,
                                              dexMarketInfo: vm.dexMarketInfo,
                                              invited: vm.invited)
            self.spotViewModelBehaviorRelay.accept(spotViewModel)
        }
    }
    
    fileprivate func fetchDepth() {
        let symbol = self.symbol
        fetchUntilSuccess(promise: {
            UnifyProvider.vitex.getDepth(symbol: symbol, limit: 6)
        }) { [weak self] (depthList) in
            guard let `self` = self else { return }
            plog(level: .debug, log: "getDepth for \(self.symbol)", tag: .market)
            self.depthListBehaviorRelay.accept(depthList)
        }
    }

    fileprivate func fetch() {
        fetchDepth()

        let tradeToken = marketInfo.statistic.tradeToken
        let quoteToken = marketInfo.statistic!.quoteToken
        let tradeTokenId = marketInfo.statistic.tradeToken
        let quoteTokenId = marketInfo.statistic.quoteToken
        let address = self.address
        fetchUntilSuccess(promise: {
            when(fulfilled:
                when(fulfilled:
                     UnifyProvider.vitex.getPairDetailInfo(tradeTokenId: tradeToken, quoteTokenId: quoteToken),
                     TokenInfoCacheService.instance.tokenInfo(forViteTokenId: tradeTokenId),
                     TokenInfoCacheService.instance.tokenInfo(forViteTokenId: quoteTokenId)
                ),
                 when(fulfilled:
                      ViteNode.dex.info.getDexVIPState(address: address),
                      ViteNode.dex.info.getDexSuperVIPState(address: address),
                      ViteNode.dex.info.getDexMarketInfo(tradeTokenId: tradeTokenId, quoteTokenId: quoteTokenId),
                      ViteNode.dex.info.getDexInviteCodeBinding(address: address)
                )
            )
        }) { [weak self] (f, s) in
            guard let `self` = self else { return }
            let spotViewModel = SpotViewModel(marketPairDetailInfo: f.0,
                                              tradeTokenInfo: f.1,
                                              quoteTokenInfo: f.2,
                                              vipState: s.0,
                                              svipState: s.1,
                                              dexMarketInfo: s.2,
                                              invited: (s.3 != nil))
            self.spotViewModelBehaviorRelay.accept(spotViewModel)
            self.tirggerRefresh()
        }
    }

    fileprivate func fetchUntilSuccess<T>(promise: @escaping () -> Promise<T>, success: @escaping (T) -> Void) {
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

    fileprivate func sub() {

        depthSubId = MarketInfoService.shared.marketSocket.sub(topic: depthTopic, ticker: { [weak self] (data) in
            guard let `self` = self else { return }
            guard let depthListProto = try? DepthListProto(serializedData: data) else { return }
            plog(level: .debug, log: "receive new DepthListProto for \(self.symbol) ", tag: .market)
            self.depthListBehaviorRelay.accept(MarketDepthList.generate(proto: depthListProto, count: 6))
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

            self.updateLoadStatus()
        })
    }

    fileprivate func unsub() {
        if let old = self.depthSubId {
            MarketInfoService.shared.marketSocket.unsub(subId: old)
        }

        if let old = self.orderSubId {
            MarketInfoService.shared.marketSocket.unsub(subId: old)
            self.orderSubId = nil
        }
    }
}
