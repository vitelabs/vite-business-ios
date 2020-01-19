//
//  MyDeFiLoanListViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2019/12/2.
//

import Foundation
import PromiseKit

class MyDeFiLoanListViewModel: ListViewModel<DeFiLoan> {

    static let limit = 20
    let address = HDWalletManager.instance.account!.address

    let status: DeFiAPI.ProductStatus
    init(tableView: UITableView, status: DeFiAPI.ProductStatus) {
        self.status = status
        super.init(tableView: tableView)
        tirggerRefresh()
    }

    override func refresh() -> Promise<(items: [DeFiLoan], hasMore: Bool)> {
        return UnifyProvider.defi.getMyLoans(status: status, address: address, offset: 0, limit: type(of: self).limit)
            .map { (items: $0, hasMore: $0.count >= type(of: self).limit) }
    }

    override func loadMore() -> Promise<(items: [DeFiLoan], hasMore: Bool)> {
        return UnifyProvider.defi.getMyLoans(status: status, address: address, offset: items.count, limit: type(of: self).limit)
            .map { (items: $0, hasMore: $0.count >= type(of: self).limit) }
    }

    override func clicked(model: DeFiLoan) {
        let vc = DeFiLoanDetailViewController(loan: model)
        UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
    }

    override func cellHeight(model: DeFiLoan) -> CGFloat {
        return MyDeFiLoanCell.cellHeight
    }

    override func cellFor(model: DeFiLoan, indexPath: IndexPath) -> UITableViewCell {
        let cell: MyDeFiLoanCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(model)
        return cell
    }
}
