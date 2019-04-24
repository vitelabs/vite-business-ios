//
//  EthViteExchangeViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2019/4/24.
//

import UIKit

class EthViteExchangeViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }

    let exchangeButton = UIButton(style: .blue, title: R.string.localizable.sendPageSendButtonTitle())

    func setupView() {
        view.addSubview(exchangeButton)

        exchangeButton.snp.makeConstraints { (m) in
//            m.top.greaterThanOrEqualTo(scrollView.snp.bottom).offset(10)
            m.left.equalTo(view).offset(24)
            m.right.equalTo(view).offset(-24)
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom).offset(-24)
            m.height.equalTo(50)
        }
    }

    func bind() {

        exchangeButton.rx.tap.bind {

        }.disposed(by: rx.disposeBag)
    }

}
