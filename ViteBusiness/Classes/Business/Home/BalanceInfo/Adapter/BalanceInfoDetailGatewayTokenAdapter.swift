//
//  BalanceInfoDetailGatewayTokenAdapter.swift
//  Action
//
//  Created by haoshenyang on 2019/6/11.
//

import Foundation

class BalanceInfoDetailGatewayTokenAdapter: BalanceInfoDetailAdapter {

    let tokenInfo: TokenInfo
    var sourceView: UIView?

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

        let o0 = BalanceInfoOperation.init(icon: R.image.crosschain_operat_deposit(), title: R.string.localizable.crosschainDeposit()) { [weak self] in
            self?.showStatement(isWithDraw: false)
        }

        let o1 = BalanceInfoOperation.init(icon: R.image.crosschain_operat_withdraw(), title: R.string.localizable.crosschainWithdraw()) { [weak self] in
            self?.showStatement(isWithDraw: true)
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

    func showStatement(isWithDraw:Bool) {
        let vc = CrossChainStatementViewController(tokenInfo: tokenInfo)
        vc.isWithDraw = isWithDraw
        UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
    }

}
