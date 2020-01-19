//
//  DeFiBillBorrowedFundViewController.swift
//  Action
//
//  Created by haoshenyang on 2019/12/4.
//

import UIKit

class DeFiBillBorrowedFundViewController: BaseTableViewController {

    var status: DeFiAPI.Bill.BillType {
        get {
            return viewModel.status
        }
        set {
            viewModel = MyDeFiBillBaseFundListViewModel(tableView: self.tableView, status: newValue, accountType: .借币账户)
        }
    }

    lazy var viewModel = MyDeFiBillBaseFundListViewModel(tableView: self.tableView, status: .全部, accountType: .借币账户)

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = viewModel
    }

}


