//
//  BalanceInfoDetailViteTokenAdapter.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/5.
//

import Foundation

class BalanceInfoDetailViteTokenAdapter: BalanceInfoDetailAdapter {

    func setup(containerView: UIView, tokenInfo: TokenInfo) {

        let cardView = BalanceInfoViteChainCardView()
        containerView.addSubview(cardView)
        cardView.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.equalToSuperview().offset(24)
            m.right.equalToSuperview().offset(-24)
            m.height.equalTo(188)
        }

        cardView.bind(tokenInfo: tokenInfo)

        let transactionsView = BalanceInfoViteChainTransactionsView(tokenInfo: tokenInfo)
        containerView.addSubview(transactionsView)
        transactionsView.snp.makeConstraints { (m) in
            m.top.equalTo(cardView.snp.bottom).offset(14)
            m.left.equalToSuperview()
            m.right.equalToSuperview()
            m.bottom.equalToSuperview()
        }
    }
}
