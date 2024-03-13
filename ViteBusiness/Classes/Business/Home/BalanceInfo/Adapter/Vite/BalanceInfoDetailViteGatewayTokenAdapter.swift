//
//  BalanceInfoDetailGatewayTokenAdapter.swift
//  Action
//
//  Created by haoshenyang on 2019/6/11.
//

import Foundation

class BalanceInfoDetailGatewayTokenAdapter: BalanceInfoDetailAdapter {

    let tokenInfo: TokenInfo

    let delegate: BalanceInfoDetailTableViewDelegate?

    var sourceView: UIView?


    required init(tokenInfo: TokenInfo, headerView: UIStackView, tableView: UITableView, vc: UIViewController? = nil) {
        let handler = TableViewHandler(tableView: tableView)
        let delegate = BalanceInfoViteChainTabelViewDelegate(tokenInfo: tokenInfo, tableViewHandler: handler)
        handler.delegate = delegate

        self.tokenInfo = tokenInfo
        self.delegate = delegate
        self.setup(headerView: headerView)
    }

    func viewDidAppear() {
        FetchQuotaManager.instance.retainQuota()
    }

    func viewDidDisappear() {
        FetchQuotaManager.instance.releaseQuota()
    }

    func setup(headerView: UIStackView) {
        let cardView = BalanceInfoViteChainCardView(isViteCoin: false)
        let operationView = getOperationView()

        cardView.bind(tokenInfo: tokenInfo)

        headerView.addArrangedSubview(cardView.padding(horizontal: 24))
        headerView.addPlaceholder(height: 16)
        headerView.addArrangedSubview(operationView.padding(horizontal: 24))
    }

    fileprivate func getOperationView() -> UIView {
        let tokenInfo = self.tokenInfo

        let o0 = BalanceInfoOperation.init(icon: R.image.crosschain_operat_deposit()?.tintColor(UIColor(netHex: 0x00BEFF)), title: R.string.localizable.crosschainDeposit()) { [weak self] in
            self?.showStatement(isWithDraw: false)
        }

        let o1 = BalanceInfoOperation.init(icon: R.image.crosschain_operat_withdraw()?.tintColor(UIColor(netHex: 0x00BEFF)), title: R.string.localizable.crosschainWithdraw()) { [weak self] in
            self?.showStatement(isWithDraw: true)
        }
        let operationView = BalanceInfoViteGatewayOperationView.init(firstOperation: o0, secondOperation: o1)
        sourceView = operationView.leftButton
        return operationView
    }

    func showStatement(isWithDraw:Bool) {
        let vc = CrossChainStatementViewController(tokenInfo: tokenInfo)
        vc.isWithDraw = isWithDraw
        UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
    }

}
