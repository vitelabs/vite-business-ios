//
//  MyDeFiSubscribeViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2019/12/2.
//

import UIKit

class MyDeFiSubscribeViewController: BaseTableViewController {

    var status: DeFiAPI.ProductStatus {
        get {
            return viewModel.status
        }
        set {
            viewModel = MyDeFiSubscribeListViewModel(tableView: self.tableView, status: newValue)
        }
    }

    lazy var viewModel = MyDeFiSubscribeListViewModel(tableView: self.tableView, status: .all)

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = viewModel
    }
}
