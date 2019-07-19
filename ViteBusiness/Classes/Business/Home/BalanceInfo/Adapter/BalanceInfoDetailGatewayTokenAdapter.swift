//
//  BalanceInfoDetailGatewayTokenAdapter.swift
//  Action
//
//  Created by haoshenyang on 2019/6/11.
//

import Foundation

class BalanceInfoDetailGatewayTokenAdapter: BalanceInfoDetailAdapter {

    let tokenInfo: TokenInfo

    required init(tokenInfo: TokenInfo) {
            self.tokenInfo = tokenInfo
    }

    func viewDidAppear() {
        ViteBalanceInfoManager.instance.registerFetch(tokenInfos: [tokenInfo])
        FetchQuotaManager.instance.retainQuota()
    }

    func viewDidDisappear() {
        ViteBalanceInfoManager.instance.unregisterFetch(tokenInfos: [tokenInfo])
        FetchQuotaManager.instance.releaseQuota()
    }

    func setup(containerView: UIView) {

        let cardView = BalanceInfoViteChainCardView()
        containerView.addSubview(cardView)
        cardView.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.equalToSuperview().offset(24)
            m.right.equalToSuperview().offset(-24)
            m.height.equalTo(188)
        }

        cardView.bind(tokenInfo: tokenInfo)

        var sourceView: UIView?
        let o0 = BalanceInfoOperation.init(icon: R.image.crosschain_operat_deposit(), title: R.string.localizable.crosschainDeposit()) {
            let a0 = UIAlertAction.init(title: R.string.localizable.crosschainDepositVitewallet(), style: .default) { [unowned self] (_) in
                let vc = EthViteExchangeViewController()
                vc.gatewayInfoService = CrossChainGatewayInfoService.init(tokenInfo: self.tokenInfo)
                vc.exchangeType = .ethChainToViteToken
                UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
            }
            let a1 = UIAlertAction.init(title: R.string.localizable.crosschainDepositOtherwallet(), style: .default) { [unowned self] (_) in
                let vc = GatewayDepositViewController.init(gatewayInfoService: CrossChainGatewayInfoService.init(tokenInfo: self.tokenInfo))
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
            let vc = GatewayWithdrawViewController.init(gateWayInfoService: CrossChainGatewayInfoService.init(tokenInfo: self.tokenInfo))
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        }
        let operationView = BalanceInfoOperationView.init(firstOperation: o0, secondOperation: o1)
        sourceView = operationView.leftButton

        containerView.addSubview(operationView)
        operationView.snp.makeConstraints { (m) in
            m.top.equalTo(cardView.snp.bottom).offset(16)
            m.left.equalToSuperview().offset(24)
            m.right.equalToSuperview().offset(-24)
            m.height.equalTo(44)
        }

        let transactionsView = BalanceInfoViteChainTransactionsView(tokenInfo: tokenInfo)
        containerView.addSubview(transactionsView)
        transactionsView.snp.makeConstraints { (m) in
            m.top.equalTo(operationView.snp.bottom).offset(14)
            m.left.equalToSuperview()
            m.right.equalToSuperview()
            m.bottom.equalToSuperview()
        }
    }
}
