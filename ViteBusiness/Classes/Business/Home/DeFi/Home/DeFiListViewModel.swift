//
//  DeFiListViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2019/11/29.
//

import Foundation
import PromiseKit

class DeFiListViewModel: ListViewModel<DeFiLoan> {

    static let limit = 20

    let sortType: DeFiAPI.ProductSortType
    init(tableView: UITableView, sortType: DeFiAPI.ProductSortType) {
        self.sortType = sortType
        super.init(tableView: tableView)
        tirggerRefresh()
    }

    override func refresh() -> Promise<(items: [DeFiLoan], hasMore: Bool)> {
        return UnifyProvider.defi.getAllOnSaleLoans(sortType: sortType, offset: 0, limit: type(of: self).limit)
            .map { (items: $0, hasMore: $0.count >= type(of: self).limit) }
    }

    override func loadMore() -> Promise<(items: [DeFiLoan], hasMore: Bool)> {
        return UnifyProvider.defi.getAllOnSaleLoans(sortType: sortType, offset: items.count, limit: type(of: self).limit)
            .map { (items: $0, hasMore: $0.count >= type(of: self).limit) }
    }

    override func clicked(model: DeFiLoan) {
        let detail = DeFiProductDetailViewController()
        detail.productHash = model.productHash
        UIViewController.current?.navigationController?.pushViewController(detail, animated: true)
    }

    override func cellHeight(model: DeFiLoan) -> CGFloat {
        return DeFiHomeProductCell.cellHeight
    }

    override func cellFor(model: DeFiLoan, indexPath: IndexPath) -> UITableViewCell {
        let cell: DeFiHomeProductCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(model)
        return cell
    }
}
