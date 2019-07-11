//
//  BalanceInfoDetailBnbAdapter.swift
//  ViteBusiness
//
//  Created by Water on 2019/6/25.
//

import Foundation

class BalanceInfoDetailBnbAdapter: BalanceInfoDetailAdapter {

    let tokenInfo: TokenInfo
    let transactionsView : BalanceInfoBnbChainTransactionsView
    required init(tokenInfo: TokenInfo) {
        self.tokenInfo = tokenInfo
        self.transactionsView = BalanceInfoBnbChainTransactionsView(tokenInfo: tokenInfo)
    }

    func viewDidAppear() {
        BnbWallet.shared.fetchBalance()
        self.transactionsView.refreshData()
    }

    func viewDidDisappear() {

    }

    func setup(containerView: UIView) {

        let cardView = BalanceInfoBnbChainCardView()
        containerView.addSubview(cardView)
        cardView.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.equalToSuperview().offset(24)
            m.right.equalToSuperview().offset(-24)
            m.height.equalTo(188)
        }

        cardView.bind(tokenInfo: tokenInfo)
        
        containerView.addSubview(transactionsView)
        transactionsView.snp.makeConstraints { (m) in
            m.top.equalTo(cardView.snp.bottom).offset(14)
            m.left.equalToSuperview()
            m.right.equalToSuperview()
            m.bottom.equalToSuperview()
        }
    }
}
