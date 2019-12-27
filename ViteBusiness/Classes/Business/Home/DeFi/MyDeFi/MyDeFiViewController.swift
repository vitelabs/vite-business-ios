//
//  MyDeFiViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2019/12/2.
//

import UIKit
import ActionSheetPicker_3_0
import ViteWallet
import RxSwift
import RxCocoa

class MyDeFiViewController: BaseViewController {

    private let loanHeaderView = MyDeFiLoanHeaderView()
    private let subscribeHeaderView = MyDeFiSubscribeHeaderView()

    private let loanVC = MyDeFiLoanViewController()
    private let subscribeVC = MyDeFiSubscribeViewController()

    private var isLoan = true

    private lazy var manager: DNSPageViewManager = {
        let pageStyle = DNSPageStyle()
        pageStyle.isShowBottomLine = true
        pageStyle.isTitleViewScrollEnabled = true
        pageStyle.titleViewBackgroundColor = .clear
        pageStyle.titleSelectedColor = Colors.titleGray
        pageStyle.titleColor = Colors.titleGray_61
        pageStyle.titleFont = Fonts.Font13
        pageStyle.bottomLineColor = Colors.blueBg
        pageStyle.bottomLineHeight = 2
        pageStyle.bottomLineWidth = 20

        let titles = [
            R.string.localizable.defiMyPageMyLoanTitle(),
            R.string.localizable.defiMyPageMySubscribeTitle()
        ]

        let viewControllers = [
            self.loanVC,
            self.subscribeVC
        ]

        return DNSPageViewManager(style: pageStyle, titles: titles, childViewControllers: viewControllers)
    }()

