//
//  BalanceInfoEthErc20ViteOperationView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/2/28.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class BalanceInfoEthErc20ViteOperationView: UIView {

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 0, height: 44)
    }

    let exchangeButton = OperationButton(icon: R.image.icon_balance_detail_vote(), title: R.string.localizable.balanceInfoDetailVote())

    override init(frame: CGRect) {
        super.init(frame: frame)


        clipsToBounds = false
        
        addSubview(exchangeButton)

        exchangeButton.snp.makeConstraints { (m) in
            m.top.bottom.equalToSuperview()
            m.left.equalToSuperview()
            m.right.equalToSuperview()
        }

        exchangeButton.button.rx.tap.bind {
            let sendViewController = EthViteExchangeViewController()
            UIViewController.current?.navigationController?.pushViewController(sendViewController, animated: true)
            }.disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
