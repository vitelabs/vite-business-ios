//
//  DexTokenDetailViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2020/8/27.
//

import Foundation
import ViteWallet
import RxSwift
import RxCocoa

class DexTokenDetailViewController: BaseTableViewController {

    let type: DexAssetsHomeViewController.PType
    let tokenInfo: TokenInfo
    var viewModle: Any?

    init(tokenInfo: TokenInfo, type: DexAssetsHomeViewController.PType) {
        self.tokenInfo = tokenInfo
        self.type = type
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

    lazy var headerView = DexTokenDetailHeaderView(tokenInfo: self.tokenInfo, type: self.type)
    lazy var bottomView = DexTokenDetailBottomView(tokenInfo: self.tokenInfo, type: self.type)

    func setupView() {
        navigationItem.title = R.string.localizable.dexTokenDetailPageTitle()
        navigationBarStyle = .default
        tableView.contentInsetAdjustmentBehavior = .never
        headerView.frame = CGRect(x: 0, y: 0, width: 0, height: headerView.height)
        tableView.tableHeaderView = headerView

        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { (m) in
            m.left.right.bottom.equalToSuperview()
            m.top.equalTo(self.view.safeAreaLayoutGuideSnpBottom).offset(-94)
        }

        tableView.snp.remakeConstraints { (m) in
            m.top.left.right.equalTo(view)
            m.bottom.equalTo(bottomView.snp.top)
        }

        switch self.type {
        case .wallet:
            viewModle = DexTokenDetailListWalletViewModel(tableView: self.tableView, tokenInfo: self.tokenInfo, address: HDWalletManager.instance.account!.address)
        case .vitex:
            viewModle = DexTokenDetailListDexViewModel(tableView: self.tableView, tokenInfo: self.tokenInfo, address: HDWalletManager.instance.account!.address)
        }
    }

    func bind() {

    }
}


