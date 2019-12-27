//
//  MyDeFiBillViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2019/12/3.
//

import UIKit
import ActionSheetPicker_3_0

class MyDeFiBillViewController: BaseViewController {

    var initStatus: DeFiAPI.Bill.BillType?

    private let baseAccountHeadeView = MyDeFiSubscribeHeaderView().then {
        $0.issuedTitleLabel.text = R.string.localizable.defiBillPageBasedbalance()
        $0.issuedLabel.text = "-- VITE"

        $0.predictTitleLabel.text = " "
        $0.predictLabel.text = " "

        $0.subscribeTitleLabel.text  = R.string.localizable.defiFrozenedAmountTitle()
        $0.subscribeLabel.text = "-- VITE"

        $0.rateTitleLabel.text = R.string.localizable.defiBillPageUsedBasedbalance()
        $0.rateLabel.text = "-- VITE"

    }

    private let loanHeaderView = MyDeFiLoanHeaderView().then {
        $0.accountButton.isHidden = true
        $0.loanButton.isHidden = true
        $0.accountTitleLabel.text = R.string.localizable.defiBillPageBorrowmoneybalances()
        $0.loanTitleLabel.text = R.string.localizable.defiBillPageTotalamountofborrowedmoney()
    }

    private let loanVC = DeFiBillBaseFundViewController()
    private let subscribeVC = DeFiBillBorrowedFundViewController()

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
            R.string.localizable.defiMyPageMyLoanAccountAmount(),
            R.string.localizable.defiMyPageMyLoanLoanAmount(),
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
        if let initStatus = self.initStatus {
            loanVC.status = initStatus
            self.filtrateButton.setTitle(initStatus.name, for: .normal)
        }
    }

    private func setupView() {
        self.view.backgroundColor = .white
        navigationTitleView = NavigationTitleView(title:R.string.localizable.defiBillPageTitle())

        view.addSubview(baseAccountHeadeView)
        baseAccountHeadeView.snp.makeConstraints { (m) in
            m.top.equalTo(navigationTitleView!.snp.bottom)
            m.left.right.equalToSuperview().inset(24)
        }

        view.addSubview(loanHeaderView)
        loanHeaderView.snp.makeConstraints { (m) in
            m.edges.equalTo(baseAccountHeadeView)
        }

        view.addSubview(filtrateView)
        filtrateView.snp.makeConstraints { (m) in
            m.top.equalTo(baseAccountHeadeView.snp.bottom).offset(8)
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


        filtrateButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }

            let statuss: [DeFiAPI.Bill.BillType]
            let currentStatus: DeFiAPI.Bill.BillType
            if self.isLoan {
                statuss = [.全部, .已付利息, /*.已付利息退款, */.认购金额, .到期认购金额, .认购收益, .认购金额退款, .注册SBP, .注册SBP退款, .开通交易所SVIP, .开通交易所SVIP退款, .获取配额, .获取配额退款, .抵押挖矿, .抵押挖矿退款, .划转收入, .划转支出]
                currentStatus = self.loanVC.status
            } else {
                statuss = [.全部,  .注册SBP, .注册SBP退款, .开通交易所SVIP, .开通交易所SVIP退款, .获取配额, .获取配额退款, .抵押挖矿, .抵押挖矿退款, .成功借币, .借币到期还款]
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

        ViteBalanceInfoManager.instance.defiBalanceInfosDriver.drive(onNext: { [weak self] (infoMap) in
            guard let `self` = self else { return }
            guard let info = infoMap[TokenInfo.BuildIn.vite.value.id] else {
                return
            }
            let baseStr = info.baseAccount.available.amountShort(decimals: TokenInfo.BuildIn.vite.value.decimals)
            let frozedStr = (info.baseAccount.subscribed + info.baseAccount.locked).amountShort(decimals: TokenInfo.BuildIn.vite.value.decimals)
            let usedStr = info.baseAccount.invested.amountShort(decimals: TokenInfo.BuildIn.vite.value.decimals)
            self.baseAccountHeadeView.issuedLabel.text = baseStr + " VITE"
            self.baseAccountHeadeView.subscribeLabel.text = frozedStr + " VITE"
            self.baseAccountHeadeView.rateLabel.text = usedStr + " VITE"

            let loanBalanceStr = (info.loanAccount.available).amountShort(decimals: TokenInfo.BuildIn.vite.value.decimals)
            let loanTotalStr = (info.loanAccount.invested + info.loanAccount.available).amountShort(decimals: TokenInfo.BuildIn.vite.value.decimals)
            self.loanHeaderView.accountLabel.text = loanBalanceStr + " VITE"
            self.loanHeaderView.loanLabel.text = loanTotalStr + " VITE"

        })
    }

    private func pageChanged() {
        let status: DeFiAPI.Bill.BillType
        if isLoan {
            baseAccountHeadeView.isHidden = false
            loanHeaderView.isHidden = true
            status = loanVC.status
        } else {
            baseAccountHeadeView.isHidden = true
            loanHeaderView.isHidden = false
            status = subscribeVC.status
        }

        filtrateButton.setTitle(status.name, for: .normal)
    }
}

extension MyDeFiBillViewController: DNSPageContentViewDelegate {
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

extension DeFiAPI.Bill.BillType {

    var itemName: String {
        switch self {
        case .全部:
            return "Unknow Type"
        default:
            return self.name;
        }
    }
    var name: String {
        switch self {
        case .全部:
            return R.string.localizable.defiBillBillTypeTitleAll()
        case .已付利息:
            return R.string.localizable.defiBillBillTypeTitlePaiedInterest()
//        case .已付利息退款:
//            return R.string.localizable.defiBillBillTypeTitleRefundOfinterestPaid()
        case .认购金额:
            return R.string.localizable.defiBillBillTypeTitleSubscriptionAmount()
        case .到期认购金额:
            return R.string.localizable.defiBillBillTypeTitleSubscriptionAmountDue()
        case .认购收益:
            return R.string.localizable.defiBillBillTypeTitleSubscriptionRevenuee()
        case .认购金额退款:
            return R.string.localizable.defiBillBillTypeTitleRefundofsubscriptionamount()
        case .注册SBP:
            return R.string.localizable.defiBillBillTypeTitleRegisteredSBP()
        case .注册SBP退款:
            return R.string.localizable.defiBillBillTypeTitleRegisterforSBPrefund()
        case .开通交易所SVIP:
            return R.string.localizable.defiBillBillTypeTitleOpenSVIPexchange()
        case .开通交易所SVIP退款:
            return R.string.localizable.defiBillBillTypeTitleOpenexchangeSVIPrefund()
        case .获取配额:
            return R.string.localizable.defiBillBillTypeTitleGetquota()
        case .获取配额退款:
            return R.string.localizable.defiBillBillTypeTitleQuotarefund()
        case .抵押挖矿:
            return R.string.localizable.defiBillBillTypeTitleMinning()
        case .抵押挖矿退款:
            return  R.string.localizable.defiBillBillTypeTitleMinningrefund()
        case .划转收入:
            return R.string.localizable.defiBillBillTypeTitleTransferincome()
        case .划转支出:
            return R.string.localizable.defiBillBillTypeTitleTransferspending()
        case .成功借币:
            return R.string.localizable.defiBillBillTypeTitleSuccessborrowmoney()
        case .借币到期还款:
            return R.string.localizable.defiBillBillTypeTitleLoanisdueforrepayment()
        }
    }
}
