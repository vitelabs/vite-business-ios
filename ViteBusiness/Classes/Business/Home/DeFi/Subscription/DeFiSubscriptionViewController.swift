//
//  DeFiSubscriptionViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2019/12/5.
//

import UIKit
import ViteWallet
import RxSwift
import RxCocoa
import NSObject_Rx
import PromiseKit

class DeFiSubscriptionViewController: BaseScrollableViewController {

    let token = ViteWalletConst.viteToken
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

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let titleView = NavigationTitleView(title: R.string.localizable.defiSubscriptionPageTitle(), horizontal: 0)
    let header = DeFiProductInfoCard.init(title: R.string.localizable.defiCardSlogan(),
                                          status: .none,
                                          porgressDesc: "\(R.string.localizable.defiCardProgress())--%", progress: 0, deadLineDesc: NSAttributedString.init(string: "--后结束认购"))

    lazy var idView = SendStaticItemView(title: R.string.localizable.defiSubscriptionPageIdTitle(), rightViewStyle: .label(style: .text(string: "--")))

    lazy var durationView = SendStaticItemView(title: R.string.localizable.defiSubscriptionPageDurationTitle(), rightViewStyle: .labels(topStyle: .attributed(string: self.updateDuration(text: "--")), bottomStyle: .text(string: R.string.localizable.defiSubscriptionPageDurationBlock("--"))))

    lazy var rateView = SendStaticItemView(title: R.string.localizable.defiSubscriptionPageYearRateTitle(), rightViewStyle: .label(style: .text(string: "--%")))
    lazy var loanAmountView = SendStaticItemView(title: R.string.localizable.defiSubscriptionPageLoanAmountTitle(), rightViewStyle: .label(style: .attributed(string: self.updateValue("--", unit: self.token.symbol))))
    lazy var eachAmountView = SendStaticItemView(title: R.string.localizable.defiSubscriptionPageEachAmountTitle(), rightViewStyle: .label(style: .attributed(string: self.updateValue("--", unit: self.token.symbol))))
    lazy var leftCopysView = SendStaticItemView(title: R.string.localizable.defiSubscriptionPageLeftCopysTitle(), rightViewStyle: .label(style: .attributed(string: self.updateValue("--", unit: R.string.localizable.defiSubscriptionPageLeftCopysUnit()))))

    lazy var subscriptionCopysView = SendTextFieldItemView(title: R.string.localizable.defiSubscriptionPageSubscriptionCopysTitle(), rightViewStyle: .label(style: .text(string: R.string.localizable.defiSubscriptionPageSubscriptionCopysUnit())))

    lazy var subscriptionAmountView = SendStaticItemView(title: R.string.localizable.defiSubscriptionPageSubscriptionAmountTitle(), rightViewStyle: .label(style: .attributed(string: self.updateValue("--", unit: self.token.symbol))))

    lazy var earningsView = SendStaticItemView(title: R.string.localizable.defiSubscriptionPageEarningsTitle(), rightViewStyle: .label(style: .attributed(string: self.updateValue("--/--", unit: self.token.symbol))))

    let subscriptionButton = UIButton(style: .blue, title: R.string.localizable.defiSubscriptionPageSubscriptionButtonTitle())

