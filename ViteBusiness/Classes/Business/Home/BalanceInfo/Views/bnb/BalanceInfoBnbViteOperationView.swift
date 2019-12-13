//
//  BalanceInfoEthErc20ViteOperationView.swift
//  ViteBusiness
//
//  Created by Water on 2019/12/10.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class BalanceInfoBnbViteOperationView: UIView {

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 0, height: 44)
    }

    let exchangeButton = OperationButton(icon: R.image.icon_balance_detail_exchange(), title: R.string.localizable.balanceInfoDetailExchangeVite(), style: .single)

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
            Statistics.log(eventId: Statistics.Page.WalletHome.ethViteConversionClicked.rawValue)
            let sendViewController = EthViteExchangeViewController()
            UIViewController.current?.navigationController?.pushViewController(sendViewController, animated: true)
            }.disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

