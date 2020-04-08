//
//  SpotOpenedOrderListViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2020/4/7.
//

import Foundation
import PromiseKit

class SpotOpenedOrderListViewModel: ListViewModel<MarketOrder> {
    static let limit = 50
    let address = HDWalletManager.instance.account!.address
    let quoteTokenSymbol: String
    let tradeTokenSymbol: String

    init(tableView: UITableView, tradeTokenSymbol: String, quoteTokenSymbol: String) {
        self.tradeTokenSymbol = tradeTokenSymbol
        self.quoteTokenSymbol = quoteTokenSymbol
        super.init(tableView: tableView)
        tirggerRefresh()
        subOrder()
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
        cell.bind(model)
        return cell
    }

    override func merge(items: [MarketOrder]) {
        self.items.append(contentsOf: items)
    }

    var orderSubId: SubId? = nil

    deinit {
        unsub()
    }
}

extension SpotOpenedOrderListViewModel {

    var orderTopic: String { "order.\(address)" }

    func subOrder() {
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
        if let old = self.orderSubId {
            MarketInfoService.shared.marketSocket.unsub(subId: old)
            self.orderSubId = nil
        }
    }
}
