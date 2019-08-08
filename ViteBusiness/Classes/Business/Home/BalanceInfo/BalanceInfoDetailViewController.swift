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
import MJRefresh

class BalanceInfoDetailViewController: BaseViewController {
    let tokenInfo: TokenInfo
    var adapter: BalanceInfoDetailAdapter!

    init(tokenInfo: TokenInfo) {
        self.tokenInfo = tokenInfo
        super.init(nibName: nil, bundle: nil)
        self.adapter = tokenInfo.createBalanceInfoDetailAdapter(headerView: headerView, tableView: tableView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }


    let titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        $0.textColor = UIColor(netHex: 0x24272B)
        $0.alpha = 0
    }

    let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    let tableHeaderView = UIView()
    let tableFooterView = UIView()
    let navView = BalanceInfoNavView()
    let headerView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 0
    }


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

        view.backgroundColor = .white
        navigationBarStyle = .default
        navigationItem.titleView = titleLabel
        titleLabel.text = tokenInfo.uniqueSymbol

        view.addSubview(tableView)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -20, right: 0)
        tableView.backgroundColor = .white
        tableView.snp.remakeConstraints { (m) in
            m.top.left.right.equalTo(view)
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom)
        }

        tableHeaderView.addSubview(navView)
        tableHeaderView.addSubview(headerView)

        navView.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.right.equalToSuperview()
            m.height.equalTo(128)
        }

        headerView.snp.makeConstraints { (m) in
            m.top.equalTo(navView.snp.bottom).offset(-60)
            m.left.right.bottom.equalToSuperview()
        }

        let height = tableHeaderView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        tableHeaderView.frame = CGRect(x: 0, y: 0, width: 0, height: height)
        tableView.tableHeaderView = tableHeaderView

        let tapGestureRecognizer = UITapGestureRecognizer()
        navView.tokenIconView.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.rx.event.subscribe(onNext: { [unowned self] (r) in
            let vc =  GatewayTokenDetailViewController.init(tokenInfo: self.tokenInfo)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: rx.disposeBag)

        navView.gatewayInfoBtn.rx.tap.bind { [unowned self] _ in
            guard self.tokenInfo.isGateway else { return }
            let vc = GateWayDetailViewController.init(tokenInfo: self.tokenInfo)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: rx.disposeBag)
    }

    func bind() {
        navView.bind(tokenInfo: tokenInfo)

        tableView.rx.contentOffset
            .map { max(min($0.y, 64.0), 0.0) / 64.0 }
            .bind(to: titleLabel.rx.alpha)
            .disposed(by: rx.disposeBag)
    }
}
