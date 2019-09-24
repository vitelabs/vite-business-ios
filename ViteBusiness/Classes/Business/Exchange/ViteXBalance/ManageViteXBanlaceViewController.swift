//
//  ManageViteXBanlaceViewController.swift
//  Action
//
//  Created by haoshenyang on 2019/9/9.
//

import UIKit
import ViteWallet
import SnapKit
import Vite_HDWalletKit
import BigInt
import PromiseKit
import JSONRPCKit
import RxCocoa
import RxSwift

class ManageViteXBanlaceViewController: BaseViewController {

    enum ActionType {
        case toVitex
        case toWallet
    }

    let actionType: ManageViteXBanlaceViewController.ActionType

    init(tokenInfo: TokenInfo,actionType: ManageViteXBanlaceViewController.ActionType) {
        self.token = tokenInfo
        self.actionType = actionType
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var abstractView = WalletAbstractView().then { abstractView in
        abstractView.tl0.text = R.string.localizable.fundWalletAddress()
        abstractView.cl0.text = HDWalletManager.instance.account?.address
        abstractView.tl1.text = self.actionType == .toVitex ? R.string.localizable.fundWalletFound() : R.string.localizable.fundVitexFound()
        abstractView.cl1.text = " "
        abstractView.tl2.text = R.string.localizable.fundQuotaInfo()
        abstractView.cl2.text = " "
    }

    lazy var scrollView = ScrollableView(insets: UIEdgeInsets(top: 10, left: 24, bottom: 30, right: 24)).then {
        $0.layer.masksToBounds = false
        $0.stackView.spacing = 10
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }

    lazy var amountView = EthViteExchangeAmountView().then { amountView in
        amountView.textField.keyboardType = .decimalPad
        amountView.symbolLabel.text = ""
        amountView.symbolLabel.textColor = UIColor.init(netHex: 0x3E4A59,alpha: 0.7)
        amountView.button.setTitle(R.string.localizable.fundDepositAll(), for: .normal)
        amountView.titleLabel.text = self.actionType == .toVitex ? R.string.localizable.fundDepositAmount() : R.string.localizable.fundWithdrawAmount()
        let placeholder = self.actionType == .toVitex ? R.string.localizable.fundDepositPlaceholder() : R.string.localizable.fundWithdrawPlaceholder()
        amountView.textField.attributedPlaceholder = NSAttributedString.init(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(netHex: 0x3E4A59, alpha: 0.45)])
    }

    var quotaView = SendQuotaItemView(utString: ABI.BuildIn.dexDeposit.ut.utToString())

    lazy var handleButton = { () -> UIButton in
        let title = self.actionType == .toVitex ? R.string.localizable.fundDeposit() : R.string.localizable.fundWithdraw()
        return UIButton.init(style: .blue, title: title)
    }()

