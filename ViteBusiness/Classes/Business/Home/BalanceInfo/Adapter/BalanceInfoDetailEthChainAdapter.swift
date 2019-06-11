//
//  BalanceInfoDetailEthChainAdapter.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/5.
//

import Foundation

class BalanceInfoDetailEthChainAdapter: BalanceInfoDetailAdapter {

    let tokenInfo: TokenInfo

    required init(tokenInfo: TokenInfo) {
        self.tokenInfo = tokenInfo
    }

    func viewDidAppear() {
        ETHBalanceInfoManager.instance.registerFetch(tokenInfos: [tokenInfo])
    }

    func viewDidDisappear() {
        ETHBalanceInfoManager.instance.unregisterFetch(tokenInfos: [tokenInfo])
    }

    func setup(containerView: UIView) {

        let cardView = BalanceInfoEthChainCardView()
        containerView.addSubview(cardView)
        cardView.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.equalToSuperview().offset(24)
            m.right.equalToSuperview().offset(-24)
            m.height.equalTo(188)
        }

        cardView.bind(tokenInfo: tokenInfo)

        let transactionsView = BalanceInfoEthChainTransactionsView(tokenInfo: tokenInfo)
        containerView.addSubview(transactionsView)
        transactionsView.snp.makeConstraints { (m) in
            m.top.equalTo(cardView.snp.bottom).offset(14)
            m.left.equalToSuperview()
            m.right.equalToSuperview()
            m.bottom.equalToSuperview()
        }
    }
}
