//
//  ExchangeViewController.swift
//  Action
//
//  Created by haoshenyang on 2019/7/25.
//

import UIKit
import BigInt
import ViteWallet
import RxSwift
import RxCocoa

class ExchangeViewController: BaseViewController {

    let vm = ExchangeViewModel()

    let exchangeButton = UIButton.init(style: .blueWithShadow, title: R.string.localizable.exchangeBuy())

    let topBackgroundView = UIImageView()

    let card = ExchangeCard()

    let titleView = PageTitleView.titleAndInfoButton(title: R.string.localizable.exchangeTitley())

    let label0 = UILabel().then {
        $0.text = R.string.localizable.exchangeLimitOnetime("-", "-")
        $0.numberOfLines = 0
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59,alpha: 0.8)
    }

    let pointView0: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(netHex:0x007AFF)
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
        return view
    }()

    let label1 = UILabel().then {
        $0.text = R.string.localizable.exchangeLimitOneday("-", "-")
        $0.numberOfLines = 0
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59,alpha: 0.8)
    }

    let pointView1: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(netHex:0x007AFF)
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        kas_activateAutoScrollingForView(scrollView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vm.action.onNext(.getRate)
    }
    
    func setupViews()  {
        navigationBarStyle = .clear
        view.addSubview(scrollView)
        scrollView.addSubview(exchangeButton)
        scrollView.addSubview(topBackgroundView)
        scrollView.addSubview(titleView)
        scrollView.addSubview(card)
        scrollView.addSubview(label0)
        scrollView.addSubview(label1)
        scrollView.addSubview(pointView0)
        scrollView.addSubview(pointView1)


        scrollView.snp.makeConstraints { (m) in
            m.left.right.top.equalToSuperview()
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom)
        }

        topBackgroundView.snp.makeConstraints { (m) in
            m.left.right.top.equalToSuperview()
            m.height.equalTo(172 + UIApplication.shared.statusBarFrame.size.height)
        }

        titleView.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview()
            m.top.equalToSuperview().offset(UIApplication.shared.statusBarFrame.size.height + 50)
        }

        titleView.titleLabel.textColor = .white

        topBackgroundView.backgroundColor =  UIColor.gradientColor(style: .leftTop2rightBottom,
                                                                   frame: CGRect.init(x: 0, y: 0, width:kScreenW, height: UIApplication.shared.statusBarFrame.size.height + 172),
                                                                   colors: [UIColor(netHex: 0x052EF5),UIColor(netHex: 0x0BB6EB)])

        scrollView.isScrollEnabled = true
        scrollView.bounces = false

        card.snp.makeConstraints { m in
            m.left.right.equalToSuperview().inset(24)
            m.height.equalTo(424)
            m.centerX.equalToSuperview()
            m.top.equalTo(topBackgroundView.snp.bottom).offset(-72)
        }

        card.backgroundColor = UIColor.init(netHex: 0xffffff)
        card.layer.shadowColor = UIColor(netHex: 0x000000).cgColor
        card.layer.shadowOpacity = 0.1
        card.layer.shadowOffset = CGSize(width: 0, height: 0)
        card.layer.shadowRadius = 4
        card.layer.cornerRadius = 2


        card.viteInfo.inputTextField.delegate = self
        card.ethInfo.inputTextField.delegate = self

        exchangeButton.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview().inset(24)
            m.top.equalTo(card.snp.bottom).offset(29)
            m.height.equalTo(50)
        }

        pointView0.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(35)
            m.height.width.equalTo(6)
            m.top.equalTo(exchangeButton.snp.bottom).offset(29)
        }

        label0.snp.makeConstraints { (m) in
            m.left.equalTo(pointView0.snp.right).offset(5)
            m.top.equalTo(pointView0.snp.bottom).offset(-10)
            m.right.equalToSuperview().offset(-24)
        }

        pointView1.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(35)
            m.height.width.equalTo(6)
            m.top.equalTo(label0.snp.bottom).offset(10)
        }

        label1.snp.makeConstraints { (m) in
            m.left.equalTo(pointView1.snp.right).offset(5)
            m.top.equalTo(pointView1.snp.bottom).offset(-10)
            m.right.equalToSuperview().offset(-24)
            m.bottom.equalToSuperview().offset(-20)
        }

    }

    func bind()  {
        vm.rateInfo.bind { [weak self] info in
            guard let `self` = self else { return }
            self.card.priceLabel.text = R.string.localizable.exchangePrice() + "1 VITE = " + (String(info.rightRate) ?? "-") + " ETH"
            if let total = BigDecimal(String(info.quota.quotaTotal) ),
                let min = BigDecimal(String(info.quota.unitQuotaMin)),
                let max = BigDecimal(String(info.quota.unitQuotaMax)),
                let rest = BigDecimal(String(info.quota.quotaRest)) {
                let totalStr =  BigDecimalFormatter.format(bigDecimal: total , style: .decimalTruncation(8), padding: .none, options:  [.groupSeparator])
                let minStr =  BigDecimalFormatter.format(bigDecimal: min , style: .decimalTruncation(8), padding: .none, options:  [.groupSeparator])
                let maxStr =  BigDecimalFormatter.format(bigDecimal: max , style: .decimalTruncation(8), padding: .none, options:  [.groupSeparator])
                let restStr =  BigDecimalFormatter.format(bigDecimal: rest , style: .decimalTruncation(8), padding: .none, options:  [.groupSeparator])
                self.label0.text = R.string.localizable.exchangeLimitOnetime(minStr, maxStr)
                self.label1.text = R.string.localizable.exchangeLimitOneday(totalStr, restStr)
                let placeholder = minStr + " - " + maxStr
                self.card.viteInfo.inputTextField.attributedPlaceholder = NSAttributedString.init(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(netHex: 0x3E4A59, alpha: 0.45)])
            }

        }.disposed(by: rx.disposeBag)

        card.viteInfo.inputTextField.rx.text.bind {[weak self] text in
            guard let `self` = self else { return }
            guard let count = Double(text ?? "") else {
                self.card.ethInfo.inputTextField.text = nil
                return
            }
            let rightRate = self.vm.rateInfo.value.rightRate

            guard rightRate > 0 else {
                self.card.ethInfo.inputTextField.text = nil
                return
            }

            let a = count * rightRate
            let str = String(format: "%.18lf", a)

            if let de2 = BigDecimal(str ) {
                self.card.ethInfo.inputTextField.text =
                    BigDecimalFormatter.format(bigDecimal: de2 , style: .decimalTruncation(18), padding: .none, options:  [])
            } else {
                self.card.ethInfo.inputTextField.text = str
            }

        }.disposed(by: rx.disposeBag)

        card.ethInfo.inputTextField.rx.text.bind {[weak self] text in
            guard let `self` = self else { return }
            guard let count = Double(text ?? "") else {
                self.card.viteInfo.inputTextField.text = nil
                return
            }
            let rightRate = self.vm.rateInfo.value.rightRate
            guard rightRate > 0 else {
                self.card.viteInfo.inputTextField.text = nil
                return
            }
            let a = count / rightRate
            self.card.viteInfo.inputTextField.text = String(a)

        }.disposed(by: rx.disposeBag)


        card.historyButton.rx.tap.bind { _ in

            UIViewController.current?.navigationController?.pushViewController(ExchangeHistoryViewController(), animated: true)

            }.disposed(by: rx.disposeBag)

        exchangeButton.rx.tap.bind{ [weak self] in
            guard let `self` = self else { return }
            Statistics.log(eventId: "instant_purchase_buy")

            guard let viteAmount = Double(self.card.viteInfo.inputTextField.text ?? "")  else  {
                Toast.show(R.string.localizable.grinSendIllegalAmmount())
                return
            }
            let info = self.vm.rateInfo.value
            guard viteAmount >= self.vm.rateInfo.value.quota.unitQuotaMin,
                viteAmount <= self.vm.rateInfo.value.quota.unitQuotaMax,
                viteAmount <= self.vm.rateInfo.value.quota.quotaRest else {
                    let message = R.string.localizable.exchangeLimitAlert(String(info.quota.unitQuotaMin), String(info.quota.unitQuotaMax), String(info.quota.quotaTotal))
                    Alert.show(title: R.string.localizable.grinNoticeTitle(), message: message, actions: [
                        (.default(title: R.string.localizable.confirm()), nil),
                        ])
                return
            }

            let address = self.vm.rateInfo.value.storeAddress

            guard let amountString = self.card.ethInfo.inputTextField.text,
                !amountString.isEmpty,
                let amount = amountString.toAmount(decimals: TokenInfo.eth000.decimals) else {
                    Toast.show(R.string.localizable.sendPageToastAmountEmpty())
                    return
            }

            Workflow.sendTransactionWithConfirm(account: HDWalletManager.instance.account!, toAddress: address, tokenInfo: TokenInfo.eth000, amount:amount, data: nil, utString: nil) { [weak self] (block) in
                guard let `self` = self else { return }
                switch block {
                case .success(let b):
                    self.vm.action.onNext(.report(hash:b.hash ?? ""))
                case .failure(let e):
                    Toast.show(e.localizedDescription)
                }
            }
        }.disposed(by: rx.disposeBag)

        titleView.infoButton.rx.tap.bind{
            var url: URL!
            if LocalizationService.sharedInstance.currentLanguage == .chinese {
                url = URL.init(string: "https://vite-static-pages.netlify.com/exchange/zh/exchange.html")
            } else {
                url = URL.init(string: "https://vite-static-pages.netlify.com/exchange/en/exchange.html")
            }
            let vc = WKWebViewController.init(url: url)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: rx.disposeBag)

        vm.exchangeResult.bind { result in
            UIViewController.current?.navigationController?.pushViewController(ExchangeHistoryViewController(), animated: true)
        }.disposed(by: rx.disposeBag)
    }

    lazy var scrollView = ScrollableView(insets: UIEdgeInsets(top: 10, left: 24, bottom: 30, right: 24)).then {
        $0.layer.masksToBounds = false
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }


}

extension ExchangeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == card.ethInfo.inputTextField {
            let (ret, text) = InputLimitsHelper.allowDecimalPointWithDigitalText(textField.text ?? "", shouldChangeCharactersIn: range, replacementString: string, decimals: TokenInfo.eth.decimals)
            textField.text = text
            return ret
        } else if textField == card.viteInfo.inputTextField {
            let (ret, text) = InputLimitsHelper.allowDecimalPointWithDigitalText(textField.text ?? "", shouldChangeCharactersIn: range, replacementString: string, decimals: TokenInfo.viteCoin.decimals)
            textField.text = text
            return ret
        } else {
            return true
        }
    }
}

