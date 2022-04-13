//
//  MiningStakingWithdrawalListViewController.swift
//  ViteBusiness
//
//  Created by stone on 2022/2/14.
//

import Foundation
import ViteWallet
import RxSwift
import RxCocoa

class MiningStakingWithdrawalListViewController: BaseTableViewController {

    var viewModle: MiningStakingWithdrawalListViewModel?

    init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }

    func setupView() {
        navigationItem.title = R.string.localizable.miningStakingPageWithdrawPageTitle()
        navigationBarStyle = .default
        tableView.contentInsetAdjustmentBehavior = .never
        viewModle = MiningStakingWithdrawalListViewModel(tableView: self.tableView, address: HDWalletManager.instance.account!.address)
    }

    func bind() {

    }
}