    let token: TokenInfo
    var balance = Amount(0)

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        kas_activateAutoScrollingForView(scrollView)
        ViteBalanceInfoManager.instance.registerFetch(tokenCodes: [token.tokenCode])
        FetchQuotaManager.instance.retainQuota()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        FetchQuotaManager.instance.releaseQuota()
        ViteBalanceInfoManager.instance.unregisterFetch(tokenCodes: [token.tokenCode])
    }

    func setUpView() {
        let  tilte = self.actionType == .toVitex ? R.string.localizable.fundTitleToVitex() : R.string.localizable.fundTitleToWallet()
        navigationTitleView = PageTitleView.titleAndTokenIcon(title: tilte, tokenInfo: token)
        navigationTitleView?.backgroundColor = UIColor.white

        amountView.symbolLabel.textColor = UIColor.init(netHex: 0x3E4A59,alpha: 0.7)
        amountView.textField.keyboardType = .decimalPad

        view.addSubview(scrollView)
        view.addSubview(handleButton)

        scrollView.snp.makeConstraints { (m) in
            m.top.equalTo(navigationTitleView!.snp.bottom)
            m.left.right.equalTo(view)
            m.bottom.equalTo(handleButton.snp.top)
        }

        scrollView.stackView.addArrangedSubview(abstractView)
        scrollView.stackView.addArrangedSubview(amountView)
        scrollView.stackView.addPlaceholder(height: 10)
        scrollView.stackView.addArrangedSubview(quotaView)

        abstractView.snp.makeConstraints { (m) in
            m.height.equalTo(198)
        }

        handleButton.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview().inset(24)
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom).offset(-24)
        }
    }

    func bind() {
        FetchQuotaManager.instance.quotaDriver
            .drive(onNext: { [weak self] (quota) in
                guard let `self` = self else { return }
                self.abstractView.cl2.text = "\(quota.currentUt.utToString())/\(quota.utpe.utToString()) UT"
            }).disposed(by: rx.disposeBag)

        amountView.button.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            self.amountView.textField.text = self.balance.amount(decimals: self.token.decimals, count: min(8,self.token.decimals),groupSeparator: false)
            }.disposed(by: rx.disposeBag)

        if actionType == .toVitex {
            ViteBalanceInfoManager.instance.balanceInfoDriver(forViteTokenId: token.id)
                .drive(onNext: { [weak self] balanceInfo in
                    guard let `self` = self else { return }
                    self.balance = balanceInfo?.balance ?? Amount(0)
                    self.abstractView.cl1.text = self.balance.amountFullWithGroupSeparator(decimals: self.token.decimals)
                }).disposed(by: rx.disposeBag)
        } else if actionType == .toWallet {
            ViteBalanceInfoManager.instance.dexBalanceInfoDriver(forViteTokenId: token.id)
                .drive(onNext: { [weak self] dexBalanceInfo in
                    guard let `self` = self else { return }
                    self.balance = dexBalanceInfo?.available ?? Amount(0)
                    self.abstractView.cl1.text = self.balance.amountFullWithGroupSeparator(decimals: self.token.decimals)
                }).disposed(by: rx.disposeBag)
        }

        handleButton.rx.tap.bind { [weak self] _ in
            guard let `self` = self else { return }
            guard let amountString = self.amountView.textField.text, !amountString.isEmpty,
                let amount = amountString.toAmount(decimals: self.token.decimals) else {
                    Toast.show(R.string.localizable.sendPageToastAmountEmpty())
                    return
            }

            guard amount > 0 else {
                Toast.show(R.string.localizable.sendPageToastAmountZero())
                return
            }

            guard amount <= self.balance else {
                Toast.show(R.string.localizable.fundTooBig())
                return
            }

            if self.actionType == .toVitex {
                self.fundFromWalletToVitex(amount:amount)
            } else if self.actionType == .toWallet {
                self.fundFromVitexToWallet(amount:amount)
            }

        }.disposed(by: rx.disposeBag)
    }

    func fundFromWalletToVitex(amount: Amount) {
        guard let amout = HDWalletManager.instance.account else { return }
        Workflow.dexDepositWithConfirm(account: amout, tokenInfo: token, amount: amount) { [weak self] (result) in
            switch result {
            case .success(_):
                Alert.show(title: R.string.localizable.fundDepositSuccess(), message: nil, actions: [
                    (.default(title: R.string.localizable.cancel()), { _ in
                        self?.navigationController?.popViewController(animated: true)
                    }),
                    (.default(title: R.string.localizable.confirm()), { _ in
                        guard let `self` = self else { return }
                        let webvc = WKWebViewController(url: self.vitexPageUrl())
                        var vcs = self.navigationController?.viewControllers
                        vcs?.popLast()
                        vcs?.append(webvc)
                        if let vcs = vcs {
                            self.navigationController?.setViewControllers(vcs, animated: true)
                        }
                    })])

            case .failure(let e):
                Toast.show(e.localizedDescription)
            }
        }
    }

    func fundFromVitexToWallet(amount: Amount) {
        guard let amout = HDWalletManager.instance.account else { return }
        Workflow.dexWithdrawWithConfirm(account: amout, tokenInfo: token, amount: amount) { [weak self] (result) in
            switch result {
            case .success(_):
                self?.navigationController?.popViewController(animated: true)
            case .failure(let e):
                Toast.show(e.localizedDescription)
            }
        }
    }

    func vitexPageUrl() -> URL {
        var urlStr = ViteConst.instance.vite.viteXUrl + "#/assets"
            + "?address=" + (HDWalletManager.instance.account?.address ?? "")
            + "&currency=" + AppSettingsService.instance.currencyBehaviorRelay.value.rawValue
        return URL.init(string:urlStr)!
    }

}
