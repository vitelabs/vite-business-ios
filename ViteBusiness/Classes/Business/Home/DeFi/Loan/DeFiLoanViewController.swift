//
//  DeFiLoanViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2019/12/4.
//

import UIKit
import ViteWallet

class DeFiLoanViewController: BaseScrollableViewController {

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

    lazy var eachAmountView = SendTextFieldItemView(title: R.string.localizable.defiLoanPageCellEachAmountTitle(), rightViewStyle: .label(style: .text(string: token.symbol))).then {
        $0.textField.placeholder = R.string.localizable.defiLoanPageCellEachAmountPlaceholder("10", self.token.symbol)
    }

    lazy var numberView = SendTextFieldItemView(title: R.string.localizable.defiLoanPageCellNumberTitle(), rightViewStyle: .label(style: .text(string: R.string.localizable.defiLoanPageCellNumberUnit()))).then {
        $0.textField.placeholder = R.string.localizable.defiLoanPageCellNumberPlaceholder()
    }

    lazy var totalAmountView = SendStaticItemView(title: R.string.localizable.defiLoanPageCellTotalAmountTitle(), rightViewStyle: .label(style: .attributed(string: attributedString(text: "--"))))

    let totalAmountTipView = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.8)
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.numberOfLines = 0
    }

    lazy var rateView = SendTextFieldItemView(title: R.string.localizable.defiLoanPageCellRateTitle(), rightViewStyle: .label(style: .text(string: "%")))

    lazy var subscriptionTimeView = SendTextFieldItemView(title: R.string.localizable.defiLoanPageCellSubscriptionTimeTitle(), rightViewStyle: .label(style: .text(string: R.string.localizable.defiLoanPageCellSubscriptionTimeUnit()))).then {
        $0.textField.placeholder = "1-7"
    }

    lazy var interestView = SendStaticItemView(title: R.string.localizable.defiLoanPageCellInterestTitle(), rightViewStyle: .label(style: .attributed(string: attributedString(text: "--"))))

    let loanButton = UIButton(style: .blue, title: R.string.localizable.defiLoanPageLoanButtonTitle())

    let tip1View = TipTextView(text: R.string.localizable.defiLoanPageTip1())
    let tip2View = TipTextView(text: R.string.localizable.defiLoanPageTip2())
    let tip3View = TipTextView(text: R.string.localizable.defiLoanPageTip3())

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
        subscriptionTimeView.textField.keyboardType = .numberPad

        eachAmountView.textField.kas_setReturnAction(.next(responder: numberView.textField))
        numberView.textField.kas_setReturnAction(.next(responder: rateView.textField))
        rateView.textField.kas_setReturnAction(.next(responder: subscriptionTimeView.textField))
        subscriptionTimeView.textField.kas_setReturnAction(.done(block: { (textField) in
            textField.resignFirstResponder()
        }))
    }

    func bind() {
        loanButton.rx.tap.bind {[weak self] _ in
            guard let account = HDWalletManager.instance.account else { return }
            let a = pow(10.0, Double(TokenInfo.BuildIn.vite.value.decimals)) * 100
            let shareAmount = Amount(a)
            let dayRate = 0.001
            let shares = 100
            let subscribeDays = 7
            let expireDays = 30

            Workflow.defiNewLoanWithConfirm(
                account: account,
                tokenInfo: TokenInfo.BuildIn.vite.value,
                dayRate: dayRate,
                shareAmount: shareAmount,
                shares: shares,
                subscribeDays: subscribeDays,
                expireDays: expireDays) { [weak self] (result) in
                    guard let `self` = self else { return }
                    switch result {
                    case .success(_):
                        self.navigationController?.popViewController(animated: true)
                    case .failure(let e):
                        Toast.show(e.localizedDescription)
                    }
                }
        }.disposed(by: rx.disposeBag)
    }

    deinit {
        print("sss")
    }
}
