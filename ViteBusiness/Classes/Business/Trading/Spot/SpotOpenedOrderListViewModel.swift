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
}
