//
//  MyDeFiSubscribeListViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2019/12/2.
//

import Foundation
import PromiseKit

class MyDeFiSubscribeListViewModel: ListViewModel<MyDeFiSubscribeCell> {

    static let limit = 4
    let address = HDWalletManager.instance.account!.address

    let status: DeFiAPI.ProductStatus
    init(tableView: UITableView, status: DeFiAPI.ProductStatus) {
        self.status = status
        super.init(tableView: tableView)
        tirggerRefresh()
    }

    override func refresh() -> Promise<(items: [DeFiSubscription], hasMore: Bool)> {
        return UnifyProvider.defi.getMySubscriptions(status: status, address: address, offset: 0, limit: type(of: self).limit)
            .map { (items: $0, hasMore: $0.count >= type(of: self).limit) }
    }

    override func loadMore() -> Promise<(items: [DeFiSubscription], hasMore: Bool)> {
        return UnifyProvider.defi.getMySubscriptions(status: status, address: address, offset: items.count, limit: type(of: self).limit)
            .map { (items: $0, hasMore: $0.count >= type(of: self).limit) }
    }

    override func clicked(model: DeFiSubscription) {

    }
}
