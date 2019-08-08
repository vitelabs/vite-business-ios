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

    required init(tokenInfo: TokenInfo, headerView: UIStackView, tableView: UITableView) {
        let handler = TableViewHandler(tableView: tableView)
        let delegate = BalanceInfoViteChainTabelViewDelegate(tokenInfo: tokenInfo, tableViewHandler: handler)
        handler.delegate = delegate

        self.tokenInfo = tokenInfo
        self.delegate = delegate
        self.setup(headerView: headerView)
    }

    func viewDidAppear() {
        ViteBalanceInfoManager.instance.registerFetch(tokenInfos: [tokenInfo])
        FetchQuotaManager.instance.retainQuota()
    }

    func viewDidDisappear() {
        ViteBalanceInfoManager.instance.unregisterFetch(tokenInfos: [tokenInfo])
        FetchQuotaManager.instance.releaseQuota()
    }

    func setup(headerView: UIStackView) {
        let cardView = BalanceInfoViteChainCardView()
        let operationView = getOperationView()

        cardView.bind(tokenInfo: tokenInfo)

        headerView.addArrangedSubview(cardView.padding(horizontal: 24))
        headerView.addPlaceholder(height: 16)
        headerView.addArrangedSubview(operationView.padding(horizontal: 24))
    }

    fileprivate func getOperationView() -> UIView {
        let tokenInfo = self.tokenInfo
        var sourceView: UIView?
        let o0 = BalanceInfoOperation.init(icon: R.image.crosschain_operat_deposit(), title: R.string.localizable.crosschainDeposit()) {
            let a0 = UIAlertAction.init(title: R.string.localizable.crosschainDepositVitewallet(), style: .default) { (_) in
                let vc = EthViteExchangeViewController()
                vc.gatewayInfoService = CrossChainGatewayInfoService.init(tokenInfo: tokenInfo)
                vc.exchangeType = .ethChainToViteToken
                UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
            }
            let a1 = UIAlertAction.init(title: R.string.localizable.crosschainDepositOtherwallet(), style: .default) { (_) in
                let vc = GatewayDepositViewController.init(gatewayInfoService: CrossChainGatewayInfoService.init(tokenInfo: tokenInfo))
                UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
            }

            let a2 = UIAlertAction.init(title: R.string.localizable.cancel(), style: .cancel) { _ in }
            var message: String? = R.string.localizable.crosschainBetaAlert()
            if message == "" {
                message = nil
            }
            let alert = UIAlertController.init(title: nil, message: message, preferredStyle: .actionSheet)
            alert.addAction(a0)
            alert.addAction(a1)
            alert.addAction(a2)
            if let popover = alert.popoverPresentationController, let sourceView = sourceView {
                popover.sourceView = sourceView
                popover.sourceRect = sourceView.bounds
                popover.permittedArrowDirections = .any;
            }
            UIViewController.current?.present(alert, animated: true, completion: nil)
        }

        let o1 = BalanceInfoOperation.init(icon: R.image.crosschain_operat_withdraw(), title: R.string.localizable.crosschainWithdraw()) {
            let vc = GatewayWithdrawViewController.init(gateWayInfoService: CrossChainGatewayInfoService.init(tokenInfo: tokenInfo))
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        }
        let operationView = BalanceInfoViteGatewayOperationView.init(firstOperation: o0, secondOperation: o1)
        sourceView = operationView.leftButton
        return operationView
    }
}
