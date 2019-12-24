//
//  DeFiLoanDetailViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2019/12/6.
//

import UIKit
import ViteWallet
import RxSwift
import RxCocoa
import NSObject_Rx

class DeFiLoanDetailViewController: BaseScrollableViewController {

    let productHash: String
    var loan: DeFiLoan? {
        didSet {
            self.reloadView()
        }
    }

    init(productHash: String) {
        self.productHash = productHash
        super.init()
    }

    init(loan: DeFiLoan) {
        self.productHash = loan.productHash
        self.loan = loan
        super.init()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        refresh()
        viewUseButton.rx.tap.bind {[unowned self] _ in
            let usage = DefiUsageViewController()
            usage.productHash = self.productHash
            self.navigationController?.pushViewController(usage, animated: true)
        }.disposed(by: rx.disposeBag)
    }

    var a = false
    override func viewDidAppear(_ animated: Bool) {
        if a == true { return }
        a = true
        super.viewDidAppear(animated)
        let usage = DefiUsageViewController()
        usage.productHash = productHash
        navigationController?.pushViewController(usage, animated: true)
    }

    func refresh() {
        if self.loan == nil {
            self.dataStatus = .loading
        }
        UnifyProvider.defi.getProductDetail(hash: productHash).done { [weak self] (loan) in
            guard let `self` = self else { return }
            self.loan = loan
            if self.loan == nil {
                self.dataStatus = .normal
            }
        }.catch { [weak self] (error) in
            guard let `self` = self else { return }
            if self.loan == nil {
                self.dataStatus = .networkError(error, {[weak self] in
                    guard let `self` = self else { return }
                    self.refresh()
                })
            } else {
                Toast.show(error.localizedDescription)
            }
        }
    }

    // failed
    let token = ViteWalletConst.viteToken
    let titleView = NavigationTitleView(title: R.string.localizable.defiLoanDetailPageTitle(), horizontal: 0)
    let header = DeFiProductInfoCard.init(title: R.string.localizable.defiCardSlogan(),
                                          status: .none,
                                          porgressDesc: "\(R.string.localizable.defiCardProgress())--%", progress: 0)

    lazy var idView = SendStaticItemView(title: R.string.localizable.defiItemIdTitle(), rightViewStyle: .label(style: .text(string: "--")))
    lazy var loanAmountView = SendStaticItemView(title: R.string.localizable.defiItemLoanAmountTitle(), rightViewStyle: .label(style: .attributed(string: DeFiFormater.value("--", unit: self.token.symbol))))
    lazy var eachAmountView = SendStaticItemView(title: R.string.localizable.defiItemEachAmountTitle(), rightViewStyle: .label(style: .attributed(string: DeFiFormater.value("--", unit: self.token.symbol))))
    lazy var loanDurationView = SendStaticItemView(title: R.string.localizable.defiItemLoanDurationTitle(), rightViewStyle: .labels(topStyle: .attributed(string: DeFiFormater.loanDuration(text: "--")), bottomStyle: .text(string: R.string.localizable.defiSubscriptionPageDurationBlock("--"))))
    lazy var dayRateView = SendStaticItemView(title: R.string.localizable.defiItemDayRateTitle(), rightViewStyle: .label(style: .text(string: "--%")))
    lazy var paidInterestView = SendStaticItemView(title: R.string.localizable.defiItemPaidInterestTitle(), rightViewStyle: .label(style: .attributed(string: DeFiFormater.value("--", unit: self.token.symbol))))
    lazy var subscriptionDurationView = SendStaticItemView(title: R.string.localizable.defiItemSubscriptionDurationTitle(), rightViewStyle: .label(style: .attributed(string: DeFiFormater.subscriptionDuration(text: "--"))))
    lazy var subscribeAmountView = SendStaticItemView(title: R.string.localizable.defiItemSubscribeAmountTitle(), rightViewStyle: .label(style: .attributed(string: DeFiFormater.value("--", unit: self.token.symbol))))
    lazy var refundPaidInterestView = SendStaticItemView(title: R.string.localizable.defiItemRefundPaidInterestTitle(), rightViewStyle: .label(style: .attributed(string: DeFiFormater.value("--", unit: self.token.symbol))))
    lazy var publishTimeView = SendStaticItemView(title: R.string.localizable.defiItemPublishTimeTitle(), rightViewStyle: .label(style: .text(string: "--")))

