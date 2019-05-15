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

    var firstViewDidAppear = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        adapter.viewDidAppear()

        if firstViewDidAppear {
            firstViewDidAppear = false
            if allowJumpTokenDetailPage {
                navView.tokenIconView.beat()
            }
        }
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


        if allowJumpTokenDetailPage {
            let tapGestureRecognizer = UITapGestureRecognizer()
            navView.tokenIconView.addGestureRecognizer(tapGestureRecognizer)
            tapGestureRecognizer.rx.event.subscribe(onNext: { [weak self] (r) in
                guard let url = self?.tokenInfo.infoURL else { return }
                let vc = WKWebViewController.init(url: url)
                UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: rx.disposeBag)
        }
    }

    func bind() {
        navView.bind(tokenInfo: tokenInfo)
    }
}

extension BalanceInfoDetailViewController {
    var allowJumpTokenDetailPage: Bool {
        switch tokenInfo.coinType {
        case .vite:
            return true
        case .eth:
            return !tokenInfo.isEtherCoin
        case .grin:
            return false
        }
    }
}
