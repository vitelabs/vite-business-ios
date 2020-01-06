//
//  DeFiLoanViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2019/12/4.
//

import UIKit
import ViteWallet
import RxSwift
import RxCocoa

class DeFiLoanViewController: BaseScrollableViewController {

    let loan: DeFiLoan?
    init(loan: DeFiLoan? = nil) {
        self.loan = loan
        super.init()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let token = ViteWalletConst.viteToken

    let titleView = NavigationTitleView(title: R.string.localizable.defiLoanPageTitle(), horizontal: 0)

    let header = UIView().then {
        $0.backgroundColor =
        UIColor.gradientColor(style: .left2right,
        frame: CGRect(x: 0, y: 0, width: kScreenW - 24 * 2, height: 46),
        colors: [UIColor(netHex: 0xE3F0FF),
                 UIColor(netHex: 0xF2F8FF)])

        let iconImageView = UIImageView(image: R.image.icon_defi_home_cell_safe_flag())
        let label = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59)
            $0.text = R.string.localizable.defiLoanPageSlogan()
        }

        $0.addSubview(iconImageView)
        $0.addSubview(label)

        iconImageView.snp.makeConstraints { (m) in
            m.top.bottom.equalToSuperview().inset(12)
            m.left.equalToSuperview().offset(14)
            m.size.equalTo(CGSize(width: 22, height: 22))
        }

