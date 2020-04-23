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
    var tokenInfo: TokenInfo? = nil
    var adapter: BalanceInfoDetailAdapter? = nil

    init(tokenInfo: TokenInfo) {
        super.init(nibName: nil, bundle: nil)
        self.tokenInfo = tokenInfo
        self.adapter = tokenInfo.createBalanceInfoDetailAdapter(headerView: headerView, tableView: tableView, vc: self)
    }

    var tokenCode: TokenCode? = nil
    init(tokenCode: TokenCode) {
        super.init(nibName: nil, bundle: nil)
        if let tokenInfo = TokenInfoCacheService.instance.tokenInfo(for: tokenCode) {
            self.tokenInfo = tokenInfo
            self.adapter = tokenInfo.createBalanceInfoDetailAdapter(headerView: headerView, tableView: tableView, vc: self)
        } else {
            self.tokenCode = tokenCode
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        view.backgroundColor = .white
        navigationBarStyle = .default

        if let tokenInfo = self.tokenInfo {
            setupView(tokenInfo: tokenInfo)
            bind(tokenInfo: tokenInfo)
        } else {
            getTokenInfo()
        }
    }

    private func getTokenInfo() {
        self.dataStatus = .loading
        TokenInfoCacheService.instance.tokenInfo(for: tokenCode!) { [weak self] (ret) in
            guard let `self` = self else { return }
            switch ret {
            case .success(let tokenInfo):

                if !GrinManager.default.walletCreated.value {
                    Toast.show(R.string.localizable.grinCreating())
                    self.dismiss()
                }

                self.dataStatus = .normal
                self.tokenInfo = tokenInfo
                self.adapter = tokenInfo.createBalanceInfoDetailAdapter(headerView: self.headerView, tableView: self.tableView, vc: self)
                self.setupView(tokenInfo: tokenInfo)
                self.bind(tokenInfo: tokenInfo)
                self.adapter?.viewDidAppear()
            case .failure(let error):
                self.dataStatus = .networkError(error, { [weak self] in
                    self?.getTokenInfo()
                })
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        adapter?.viewDidAppear()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        adapter?.viewDidDisappear()
    }

    func setupView(tokenInfo: TokenInfo) {

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
           NotificationCenter.default.post(name: .goTokenInfoVC, object: ["tokenCode": tokenInfo.tokenCode])
        }).disposed(by: rx.disposeBag)

        navView.gatewayInfoBtn.button.rx.tap.bind { _ in
            guard tokenInfo.isGateway else { return }
           NotificationCenter.default.post(name: .goGateWayVC, object: ["gateway": tokenInfo.gatewayInfo?.toJSONString()])
        }.disposed(by: rx.disposeBag)

        navView.helpButton.rx.tap.bind { _ in
            var url: URL!
            if LocalizationService.sharedInstance.currentLanguage == .chinese {
                url = URL(string: "https://forum.vite.net/topic/1335/grin%E7%94%A8%E6%88%B7%E4%BD%BF%E7%94%A8vite%E9%92%B1%E5%8C%85%E6%94%B6%E8%BD%AC%E8%B4%A6%E6%95%99%E7%A8%8B")
            } else {
                url = URL(string: "https://forum.vite.net/topic/1334/a-tutorial-about-how-to-send-receive-a-grin-on-vite-mobile-wallet")
            }
            let webvc = WKWebViewController(url: url)
            UIViewController.current?.navigationController?.pushViewController(webvc, animated: true)
            }
            .disposed(by: rx.disposeBag)
    }   

    func bind(tokenInfo: TokenInfo) {
        navView.bind(tokenInfo: tokenInfo)

        tableView.rx.contentOffset
            .map { max(min($0.y, 64.0), 0.0) / 64.0 }
            .bind(to: titleLabel.rx.alpha)
            .disposed(by: rx.disposeBag)
    }
}

//TODO...

//extension BalanceInfoDetailViewController {
//    var allowJumpTokenDetailPage: Bool {
//        switch tokenInfo.coinType {
//        case .vite:
//            return true
//        case .eth:
//            return !tokenInfo.isEtherCoin
//        case .grin:
//            return false
//        case .bnb:
//            return false
//        }
//    }
//}
extension BalanceInfoDetailViewController: ViewControllerDataStatusable {

    public func networkErrorView(error: Error, retry: @escaping () -> Void) -> UIView {
        return UIView.defaultNetworkErrorView(error: error) { [weak self] in
            self?.dataStatus = .loading
            retry()
        }
    }
}