    let filtrateButton = UIButton().then {
        $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)
        $0.setImage(R.image.icon_defi_home_down_button(), for: .normal)
        $0.setImage(R.image.icon_defi_home_down_button()?.highlighted, for: .highlighted)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        $0.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.titleLabel?.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: -1)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 7)
        $0.backgroundColor = UIColor(netHex: 0x007AFF, alpha: 0.06)
        $0.setTitle("ffff", for: .normal)
    }

    lazy var filtrateView = UIView().then {
        
        $0.addSubview(self.manager.titleView)
        self.manager.titleView.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.equalToSuperview().offset(24 - 15)
            m.right.equalToSuperview().offset(-24)
            m.bottom.equalToSuperview()
            m.height.equalTo(35)
        }

        $0.addSubview(self.filtrateButton)
        self.filtrateButton.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.height.equalTo(28)
            m.right.equalToSuperview().offset(-24)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ViteBalanceInfoManager.instance.registerFetch(tokenCodes: MyTokenInfosService.instance.tokenCodes)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ViteBalanceInfoManager.instance.unregisterFetch(tokenCodes: MyTokenInfosService.instance.tokenCodes)
    }

    private func setupView() {
        self.view.backgroundColor = .white
        navigationTitleView = NavigationTitleView(title: R.string.localizable.defiMyPageTitle())

        view.addSubview(loanHeaderView)
        loanHeaderView.snp.makeConstraints { (m) in
            m.top.equalTo(navigationTitleView!.snp.bottom)
            m.left.right.equalToSuperview().inset(24)
        }

        view.addSubview(subscribeHeaderView)
        subscribeHeaderView.snp.makeConstraints { (m) in
            m.edges.equalTo(loanHeaderView)
        }

        view.addSubview(filtrateView)
        filtrateView.snp.makeConstraints { (m) in
            m.top.equalTo(loanHeaderView.snp.bottom).offset(8)
            m.left.right.equalToSuperview()
        }

        view.addSubview(manager.contentView)
        manager.contentView.snp.makeConstraints { (make) in
            make.top.equalTo(filtrateView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom)
        }
    }

    private func bind() {
        pageChanged()
        manager.contentView.delegate = self
        manager.titleView.clickHandler = { [weak self] (titleView, index) in
            self?.isLoan = (index == 0)
            self?.pageChanged()
        }

        ViteBalanceInfoManager.instance.defiViteBalanceInfoDriver()
            .map { $0.baseAccount.available.amountShortStringForDeFiWithGroupSeparator(decimals: ViteWalletConst.viteToken.decimals) }
            .drive(loanHeaderView.accountLabel.rx.text).disposed(by: rx.disposeBag)
        ViteBalanceInfoManager.instance.defiViteBalanceInfoDriver().map { $0.loanAccount.available.amountShortStringForDeFiWithGroupSeparator(decimals: ViteWalletConst.viteToken.decimals) }.drive(loanHeaderView.loanLabel.rx.text).disposed(by: rx.disposeBag)

        filtrateButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }


            let statuss: [DeFiAPI.ProductStatus]
            let currentStatus: DeFiAPI.ProductStatus
            if self.isLoan {
                statuss = [.all, .onSale, .failed, .success, .cancel]
                currentStatus = self.loanVC.status
            } else {
                statuss = [.all, .onSale, .failed, .success]
                currentStatus = self.subscribeVC.status
            }

            var index = 0
            for (i, s) in statuss.enumerated() where s == currentStatus {
                index = i
            }
            _ =  ActionSheetStringPicker.show(withTitle: R.string.localizable.defiHomePageSortTitle(), rows: statuss.map({ $0.name }), initialSelection: index, doneBlock: {[weak self] _, index, _ in
                guard let `self` = self else { return }
                let status = statuss[index]
                guard status != currentStatus else { return }
                self.filtrateButton.setTitle(status.name, for: .normal)
                if self.isLoan {
                    self.loanVC.status = status
                } else {
                    self.subscribeVC.status = status
                }
            }, cancel: { _ in return }, origin: self.view)
        }.disposed(by: rx.disposeBag)

        subscribeVC.viewModel.profitsDriver.drive(onNext: {[weak self] (profits) in
            guard let `self` = self else { return }
            let decimals = ViteWalletConst.viteToken.decimals
            self.subscribeHeaderView.issuedLabel.text = profits.earnProfits.amountShortStringForDeFiWithGroupSeparator(decimals: decimals)
            self.subscribeHeaderView.predictLabel.text = profits.totalProfits.amountShortStringForDeFiWithGroupSeparator(decimals: decimals)
            self.subscribeHeaderView.subscribeLabel.text = profits.subscribedAmount.amountShortStringForDeFiWithGroupSeparator(decimals: decimals)
            self.subscribeHeaderView.rateLabel.text = profits.profitsRateString
        }).disposed(by: rx.disposeBag)

        Observable<Int>.interval(0.1, scheduler: MainScheduler.instance).bind { [weak self] (_) in
            guard let `self` = self else { return }
            let date = Date()
            for cell in self.loanVC.tableView.visibleCells {
                if let c = cell as? MyDeFiLoanCell {
                    c.updateEndTime(date: date)
                }
            }
            for cell in self.subscribeVC.tableView.visibleCells {
                if let c = cell as? MyDeFiSubscribeCell {
                    c.updateEndTime(date: date)
                }
            }
        }.disposed(by: rx.disposeBag)
    }

    private func pageChanged() {
        let status: DeFiAPI.ProductStatus
        if isLoan {
            loanHeaderView.isHidden = false
            subscribeHeaderView.isHidden = true
            status = loanVC.status
        } else {
            loanHeaderView.isHidden = true
            subscribeHeaderView.isHidden = false
            status = subscribeVC.status
        }

        filtrateButton.setTitle(status.name, for: .normal)
    }
}

extension MyDeFiViewController: DNSPageContentViewDelegate {
    func contentView(_ contentView: DNSPageContentView, didEndScrollAt index: Int) {
        self.manager.titleView.contentView(contentView, didEndScrollAt: index)
        for (i, label) in self.manager.titleView.titleLabels.enumerated() {
            if i == index {
                label.textColor = self.manager.titleView.style.titleSelectedColor
            } else {
                label.textColor = self.manager.titleView.style.titleColor
            }
        }
        self.isLoan = (index == 0)
        self.pageChanged()
    }

    func contentView(_ contentView: DNSPageContentView, scrollingWith sourceIndex: Int, targetIndex: Int, progress: CGFloat) {
        self.manager.titleView.contentView(contentView, scrollingWith: sourceIndex, targetIndex: targetIndex, progress: progress)
    }
}

extension DeFiAPI.ProductStatus {
    var name: String {
        switch self {
        case .all:
            return R.string.localizable.defiMyPageMyLoanSortAll()
        case .onSale:
            return R.string.localizable.defiMyPageMyLoanSortOnSale()
        case .failed:
            return R.string.localizable.defiMyPageMyLoanSortFailed()
        case .success:
            return R.string.localizable.defiMyPageMyLoanSortSuccess()
        case .cancel:
            return R.string.localizable.defiMyPageMyLoanSortCancel()
        }
    }
}
