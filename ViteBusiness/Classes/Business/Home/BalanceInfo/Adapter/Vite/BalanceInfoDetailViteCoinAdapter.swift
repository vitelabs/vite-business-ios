//
//  BalanceInfoDetailViteCoinAdapter.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/5.
//

import Foundation

class BalanceInfoDetailViteCoinAdapter: BalanceInfoDetailAdapter {

    let tokenInfo: TokenInfo
    let delegate: BalanceInfoDetailTableViewDelegate?

    required init(tokenInfo: TokenInfo, headerView: UIStackView, tableView: UITableView, vc: UIViewController? = nil) {
        let handler = TableViewHandler(tableView: tableView)
        let delegate = BalanceInfoViteChainTabelViewDelegate(tokenInfo: tokenInfo, tableViewHandler: handler)
        handler.delegate = delegate
        
        self.tokenInfo = tokenInfo
        self.delegate = delegate
        self.setup(headerView: headerView)
    }

    func viewDidAppear() {
        ViteBalanceInfoManager.instance.registerFetch(tokenCodes: [tokenInfo.tokenCode])
        FetchQuotaManager.instance.retainQuota()
    }

    func viewDidDisappear() {
        ViteBalanceInfoManager.instance.unregisterFetch(tokenCodes: [tokenInfo.tokenCode])
        FetchQuotaManager.instance.releaseQuota()
    }

    func setup(headerView: UIStackView) {
        let cardView = BalanceInfoViteChainCardView()
        let operationView = BalanceInfoViteCoinOperationView()

        cardView.bind(tokenInfo: tokenInfo)

        headerView.addArrangedSubview(cardView.padding(horizontal: 24))
        headerView.addPlaceholder(height: 16)
        headerView.addArrangedSubview(operationView.padding(horizontal: 24))
    }
}