        label.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.left.equalTo(iconImageView.snp.right).offset(4)
        }
    }

    lazy var eachAmountView = SendTextFieldItemView(title: R.string.localizable.defiItemEachAmountTitle(), rightViewStyle: .label(style: .text(string: token.symbol))).then {
        $0.textField.placeholder = R.string.localizable.defiLoanPageCellEachAmountPlaceholder("10", self.token.symbol)
    }

    lazy var numberView = SendTextFieldItemView(title: R.string.localizable.defiLoanPageCellNumberTitle(), rightViewStyle: .label(style: .text(string: R.string.localizable.defiLoanPageCellNumberUnit()))).then {
        $0.textField.placeholder = R.string.localizable.defiLoanPageCellNumberPlaceholder()
    }

    lazy var totalAmountView = SendStaticItemView(title: R.string.localizable.defiLoanPageCellTotalAmountTitle(), rightViewStyle: .label(style: .attributed(string: attributedString(text: "--"))))

    let totalAmountTipView = TipTextView(text: R.string.localizable.defiLoanPageCellTotalAmountTip(), hasPoint: false)

    lazy var rateView = SendTextFieldItemView(title: R.string.localizable.defiLoanPageCellRateTitle(), rightViewStyle: .label(style: .text(string: "%")))

    lazy var durationView = DeFiLoanDurationItemView().then {
        $0.rightLabel.text = R.string.localizable.defiItemLoanDurationBlock("--")
    }
    let durationTipView = TipTextView(text: R.string.localizable.defiLoanPageCellDurationTip(), hasPoint: false)

    lazy var subscriptionTimeView = SendTextFieldItemView(title: R.string.localizable.defiLoanPageCellSubscriptionTimeTitle(), rightViewStyle: .label(style: .text(string: R.string.localizable.defiLoanPageCellSubscriptionTimeUnit()))).then {
        $0.textField.placeholder = "1-7"
    }

    lazy var interestView = SendStaticItemView(title: R.string.localizable.defiLoanPageCellInterestTitle(), rightViewStyle: .label(style: .attributed(string: attributedString(text: "--"))))

    let loanButton = UIButton(style: .blue, title: R.string.localizable.defiLoanPageLoanButtonTitle())

    let tip1View = TipTextView(text: R.string.localizable.defiLoanPageTip1())
    let tip2View = TipTextView(text: R.string.localizable.defiLoanPageTip2())
    let tip3View = TipTextView(text: R.string.localizable.defiLoanPageTip3())

    let eachAmount: BehaviorRelay<Amount?> = BehaviorRelay(value: nil)
    let number: BehaviorRelay<UInt64?> = BehaviorRelay(value: nil)
    let rate: BehaviorRelay<Decimal?> = BehaviorRelay(value: nil)
    let duration: BehaviorRelay<UInt64?> = BehaviorRelay(value: nil)
    let subscriptionTime: BehaviorRelay<UInt64?> = BehaviorRelay(value: nil)
    let totalLoanAmount: BehaviorRelay<Amount?> = BehaviorRelay(value: nil)
    let interestAmount: BehaviorRelay<Amount?> = BehaviorRelay(value: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        kas_activateAutoScrollingForView(scrollView)
    }

    func attributedString(text: String) -> NSAttributedString {
        let string = "\(text) \(self.token.symbol)"
        let ret = NSMutableAttributedString(string: string)
        ret.addAttributes(text: text,
                          attrs: [NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59, alpha: 0.7),
                                  NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)])
        ret.addAttributes(text: string,
                         attrs: [NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59, alpha: 0.45),
                                 NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)])
        return ret
    }

    func setupView() {

        setNavTitle(title: R.string.localizable.defiLoanPageTitle(), bindTo: scrollView)

        scrollView.stackView.addArrangedSubview(titleView)
        scrollView.stackView.addArrangedSubview(header)
        scrollView.stackView.addPlaceholder(height: 20)
        scrollView.stackView.addArrangedSubview(eachAmountView)
        scrollView.stackView.addPlaceholder(height: 20)
        scrollView.stackView.addArrangedSubview(numberView)
        scrollView.stackView.addPlaceholder(height: 20)
        scrollView.stackView.addArrangedSubview(totalAmountView)
        scrollView.stackView.addPlaceholder(height: 4)
        scrollView.stackView.addArrangedSubview(totalAmountTipView)
        scrollView.stackView.addPlaceholder(height: 20)
        scrollView.stackView.addArrangedSubview(rateView)
        scrollView.stackView.addPlaceholder(height: 20)
        scrollView.stackView.addArrangedSubview(durationView)
        scrollView.stackView.addPlaceholder(height: 4)
        scrollView.stackView.addArrangedSubview(durationTipView)
        scrollView.stackView.addPlaceholder(height: 20)
        scrollView.stackView.addArrangedSubview(subscriptionTimeView)
        scrollView.stackView.addPlaceholder(height: 20)
        scrollView.stackView.addArrangedSubview(interestView)
        scrollView.stackView.addPlaceholder(height: 26)
        scrollView.stackView.addArrangedSubview(loanButton)
        scrollView.stackView.addPlaceholder(height: 14)
        scrollView.stackView.addArrangedSubview(tip1View)
        scrollView.stackView.addPlaceholder(height: 4)
        scrollView.stackView.addArrangedSubview(tip2View)
        scrollView.stackView.addPlaceholder(height: 4)
        scrollView.stackView.addArrangedSubview(tip3View)
        scrollView.stackView.addPlaceholder(height: 26)

        eachAmountView.textField.keyboardType = .numberPad
        numberView.textField.keyboardType = .numberPad
        rateView.textField.keyboardType = .decimalPad
        durationView.textField.keyboardType = .numberPad
        subscriptionTimeView.textField.keyboardType = .numberPad

        eachAmountView.textField.kas_setReturnAction(.next(responder: numberView.textField))
        numberView.textField.kas_setReturnAction(.next(responder: rateView.textField))
        rateView.textField.kas_setReturnAction(.next(responder: durationView.textField), delegate: self)
        durationView.textField.kas_setReturnAction(.next(responder: subscriptionTimeView.textField))
        subscriptionTimeView.textField.kas_setReturnAction(.done(block: { (textField) in
            textField.resignFirstResponder()
        }))

        if let loan = loan {
            eachAmountView.textField.text = loan.singleCopyAmount.amountShortStringForDeFiWithGroupSeparator(decimals: token.decimals)
            numberView.textField.text = String(loan.subscriptionCopies)
            rateView.textField.text = String(format: "%.4f", loan.dayRate*100)
            durationView.textField.text = String(loan.loanDuration)
            subscriptionTimeView.textField.text = String(loan.subscriptionDuration)
        }
    }

    func bind() {
        let token = self.token

        eachAmountView.textField.rx.text.map { t -> Amount? in
            guard let text = t, !text.isEmpty else { return nil }
            return text.toAmount(decimals: token.decimals)
        }.bind(to: eachAmount).disposed(by: rx.disposeBag)

        numberView.textField.rx.text.map { t -> UInt64? in
            guard let text = t, !text.isEmpty else { return nil }
            return UInt64(text)
        }.bind(to: number).disposed(by: rx.disposeBag)

        rateView.textField.rx.text.map { t -> Decimal? in
            guard let text = t, !text.isEmpty else { return nil }
            return Decimal(string: text).map { $0 / 100 }
        }.bind(to: rate).disposed(by: rx.disposeBag)

        durationView.textField.rx.text.map { t -> UInt64? in
            guard let text = t, !text.isEmpty else { return nil }
            return UInt64(text)
        }.bind(to: duration).disposed(by: rx.disposeBag)

        subscriptionTimeView.textField.rx.text.map { t -> UInt64? in
            guard let text = t, !text.isEmpty else { return nil }
            return UInt64(text)
        }.bind(to: subscriptionTime).disposed(by: rx.disposeBag)

        BehaviorRelay.combineLatest(eachAmount, number).map { (amount, number) -> Amount? in
            guard let amount = amount, let number = number else { return nil }
            return amount * Amount(number)
        }.bind(to: totalLoanAmount).disposed(by: rx.disposeBag)

        BehaviorRelay.combineLatest(totalLoanAmount, rate, duration).map { (amount, rate, duration) -> Amount? in
            guard let amount = amount, let rate = rate, let duration = duration else { return nil }
            guard let rateBigInt = Amount((rate*1000000).description) else { return nil }
            return amount * Amount(duration) * rateBigInt / Amount(1000000)
        }.bind(to: interestAmount).disposed(by: rx.disposeBag)

        duration.asDriver().drive(onNext: { [weak self] n in
            guard let `self` = self else { return }
            let ret: String
            if let n = n {
                ret = String(n * ViteConst.instance.vite.snapshotChainHeightPerDay)
            } else {
                ret = "--"
            }
            self.durationView.rightLabel.text = R.string.localizable.defiItemLoanDurationBlock(ret)
        }).disposed(by: rx.disposeBag)

        totalLoanAmount.asDriver().drive(onNext: { [weak self] a in
            guard let `self` = self else { return }
            guard let label = self.totalAmountView.rightView as? UILabel else { return }
            let ret: String
            if let amount = a {
                ret = amount.amountShortStringForDeFiWithGroupSeparator(decimals: token.decimals)
            } else {
                ret = "--"
            }
            label.attributedText = self.attributedString(text: ret)
        }).disposed(by: rx.disposeBag)

        interestAmount.asDriver().drive(onNext: { [weak self] a in
            guard let `self` = self else { return }
            guard let label = self.interestView.rightView as? UILabel else { return }
            let ret: String
            if let amount = a {
                ret = amount.amount(decimals: token.decimals, count: 6, groupSeparator: true)
            } else {
                ret = "--"
            }
            label.attributedText = self.attributedString(text: ret)
        }).disposed(by: rx.disposeBag)


        loanButton.rx.tap.bind {[weak self] _ in
            guard let `self` = self else { return }
            guard let account = HDWalletManager.instance.account else { return }

            guard let eachAmount = self.eachAmount.value else {
                Toast.show(R.string.localizable.defiLoanPageCellEachAmountErrorEmpty())
                return
            }

            guard eachAmount >= "10".toAmount(decimals: token.decimals)! else {
                Toast.show(R.string.localizable.defiLoanPageCellEachAmountErrorTooSmall())
                return
            }

            guard let number = self.number.value else {
                Toast.show(R.string.localizable.defiLoanPageCellNumberErrorEmpty())
                return
            }

            guard number > 0 else {
                Toast.show(R.string.localizable.defiLoanPageCellNumberErrorTooSmall())
                return
            }

            guard let rate = self.rate.value else {
                Toast.show(R.string.localizable.defiLoanPageCellRateErrorEmpty())
                return
            }

            guard rate > 0 else {
                Toast.show(R.string.localizable.defiLoanPageCellRateErrorTooSmall())
                return
            }

            guard rate <= 1 else {
                Toast.show(R.string.localizable.defiLoanPageCellRateErrorTooBig())
                return
            }

            guard let duration = self.duration.value else {
                Toast.show(R.string.localizable.defiLoanPageCellDurationErrorEmpty())
                return
            }

            guard duration > 0 else {
                Toast.show(R.string.localizable.defiLoanPageCellDurationErrorTooSmall())
                return
            }

            guard let subscriptionTime = self.subscriptionTime.value else {
                Toast.show(R.string.localizable.defiLoanPageCellSubscriptionTimeErrorEmpty())
                return
            }

            guard subscriptionTime >= 1, subscriptionTime <= 7 else {
                Toast.show(R.string.localizable.defiLoanPageCellSubscriptionTimeErrorIllegal())
                return
            }

            guard let interestAmount = self.interestAmount.value,
                ViteBalanceInfoManager.instance.defiViteBalance().baseAccount.available >= interestAmount else {
                    Toast.show(R.string.localizable.defiLoanPageCellEachAmountErrorNotEnough())
                    return
            }

            Workflow.defiNewLoanWithConfirm(
                account: account,
                tokenInfo: TokenInfo.BuildIn.vite.value,
                dayRate: rate,
                shareAmount: eachAmount,
                shares: number,
                subscribeDays: subscriptionTime,
                expireDays: duration) { [weak self] (result) in
                    guard let `self` = self else { return }
                    switch result {
                    case .success(_):
                        self.navigationController?.popViewController(animated: true)
                        Toast.show(R.string.localizable.defiLoanPageLoanSuccessToast())
                    case .failure(let e):
                        Toast.show(e.localizedDescription)
                    }
                }
        }.disposed(by: rx.disposeBag)
    }

}

extension DeFiLoanViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == rateView.textField {
            let (ret, text) = InputLimitsHelper.allowDecimalPointWithDigitalText(textField.text ?? "", shouldChangeCharactersIn: range, replacementString: string, decimals: 4)
            textField.text = text
            return ret
        } else {
            return true
        }
    }
}
