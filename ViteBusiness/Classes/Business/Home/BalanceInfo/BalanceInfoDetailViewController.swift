//
//  BalanceInfoDetailViewController.swift
//  Vite
//
//  Created by Stone on 2018/9/9.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import ViteWallet
import SnapKit
import RxSwift
import RxCocoa
import NSObject_Rx

class BalanceInfoDetailViewController: BaseViewController {

    let tokenInfo: TokenInfo

    init(tokenInfo: TokenInfo) {
        self.tokenInfo = tokenInfo
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }


    let navView = BalanceInfoNavView()
    let containerView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }

    func setupView() {
        navigationBarStyle = .default

        view.addSubview(navView)
        view.addSubview(containerView)

        navView.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.right.equalToSuperview()
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpTop).offset(128)
        }

        containerView.snp.makeConstraints { (m) in
            m.top.equalTo(navView.snp.bottom).offset(-60)
            m.left.right.bottom.equalToSuperview()
        }

        addSub()
    }

    func bind() {
        navView.bind(tokenInfo: tokenInfo)
    }

    func addSub() {
        let cardView = BalanceInfoViteChainCardView()
        containerView.addSubview(cardView)
        cardView.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.equalToSuperview().offset(24)
            m.right.equalToSuperview().offset(-24)
            m.height.equalTo(188)
        }

        cardView.bind(tokenInfo: tokenInfo)

        let operationView = BalanceInfoViteCoinOperationView()
        containerView.addSubview(operationView)
        operationView.snp.makeConstraints { (m) in
            m.top.equalTo(cardView.snp.bottom).offset(16)
            m.left.equalToSuperview().offset(24)
            m.right.equalToSuperview().offset(-24)
            m.height.equalTo(44)
        }

        let transactionsView = BalanceInfoViteChainTransactionsView()
        containerView.addSubview(transactionsView)
        transactionsView.snp.makeConstraints { (m) in
            m.top.equalTo(operationView.snp.bottom).offset(14)
            m.left.equalToSuperview()
            m.right.equalToSuperview()
            m.bottom.equalToSuperview()
        }

    }
}
