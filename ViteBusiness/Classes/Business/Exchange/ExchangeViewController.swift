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

    override func viewDidLoad() {

        super.viewDidLoad()
        setupViews()
        bind()
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        vm.action.onNext(.getRate)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    func setupViews()  {

        kas_activateAutoScrollingForView(scrollView)

        view.addSubview(scrollView)
        view.addSubview(exchangeButton)
        scrollView.addSubview(topBackgroundView)
        scrollView.addSubview(titleView)
        scrollView.addSubview(card)

        scrollView.snp.makeConstraints { (m) in
            m.left.right.top.equalToSuperview()
            m.bottom.equalTo(exchangeButton.snp.top).offset(-10)
        }

        topBackgroundView.snp.makeConstraints { (m) in
            m.left.right.top.equalToSuperview()
            m.height.equalTo(192)
        }

        titleView.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview()
            m.top.equalToSuperview().offset(70)
        }

        titleView.titleLabel.textColor = .white

        topBackgroundView.backgroundColor =  UIColor.gradientColor(style: .leftTop2rightBottom,
                                                                   frame: CGRect.init(x: 0, y: 0, width:kScreenW, height: 192),
                                                                   colors: [UIColor(netHex: 0x052EF5),UIColor(netHex: 0x0BB6EB)])



        scrollView.contentSize = CGSize.init(width: kScreenW, height: 567)
        scrollView.isScrollEnabled = true

        card.snp.makeConstraints { m in
            m.left.right.equalToSuperview().inset(24)
            m.height.equalTo(412)
            m.centerX.equalToSuperview()
            m.top.equalTo(topBackgroundView.snp.bottom).offset(-72)
            m.bottom.equalToSuperview().offset(-20)

        }

        card.backgroundColor = UIColor.init(netHex: 0xffffff)
        card.layer.shadowColor = UIColor(netHex: 0x000000).cgColor
        card.layer.shadowOpacity = 0.1
        card.layer.shadowOffset = CGSize(width: 0, height: 0)
        card.layer.shadowRadius = 4


        exchangeButton.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview().inset(24)
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom).offset(-20)
        }
    }

    func bind()  {
        vm.rateInfo.bind { info in
            self.card.priceLabel.text = R.string.localizable.exchangePrice() + "1VITE = " + (String(info.rightRate) ?? "-") + "ETH"
        }.disposed(by: rx.disposeBag)

        card.viteInfo.inputTextField.rx.text.bind { text in
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
            self.card.ethInfo.inputTextField.text = String(a)
        }.disposed(by: rx.disposeBag)

        card.ethInfo.inputTextField.rx.text.bind { text in
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

        exchangeButton.rx.tap.bind{ [unowned self] in

            guard let viteAmount = Double(self.card.viteInfo.inputTextField.text ?? "")  else  {
                Toast.show("illegal  amount")
                return
            }
            guard viteAmount >= self.vm.rateInfo.value.quota.unitQuotaMin  else  {
                Toast.show("less than min  amount \(self.vm.rateInfo.value.quota.unitQuotaMin)")
                return
            }
            guard viteAmount <= self.vm.rateInfo.value.quota.unitQuotaMax  else  {
                Toast.show("bigger than max amount \(self.vm.rateInfo.value.quota.unitQuotaMax)")
                return
            }

            let address = self.vm.rateInfo.value.storeAddress

            guard let amountString = self.card.ethInfo.inputTextField.text,
                !amountString.isEmpty,
                let amount = amountString.toAmount(decimals: TokenInfo.eth000.decimals) else {
                    Toast.show(R.string.localizable.sendPageToastAmountEmpty())
                    return
            }

            Workflow.sendTransactionWithConfirm(account: HDWalletManager.instance.account!, toAddress: address, tokenInfo: TokenInfo.eth000, amount:amount, data: nil, utString: nil) { (block) in
                switch block {
                case .success(let b):
                    self.vm.action.onNext(.report(hash:b.hash ?? ""))
                case .failure(let e):
                    Toast.show(e.localizedDescription)
                }
            }
        }.disposed(by: rx.disposeBag)

        titleView.infoButton.rx.tap.bind{
            let vc = WKWebViewController.init(url: URL.init(string: "http://www.baidu.com")!)
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



}
