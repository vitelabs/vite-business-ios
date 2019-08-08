//
//  BalanceInfoDetailEthErc20ViteAdapter.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/5.
//

import Foundation

class BalanceInfoDetailEthErc20ViteAdapter: BalanceInfoDetailAdapter {

    let tokenInfo: TokenInfo
    let delegate: BalanceInfoDetailTableViewDelegate?

    required init(tokenInfo: TokenInfo, headerView: UIStackView, tableView: UITableView) {
        let handler = TableViewHandler(tableView: tableView)
        let delegate = BalanceInfoEthChainTabelViewDelegate(tokenInfo: tokenInfo, tableViewHandler: handler)
        handler.delegate = delegate

        self.tokenInfo = tokenInfo
        self.delegate = delegate
        self.setup(headerView: headerView)
    }

    func viewDidAppear() {
        ETHBalanceInfoManager.instance.registerFetch(tokenInfos: [tokenInfo])
    }

    func viewDidDisappear() {
        ETHBalanceInfoManager.instance.unregisterFetch(tokenInfos: [tokenInfo])
    }

    func setup(headerView: UIStackView) {
        let cardView = BalanceInfoEthChainCardView()
        let operationView = BalanceInfoEthErc20ViteOperationView()
        
        cardView.bind(tokenInfo: tokenInfo)
        headerView.addArrangedSubview(cardView.padding(horizontal: 24))
        headerView.addPlaceholder(height: 16)
        headerView.addArrangedSubview(operationView.padding(horizontal: 24))
    }
}
