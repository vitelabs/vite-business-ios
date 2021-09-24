//
//  SpotHistoryListViewModel.swift
//  ViteBusiness
//
//  Created by stone on 2021/9/16.
//

import Foundation
import RxSwift
import RxCocoa
import PromiseKit
import ViteWallet
import BigInt

class SpotHistoryListViewModel: ListViewModel<MarketOrder> {
    static let limit = 50
    let address: ViteAddress
    
    fileprivate var quoteTokenSymbol: String?
    fileprivate var tradeTokenSymbol: String?
    fileprivate var startTime: TimeInterval?
    fileprivate var side: Int32?
    fileprivate var status: MarketOrder.Status?
    fileprivate var isShowOpen = false
    
    func showOpen() {
        isShowOpen = true
        filter(tradeTokenSymbol: nil, quoteTokenSymbol: nil, startTime: nil, side: nil, status: .open)
    }
    
    func showHistory(tradeTokenSymbol: String?, quoteTokenSymbol: String?, startTime: TimeInterval?, side: Int32?, status: MarketOrder.Status?) {
        isShowOpen = false
        filter(tradeTokenSymbol: tradeTokenSymbol, quoteTokenSymbol: quoteTokenSymbol, startTime: startTime, side: side, status: status)
    }
    
    fileprivate func filter(tradeTokenSymbol: String?, quoteTokenSymbol: String?, startTime: TimeInterval?, side: Int32?, status: MarketOrder.Status?) {
        self.tradeTokenSymbol = tradeTokenSymbol
        self.quoteTokenSymbol = quoteTokenSymbol
        self.startTime = startTime
        self.side = side
        self.status = status
        self.tirggerRefresh(clear: true)
    }

    init(tableView: UITableView, address: ViteAddress) {
        self.address = address
        super.init(tableView: tableView)
        fetch()
        sub()
        
        MarketInfoService.shared.marketSocket.isConnectedBehaviorRelay.filter { $0 }.skip(1).bind { [weak self] _ in
            guard let `self` = self else { return }
            self.tirggerRefresh()
        }.disposed(by: rx.disposeBag)
    }

    override func refresh() -> Promise<(items: [MarketOrder], hasMore: Bool)> {
        return UnifyProvider.vitex.getOrderlist(address: address, tradeTokenSymbol: tradeTokenSymbol, quoteTokenSymbol: quoteTokenSymbol, startTime: startTime, side: side, status: status, offset: 0, limit: type(of: self).limit)
            .map { (items: $0, hasMore: $0.count >= type(of: self).limit) }
    }

    override func loadMore() -> Promise<(items: [MarketOrder], hasMore: Bool)> {
        return UnifyProvider.vitex.getOrderlist(address: address, tradeTokenSymbol: tradeTokenSymbol, quoteTokenSymbol: quoteTokenSymbol, startTime: startTime, side: side, status: status, offset: items.count, limit: type(of: self).limit)
            .map { (items: $0, hasMore: $0.count >= type(of: self).limit) }
    }

    override func clicked(model: MarketOrder) {

    }

    override func cellHeight(model: MarketOrder) -> CGFloat {
        return SpotOrderCell.cellHeight
    }

    override func cellFor(model: MarketOrder, indexPath: IndexPath) -> UITableViewCell {
        let cell: SpotOrderCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(model, showCancelButton: isShowOpen)
        return cell
    }

    override func merge(items: [MarketOrder]) {
        self.items.append(contentsOf: items)
    }


    deinit {
        unsub()
    }
    
    var orderSubId: SubId? = nil
}

extension SpotHistoryListViewModel {

    

    fileprivate func fetch() {
        self.tirggerRefresh()
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

    var orderTopic: String { "order.\(address)" }

    fileprivate func sub() {

        orderSubId = MarketInfoService.shared.marketSocket.sub(topic: orderTopic, ticker: { [weak self] (data) in
            guard let `self` = self else { return }
            guard let orderProto = try? OrderProto(serializedData: data) else { return }
            let order = MarketOrder(orderProto: orderProto)
            plog(level: .debug, log: "receive new OrderProto for \(order.symbol) ", tag: .market)
            
            if self.isShowOpen {
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
            } else {
                // do nothing
            }

            self.updateLoadStatus()
        })
    }

    fileprivate func unsub() {
        if let old = self.orderSubId {
            MarketInfoService.shared.marketSocket.unsub(subId: old)
            self.orderSubId = nil
        }
    }
}