    let reloanButton = UIButton(style: .blueWithShadow, title: R.string.localizable.defiLoanDetailPageFailedButtonReloanTitle())
    let refundButton = UIButton(style: .whiteWithShadow, title: R.string.localizable.defiLoanDetailPageFailedButtonViewRefundTitle())
    lazy var failedButtonView = UIView().then {
        $0.addSubview(self.refundButton)
        $0.addSubview(self.reloanButton)

        self.refundButton.snp.makeConstraints { (m) in
            m.top.bottom.left.equalToSuperview()
        }

        self.reloanButton.snp.makeConstraints { (m) in
            m.top.bottom.right.equalToSuperview()
            m.width.equalTo(self.refundButton)
            m.left.equalTo(self.refundButton.snp.right).offset(24)
        }
    }

    let failedTip1 = TipTextView(text: R.string.localizable.defiLoanDetailPageFailedTip1())


    // on sale
    lazy var loanCopysView = SendStaticItemView(title: R.string.localizable.defiItemLoanCopysTitle(), rightViewStyle: .label(style: .attributed(string: DeFiFormater.value("--", unit:R.string.localizable.defiItemCopysUnit()))))
    let cancelButton = UIButton(style: .blueWithShadow, title: R.string.localizable.defiLoanDetailPageOnSaleButtonCancelTitle())

    let onSaleTip1 = TipTextView(text: R.string.localizable.defiLoanDetailPageOnSaleTip1())
    let onSaleTip2 = TipTextView(text: R.string.localizable.defiLoanDetailPageOnSaleTip2())
    let onSaleTip3 = TipTextView(text: R.string.localizable.defiLoanDetailPageOnSaleTip3())
    let onSaleTip4 = TipTextView(text: R.string.localizable.defiLoanDetailPageOnSaleTip4())

    // success
    lazy var successTimeView = SendStaticItemView(title: R.string.localizable.defiItemSuccessTimeTitle(), rightViewStyle: .label(style: .text(string: "--")))
    lazy var usedAmountView = SendStaticItemView(title: R.string.localizable.defiItemUsedAmountTitle(), rightViewStyle: .label(style: .attributed(string: DeFiFormater.value("--", unit: self.token.symbol))))
    lazy var canUseAmountView = SendStaticItemView(title: R.string.localizable.defiItemCanUseAmountTitle(), rightViewStyle: .label(style: .attributed(string: DeFiFormater.value("--", unit: self.token.symbol))))
    lazy var endHeightView = SendStaticItemView(title: R.string.localizable.defiItemEndSnapshootHeightTitle(), rightViewStyle: .label(style: .text(string: "--")))
    lazy var endTimeView = SendStaticItemView(title: R.string.localizable.defiItemEndTimeTitle(), rightViewStyle: .label(style: .text(string: "--")))

    let useButton = UIButton(style: .blueWithShadow, title: R.string.localizable.defiLoanDetailPageSuccessButtonUseTitle())
    let viewUseButton = UIButton(style: .whiteWithShadow, title: R.string.localizable.defiLoanDetailPageSuccessButtonViewUseTitle())
    lazy var successButtonView = UIView().then {
        $0.addSubview(self.useButton)
        $0.addSubview(self.viewUseButton)

        self.useButton.snp.makeConstraints { (m) in
            m.top.bottom.left.equalToSuperview()
        }

        self.viewUseButton.snp.makeConstraints { (m) in
            m.top.bottom.right.equalToSuperview()
            m.width.equalTo(self.useButton)
            m.left.equalTo(self.useButton.snp.right).offset(24)
        }
    }

    let successTip1 = TipTextView(text: R.string.localizable.defiLoanDetailPageSuccessTip1())

    func setupView() {

        setNavTitle(title: R.string.localizable.defiLoanDetailPageTitle(), bindTo: scrollView)
        scrollView.mj_header = RefreshHeader(refreshingBlock: { [weak self] in
            guard let `self` = self else { return }
            UnifyProvider.defi.getProductDetail(hash: self.productHash).ensure {
                self.scrollView.mj_header.endRefreshing()
            }.done { (loan) in
                self.loan = loan
            }.catch { (error) in
               Toast.show(error.localizedDescription)
            }
        })

        scrollView.alwaysBounceVertical = true
        reloadView()

        Observable<Int>.interval(0.1, scheduler: MainScheduler.instance).bind { [weak self] (_) in
            guard let loan = self?.loan else { return }
            guard loan.productStatus == .onSale else { return }
            self?.updateHeader()

        }.disposed(by: rx.disposeBag)
    }

