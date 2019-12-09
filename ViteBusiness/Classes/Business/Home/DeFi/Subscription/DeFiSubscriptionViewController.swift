//
//  DeFiSubscriptionViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2019/12/5.
//

import UIKit
import ViteWallet

class DeFiSubscriptionViewController: BaseScrollableViewController {

    let productHash: String

    init(productHash: String) {
        self.productHash = productHash
        super.init()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let token = ViteWalletConst.viteToken
    let titleView = NavigationTitleView(title: R.string.localizable.defiSubscriptionPageTitle(), horizontal: 0)
    let header = DeFiProductInfoCard.init(title: "去中心化智能合约安全保障", status: .none, porgressDesc: "认购进度：--%", progress: 0, deadLineDesc: NSAttributedString.init(string: "--后结束认购"))

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
    }
}
