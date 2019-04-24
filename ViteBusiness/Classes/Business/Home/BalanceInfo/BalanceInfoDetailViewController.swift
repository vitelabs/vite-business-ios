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
    let adapter: BalanceInfoDetailAdapter

    init(tokenInfo: TokenInfo) {
        self.tokenInfo = tokenInfo
        self.adapter = tokenInfo.createBalanceInfoDetailAdapter()
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        adapter.viewDidAppear()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        adapter.viewDidDisappear()
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
        adapter.setup(containerView: containerView)
    }

    func bind() {
        navView.bind(tokenInfo: tokenInfo)
    }
}