    func updateHeader() {
        guard let loan = self.loan else { return }
        let attributedString: NSMutableAttributedString = {
            let (day, time) = loan.countDown(for: Date())
            let string = R.string.localizable.defiCardEndTime(day, time)
            let ret = NSMutableAttributedString(string: string)

            ret.addAttributes(
                text: string,
                attrs: [
                    NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x000000),
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)
            ])

            ret.addAttributes(
                text: day,
                attrs: [
                    NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x007AFF),
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)
            ])

            ret.addAttributes(
                text: time,
                attrs: [
                    NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x007AFF),
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold)
            ])

            return ret
        }()

        let status: DeFiProductInfoCard.Status
        switch loan.productStatus {
        case .onSale:
            status = .onSale
        case .failed:
            status = .failed
        case .success:
            status = .success
        case .cancel:
            status = .cancel
        }
        header.config(title: R.string.localizable.defiCardSlogan(), status: status,
                      progressDesc: "\(R.string.localizable.defiCardProgress())\(loan.loanCompletenessString)",
            progress: CGFloat(loan.loanCompleteness), deadLineDesc: loan.productStatus == .onSale ? attributedString : nil)
    }

    func reloadView() {

        let views = scrollView.stackView.arrangedSubviews
        views.forEach { $0.removeFromSuperview() }

        guard let loan = self.loan else { return }
        updateHeader()
        switch loan.productStatus {
        case .onSale:
            header.snp.remakeConstraints { $0.height.equalTo(header.size.height) }
            scrollView.stackView.addArrangedSubview(titleView)
            scrollView.stackView.addArrangedSubview(header)
            scrollView.stackView.addArrangedSubview(idView, topInset: 20)
            scrollView.stackView.addArrangedSubview(loanAmountView, topInset: 20)
            scrollView.stackView.addArrangedSubview(eachAmountView, topInset: 20)
            scrollView.stackView.addArrangedSubview(loanCopysView, topInset: 20)
            scrollView.stackView.addArrangedSubview(loanDurationView, topInset: 20)
            scrollView.stackView.addArrangedSubview(dayRateView, topInset: 20)
            scrollView.stackView.addArrangedSubview(paidInterestView, topInset: 20)
            scrollView.stackView.addArrangedSubview(subscriptionDurationView, topInset: 20)
            scrollView.stackView.addArrangedSubview(subscribeAmountView, topInset: 20)
            scrollView.stackView.addArrangedSubview(publishTimeView, topInset: 20)
            if loan.subscribedAmount == 0 {
                scrollView.stackView.addArrangedSubview(cancelButton, topInset: 26)
            }
            scrollView.stackView.addArrangedSubview(onSaleTip1, topInset: 14)
            scrollView.stackView.addArrangedSubview(onSaleTip2, topInset: 4)
            scrollView.stackView.addArrangedSubview(onSaleTip3, topInset: 4)
            scrollView.stackView.addArrangedSubview(onSaleTip4, topInset: 4)
            scrollView.stackView.addPlaceholder(height: 26)
        case .failed, .cancel:
            header.snp.remakeConstraints { $0.height.equalTo(header.size.height) }
            scrollView.stackView.addArrangedSubview(titleView)
            scrollView.stackView.addArrangedSubview(header)
            scrollView.stackView.addArrangedSubview(idView, topInset: 20)
            scrollView.stackView.addArrangedSubview(loanAmountView, topInset: 20)
            scrollView.stackView.addArrangedSubview(eachAmountView, topInset: 20)
            scrollView.stackView.addArrangedSubview(loanDurationView, topInset: 20)
            scrollView.stackView.addArrangedSubview(dayRateView, topInset: 20)
            scrollView.stackView.addArrangedSubview(paidInterestView, topInset: 20)
            scrollView.stackView.addArrangedSubview(subscriptionDurationView, topInset: 20)
            scrollView.stackView.addArrangedSubview(subscribeAmountView, topInset: 20)
            scrollView.stackView.addArrangedSubview(refundPaidInterestView, topInset: 20)
            scrollView.stackView.addArrangedSubview(publishTimeView, topInset: 20)
            scrollView.stackView.addArrangedSubview(failedButtonView, topInset: 26)
            scrollView.stackView.addArrangedSubview(failedTip1, topInset: 14)
            scrollView.stackView.addPlaceholder(height: 26)
        case .success:
            header.snp.remakeConstraints { $0.height.equalTo(header.size.height) }
            scrollView.stackView.addArrangedSubview(titleView)
            scrollView.stackView.addArrangedSubview(header)
            scrollView.stackView.addArrangedSubview(idView, topInset: 20)
            scrollView.stackView.addArrangedSubview(publishTimeView, topInset: 20)
            scrollView.stackView.addArrangedSubview(successTimeView, topInset: 20)
            scrollView.stackView.addArrangedSubview(loanAmountView, topInset: 20)
            scrollView.stackView.addArrangedSubview(eachAmountView, topInset: 20)
            scrollView.stackView.addArrangedSubview(loanCopysView, topInset: 20)
            scrollView.stackView.addArrangedSubview(loanDurationView, topInset: 20)
            scrollView.stackView.addArrangedSubview(dayRateView, topInset: 20)
            scrollView.stackView.addArrangedSubview(subscriptionDurationView, topInset: 20)
            scrollView.stackView.addArrangedSubview(paidInterestView, topInset: 20)
            scrollView.stackView.addArrangedSubview(usedAmountView, topInset: 20)
            scrollView.stackView.addArrangedSubview(canUseAmountView, topInset: 20)
            scrollView.stackView.addArrangedSubview(endHeightView, topInset: 20)
            scrollView.stackView.addArrangedSubview(endTimeView, topInset: 20)
            scrollView.stackView.addArrangedSubview(successButtonView, topInset: 26)
            scrollView.stackView.addArrangedSubview(successTip1, topInset: 14)
            scrollView.stackView.addPlaceholder(height: 26)
        }

        idView.rightLabel?.text = loan.productHash
        loanAmountView.rightLabel?.attributedText = DeFiFormater.amount(loan.loanAmount, token: token)
        eachAmountView.rightLabel?.attributedText = DeFiFormater.amount(loan.singleCopyAmount, token: token)
        loanDurationView.rightTopBottomLabelsView?.topLabel.attributedText = DeFiFormater.loanDuration(text: String(loan.loanDuration))
        loanDurationView.rightTopBottomLabelsView?.bottomLabel.text = R.string.localizable.defiSubscriptionPageDurationBlock(String(loan.loanSnapshotCount))
        dayRateView.rightLabel?.text = loan.dayRateString
        paidInterestView.rightLabel?.attributedText = DeFiFormater.amount(loan.loanPayable, token: token)
        subscriptionDurationView.rightLabel?.attributedText = DeFiFormater.subscriptionDuration(text: String(loan.subscriptionDuration))
        subscribeAmountView.rightLabel?.attributedText = DeFiFormater.amount(loan.subscribedAmount, token: token)
        refundPaidInterestView.rightLabel?.attributedText = DeFiFormater.amount(loan.loanPayable, token: token)
        publishTimeView.rightLabel?.text = loan.subscriptionBeginTimeString

        refundButton.isEnabled = loan.refundStatus != .refunding
        refundButton.setTitle(loan.refundStatus != .refunding ?
            R.string.localizable.defiLoanDetailPageFailedButtonViewRefundTitle() :
            R.string.localizable.defiLoanDetailPageFailedButtonRefundingTitle(), for: .normal)

        loanCopysView.rightLabel?.attributedText = DeFiFormater.value(String(loan.subscriptionCopies), unit: R.string.localizable.defiItemCopysUnit())

        successTimeView.rightLabel?.text = loan.subscriptionFinishTimeString
        usedAmountView.rightLabel?.attributedText = DeFiFormater.amount(loan.loanUsedAmount, token: token)
        canUseAmountView.rightLabel?.attributedText = DeFiFormater.amount(loan.remainAmount, token: token)
        endHeightView.rightLabel?.text = String(loan.loanEndSnapshotHeight)
        endTimeView.rightLabel?.text = loan.loanEndTimeString
        useButton.isEnabled = !loan.isExpire
        viewUseButton.isEnabled = loan.isUsed
    }
}

extension DeFiLoanDetailViewController: ViewControllerDataStatusable {
    public func networkErrorView(error: Error, retry: @escaping () -> Void) -> UIView {
        return UIView.defaultNetworkErrorView(error: error) {
            retry()
        }
    }
}
