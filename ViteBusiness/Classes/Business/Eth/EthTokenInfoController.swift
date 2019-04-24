//
//  EthTokenInfoController.swift
//  ViteBusiness
//
//  Created by Water on 2019/2/21.
//

import Foundation
import ViteWallet
import SnapKit
import RxSwift
import RxCocoa
import NSObject_Rx
import ViteEthereum
import web3swift
import BigInt

class EthTokenInfoController: BaseViewController {
    var tokenInfo : TokenInfo

    init(_ tokenInfo: TokenInfo) {
        self.tokenInfo = tokenInfo
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ETHBalanceInfoManager.instance.registerFetch(tokenInfos: [tokenInfo])
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ETHBalanceInfoManager.instance.unregisterFetch(tokenInfos: [tokenInfo])
    }

    func bind() {
        ETHBalanceInfoManager.instance.balanceInfoDriver(for: self.tokenInfo.tokenCode)
            .drive(onNext: { [weak self] ret in
                guard let `self` = self else { return }
                if let balanceInfo = ret {
                    self.ethInfoCardView.balanceLab.text = balanceInfo.balance.amountFull(decimals: self.tokenInfo.decimals)
                } else {
                    // no balanceInfo, set 0.0
                    self.ethInfoCardView.balanceLab.text = "0.0"
                }
            }).disposed(by: rx.disposeBag)

        //balance loop
        Driver<Any>.combineLatest(ExchangeRateManager.instance.rateMapDriver,ETHBalanceInfoManager.instance.balanceInfoDriver(for: self.tokenInfo.tokenCode).filterNil()).map({
            (map,balanceInfo) -> String in
            map.priceString(for: balanceInfo.tokenInfo, balance: balanceInfo.balance)
        }).drive(onNext: { [weak self] (ret) in
               guard let `self` = self else { return }
            self.ethInfoCardView.balanceLegalTenderLab.text = "≈" + ret
        }).disposed(by: rx.disposeBag)
    }

    private lazy var navView = BalanceInfoNavView().then { (navView) in
        view.insertSubview(navView, at: 0)
        navView.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.right.equalToSuperview()
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpTop).offset(128)
        }
        navView.bind(tokenInfo: tokenInfo)
    }

    private lazy var ethInfoCardView = EthInfoCardView(self.tokenInfo).then { (ethInfoCardView) in
        view.addSubview(ethInfoCardView)
        ethInfoCardView.snp.makeConstraints { (m) in
            m.top.equalTo(navView.snp.bottom).offset(-60)
            m.left.equalTo(view).offset(24)
            m.right.equalTo(view).offset(-24)
            m.height.equalTo(188)
        }
    }

    let bottomTitleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.numberOfLines = 1
        $0.text = R.string.localizable.transactionListPageTitle()
    }

    fileprivate func setupView() {
        view.addSubview(bottomTitleLabel)
        bottomTitleLabel.snp.makeConstraints { (m) in
            m.top.equalTo(ethInfoCardView.snp.bottom).offset(14)
            m.left.equalTo(24)
            m.height.equalTo(20)
        }

        let contentLayout = UILayoutGuide()
        let centerLayout = UILayoutGuide()

        view.addLayoutGuide(contentLayout)
        view.addLayoutGuide(centerLayout)

        contentLayout.snp.makeConstraints { (m) in
            m.left.right.equalTo(view)
            m.top.equalTo(ethInfoCardView.snp.bottom)
            m.bottom.equalTo(view)
        }

        centerLayout.snp.makeConstraints { (m) in
            m.left.right.equalTo(contentLayout)
            m.centerY.equalTo(contentLayout)
        }

        let imageView = UIImageView(image: R.image.empty())
        let showTransactionsButton = UIButton.init(type: .system).then {
            $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            $0.titleLabel?.numberOfLines = 0
            $0.titleLabel?.textAlignment = .center
            $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
            $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)
            $0.setTitle(R.string.localizable.balanceInfoDetailShowTransactionsButtonTitle(), for: .normal)
        }
        view.addSubview(imageView)
        view.addSubview(showTransactionsButton)

        if  UIScreen.main.bounds.size == CGSize(width: 320, height: 568) {
            imageView.snp.makeConstraints { (m) in
                m.top.equalTo(centerLayout)
                m.width.height.equalTo(0)
                m.centerX.equalTo(centerLayout)
            }
        }else {
            imageView.snp.makeConstraints { (m) in
                m.top.equalTo(centerLayout)
                m.width.height.equalTo(130)
                m.centerX.equalTo(centerLayout)
            }
        }

        showTransactionsButton.snp.makeConstraints { (m) in
            m.top.equalTo(imageView.snp.bottom).offset(20)
            m.bottom.equalTo(centerLayout)
            m.left.equalTo(centerLayout).offset(24)
            m.right.equalTo(centerLayout).offset(-24)
        }

        showTransactionsButton.rx.tap.bind { [weak self] in
            var infoUrl = String.init(format: "%@%@",EtherWallet.network.getEtherInfoH5Url(), EtherWallet.account.address ?? "")
            guard let url = URL(string: infoUrl) else { return }
            let vc = WKWebViewController.init(url: url)
            self?.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: rx.disposeBag)

        self.ethInfoCardView.receiveButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            let vc = ReceiveViewController(tokenInfo: self.tokenInfo)
            self.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: rx.disposeBag)

        self.ethInfoCardView.sendButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }

            let vc = EthSendTokenController(self.tokenInfo)
            self.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: rx.disposeBag)
    }
}