    let tip1View = TipTextView(text: R.string.localizable.defiSubscriptionPageTip1())
    let tip2View = TipTextView(text: R.string.localizable.defiSubscriptionPageTip2())
    let tip3View = TipTextView(text: R.string.localizable.defiSubscriptionPageTip3())
    let tip4View = TipTextView(text: R.string.localizable.defiSubscriptionPageTip4())

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        refresh()
        bind()
    }

    func refresh() {
        if self.loan == nil {
            self.dataStatus = .loading
        }

        UnifyProvider.defi.getOrRefreshProductDetailInChain(hash: self.productHash, loan: self.loan).done { [weak self] (loan) in
            guard let `self` = self else { return }
            if self.loan == nil {
                self.dataStatus = .normal
            }
            self.loan = loan
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        kas_activateAutoScrollingForView(scrollView)
    }

    func updateValue(_ value: String, unit: String) -> NSAttributedString {
        let string = "\(value) \(unit)"
        let ret = NSMutableAttributedString(string: string)

        ret.addAttributes(
            text: string,
            attrs: [
                NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59, alpha: 0.7),
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)
        ])

        ret.addAttributes(
            text: unit,
            attrs: [
                NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59, alpha: 0.45),
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)
        ])

        return ret
    }

    func updateDuration(text: String) -> NSAttributedString {
        let string = R.string.localizable.defiSubscriptionPageDurationUnit(
            R.string.localizable.defiSubscriptionPageDurationPre(),
            text,
            R.string.localizable.defiSubscriptionPageDurationSuf())
        let ret = NSMutableAttributedString(string: string)

        ret.addAttributes(
            text: string,
            attrs: [
                NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59, alpha: 0.7),
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)
        ])

        ret.addAttributes(
            text: R.string.localizable.defiSubscriptionPageDurationSuf(),
            attrs: [
                NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59, alpha: 0.45),
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)
        ])

        return ret
    }

    func setupView() {
        setNavTitle(title: R.string.localizable.defiSubscriptionPageTitle(), bindTo: scrollView)
        scrollView.mj_header = RefreshHeader(refreshingBlock: { [weak self] in
            guard let `self` = self else { return }
            UnifyProvider.defi.getOrRefreshProductDetailInChain(hash: self.productHash, loan: self.loan).ensure {
                self.scrollView.mj_header.endRefreshing()
            }.done { (loan) in
                self.loan = loan
            }.catch { (error) in
               Toast.show(error.localizedDescription)
            }
        })

        scrollView.alwaysBounceVertical = true

        scrollView.stackView.addArrangedSubview(titleView)
        scrollView.stackView.addArrangedSubview(header)
        header.snp.makeConstraints { (m) in
            m.height.equalTo(132)
        }
        scrollView.stackView.addPlaceholder(height: 20)
        scrollView.stackView.addArrangedSubview(idView)
        scrollView.stackView.addPlaceholder(height: 20)
        scrollView.stackView.addArrangedSubview(durationView)
        scrollView.stackView.addPlaceholder(height: 20)
        scrollView.stackView.addArrangedSubview(rateView)
        scrollView.stackView.addPlaceholder(height: 20)
        scrollView.stackView.addArrangedSubview(loanAmountView)
        scrollView.stackView.addPlaceholder(height: 20)
        scrollView.stackView.addArrangedSubview(eachAmountView)
        scrollView.stackView.addPlaceholder(height: 20)
        scrollView.stackView.addArrangedSubview(leftCopysView)
        scrollView.stackView.addPlaceholder(height: 20)
        scrollView.stackView.addArrangedSubview(subscriptionCopysView)
        scrollView.stackView.addPlaceholder(height: 20)
        scrollView.stackView.addArrangedSubview(subscriptionAmountView)
        scrollView.stackView.addPlaceholder(height: 20)
        scrollView.stackView.addArrangedSubview(earningsView)
        scrollView.stackView.addPlaceholder(height: 26)
        scrollView.stackView.addArrangedSubview(subscriptionButton)
        scrollView.stackView.addPlaceholder(height: 14)
        scrollView.stackView.addArrangedSubview(tip1View)
        scrollView.stackView.addPlaceholder(height: 4)
        scrollView.stackView.addArrangedSubview(tip2View)
        scrollView.stackView.addPlaceholder(height: 4)
        scrollView.stackView.addArrangedSubview(tip3View)
        scrollView.stackView.addPlaceholder(height: 4)
        scrollView.stackView.addArrangedSubview(tip4View)
        scrollView.stackView.addPlaceholder(height: 26)

        subscriptionCopysView.textField.keyboardType = .numberPad
        subscriptionCopysView.textField.kas_setReturnAction(.done(block: { (textField) in
            textField.resignFirstResponder()
        }))
        updateHeader()
        reloadView()
    }

    let subscriptionCopys: BehaviorRelay<UInt64?> = BehaviorRelay(value: nil)
    let totalAmount: BehaviorRelay<Amount?> = BehaviorRelay(value: nil)

    func bind() {

        Observable<Int>.interval(0.1, scheduler: MainScheduler.instance).bind { [weak self] (_) in
            guard let loan = self?.loan else { return }
            guard loan.productStatus == .onSale else { return }
            self?.updateHeader()

        }.disposed(by: rx.disposeBag)

        subscriptionCopysView.textField.rx.text.map { t -> UInt64? in
            guard let text = t, !text.isEmpty else { return nil }
            return UInt64(text)
        }.bind(to: subscriptionCopys).disposed(by: rx.disposeBag)

        subscriptionCopys.map { copys -> Amount? in
            if let copys = copys {
                guard let loan = self.loan else { return nil }
                return (loan.singleCopyAmount * Amount(copys))
            } else {
                return nil
            }
        }.bind(to: totalAmount).disposed(by: rx.disposeBag)

        totalAmount.bind { [weak self] (amount) in
            guard let `self` = self else { return }
            if let amount = amount {
                guard let loan = self.loan else { return }
                guard let rateBigInt = Amount(String(format: "%.0f", loan.dayRate*1000000)) else { return }
                let dayEarnings = amount * rateBigInt / Amount(1000000)
                let totalEarnings = dayEarnings * Amount(loan.loanDuration)
                let amountString = amount.amountShortStringForDeFiWithGroupSeparator(decimals: self.token.decimals)
                let dayEarningsString = dayEarnings.amountFullWithGroupSeparator(decimals: self.token.decimals)
                let totalEarningsString = totalEarnings.amountFullWithGroupSeparator(decimals: self.token.decimals)

                self.subscriptionAmountView.rightLabel?.attributedText = self.updateValue(amountString, unit: self.token.symbol)
                self.earningsView.rightLabel?.attributedText = self.updateValue("\(totalEarningsString)/\(dayEarningsString)", unit: self.token.symbol)
            } else {
                self.subscriptionAmountView.rightLabel?.attributedText = self.updateValue("--", unit: self.token.symbol)
                self.earningsView.rightLabel?.attributedText = self.updateValue("--/--", unit: self.token.symbol)
            }
        }.disposed(by: rx.disposeBag)

        subscriptionButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            guard let _ = self.canSubscription() else { return }

            UnifyProvider.defi.getOrRefreshProductDetailInChain(hash: self.productHash, loan: self.loan).done { [weak self] (loan) in
                guard let `self` = self else { return }
                self.loan = loan
                guard let copys = self.canSubscription() else { return }
                guard let account = HDWalletManager.instance.account else { return }
                Workflow.defiSubscribeWithConfirm(
                    account: account,
                    tokenInfo:TokenInfo.BuildIn.vite.value,
                    loanId: UInt64(self.productHash)!,
                    shares: copys) { [weak self] (result) in
                        guard let `self` = self else { return }
                        switch result {
                        case .success(_):
                            self.navigationController?.popViewController(animated: true)
                            Toast.show(R.string.localizable.defiSubscriptionPageSubscriptionSuccessToast())
                        case .failure(let e):
                            Toast.show(e.localizedDescription)
                        }
                }
            }.catch { (error) in
                Toast.show(error.localizedDescription)
            }
        }.disposed(by: rx.disposeBag)
    }

    func canSubscription() -> UInt64? {
        guard let loan = self.loan else { return nil }

        guard let copys = self.subscriptionCopys.value,
            let amount = self.totalAmount.value else {
            Toast.show(R.string.localizable.defiSubscriptionPageCellCopysErrorEmpty())
            return nil
        }

        guard copys > 0 else {
            Toast.show(R.string.localizable.defiSubscriptionPageCellCopysErrorTooSmall())
            return nil
        }

        guard copys <= loan.leftCopies else {
            Toast.show(R.string.localizable.defiSubscriptionPageCellCopysErrorTooBig())
            return nil
        }

        guard ViteBalanceInfoManager.instance.defiViteBalance().baseAccount.available >= amount else {
            Toast.show(R.string.localizable.defiSubscriptionPageCellAmountErrorNotEnough())
            return nil
        }

        return copys
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
        header.config(
            title: R.string.localizable.defiCardSlogan(),
            status: status,
            progressDesc: "\(R.string.localizable.defiCardProgress())\(loan.loanCompletenessString)",
            progress: CGFloat(loan.loanCompleteness),
            deadLineDesc: loan.productStatus == .onSale ? attributedString : nil)
    }

    func reloadView() {
        guard let loan = self.loan else { return }
        idView.rightLabel?.text = loan.productHash
        if let view = durationView.rightView as? TopBottomLabelsView {
            view.topLabel.attributedText = self.updateDuration(text: String(loan.loanDuration))
            view.bottomLabel.text = R.string.localizable.defiSubscriptionPageDurationBlock(String(loan.loanSnapshotCount))
        }
        rateView.rightLabel?.text = loan.yearRateString
        loanAmountView.rightLabel?.attributedText = self.updateValue(loan.loanAmount.amountShortStringForDeFiWithGroupSeparator(decimals: self.token.decimals), unit: self.token.symbol)
        eachAmountView.rightLabel?.attributedText = self.updateValue(loan.singleCopyAmount.amountShortStringForDeFiWithGroupSeparator(decimals: self.token.decimals), unit: self.token.symbol)
        leftCopysView.rightLabel?.attributedText = self.updateValue(String(loan.leftCopies), unit: R.string.localizable.defiSubscriptionPageLeftCopysUnit())
    }
}

extension DeFiSubscriptionViewController: ViewControllerDataStatusable {
    public func networkErrorView(error: Error, retry: @escaping () -> Void) -> UIView {
        return UIView.defaultNetworkErrorView(error: error) {
            retry()
        }
    }
}
