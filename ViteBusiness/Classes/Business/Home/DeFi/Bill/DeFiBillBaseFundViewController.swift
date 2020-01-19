//
//  DeFiBillBaseFundViewController.swift
//  Action
//
//  Created by haoshenyang on 2019/12/4.
//

import UIKit
import PromiseKit

class DeFiBillBaseFundViewController: BaseTableViewController {

    var status: DeFiAPI.Bill.BillType {
        get {
            return viewModel.status
        }
        set {
            viewModel = MyDeFiBillBaseFundListViewModel(tableView: self.tableView, status: newValue , accountType: .基础账户)
        }
    }

    lazy var viewModel = MyDeFiBillBaseFundListViewModel(tableView: self.tableView, status: .全部, accountType: .基础账户)

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = viewModel
    }

}

class MyDeFiBillBaseFundListViewModel: ListViewModel<DeFiBill> {

    static let limit = 20
    let address = HDWalletManager.instance.account!.address

    let status: DeFiAPI.Bill.BillType
    let accountType: DeFiAPI.Bill.AccountType
    init(tableView: UITableView, status: DeFiAPI.Bill.BillType, accountType: DeFiAPI.Bill.AccountType) {
        self.status = status
        self.accountType = accountType
        super.init(tableView: tableView)
        tirggerRefresh()
    }

    override func refresh() -> Promise<(items: [DeFiBill], hasMore: Bool)> {
        return UnifyProvider.defi.getBills(address: address, accountType: self.accountType, billType: status, productHash: nil, offset: 0, limit: type(of: self).limit)
        .map { (items: $0, hasMore: $0.count >= type(of: self).limit) }

    }

    override func loadMore() -> Promise<(items: [DeFiBill], hasMore: Bool)> {
        return UnifyProvider.defi.getBills(address: address, accountType: self.accountType, billType: status, productHash: nil, offset: items.count, limit: type(of: self).limit)
            .map { (items: $0, hasMore: $0.count >= type(of: self).limit) }
    }

    override func clicked(model: DeFiBill) {

    }

    override func cellHeight(model: DeFiBill) -> CGFloat {
        return DeFiBillCell.cellHeight
    }

    override func cellFor(model: DeFiBill, indexPath: IndexPath) -> UITableViewCell {
        let cell: DeFiBillCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(model)
        return cell
    }
}
