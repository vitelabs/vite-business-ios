//
//  BalanceInfoBnbChainTransactionsView.swift
//  ViteBusiness
//
//  Created by Water on 2019/7/3.
//

import UIKit

class BalanceInfoBnbChainTransactionsView: UIView {

    private let vc: BnbTransactionListViewController

    init(tokenInfo: TokenInfo) {
        vc = BnbTransactionListViewController(symbol: tokenInfo.symbol)
        super.init(frame: CGRect.zero)

        let titleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            $0.textColor = UIColor(netHex: 0x3E4A59)
            $0.numberOfLines = 1
            $0.text = R.string.localizable.transactionListPageTitle()
        }


        let parentVC = self.ofViewController
        parentVC?.addChild(vc)
        vc.didMove(toParent: parentVC)

        addSubview(titleLabel)
        addSubview(vc.view)

        titleLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.equalToSuperview().offset(24)
            m.right.equalToSuperview().offset(-24)
            m.height.equalTo(20)
        }

        vc.view.snp.makeConstraints { (m) in
            m.left.right.bottom.equalToSuperview()
            m.top.equalTo(titleLabel.snp.bottom)
        }

    }

    func refreshData(){
        vc.refreshList()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

