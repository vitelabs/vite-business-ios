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

public class ManageViteXBanlaceViewController: BaseViewController {

    enum ActionType {
        case toVitex
        case toWallet
    }

    var actionType = ActionType.toVitex

    let autoDismiss: Bool
    public init(tokenInfo: TokenInfo, autoDismiss: Bool) {
        self.token = tokenInfo
        self.autoDismiss = autoDismiss
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var topContainerView = UIView().then { view in
        view.backgroundColor = UIColor.init(netHex: 0xF3F5F9)
    }

    let leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.vitex_balance_left()
        return imageView
    }()

    let fromTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.7)
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = R.string.localizable.transferFrom()
        return label
    }()

    let fromLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(netHex: 0x3e4a59)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = R.string.localizable.transferWalletAccount()
        return label
    }()

    let destTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.7)
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = R.string.localizable.transferTo()
        return label
    }()

    let destLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(netHex: 0x3e4a59)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = R.string.localizable.transferDexAccount()
        return label
    }()

    let seperator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(netHex: 0xD3DFEF)
        return view
    }()

    let switchButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(R.image.vitex_balance_switch(), for: .normal)
        return button
    }()

    lazy var amountView = EthViteExchangeAmountView().then { amountView in
        amountView.textField.keyboardType = .decimalPad
        amountView.symbolLabel.text = self.token.symbol
        amountView.symbolLabel.textColor = UIColor.init(netHex: 0x3E4A59,alpha: 0.7)
        amountView.button.setTitle(R.string.localizable.fundDepositAll(), for: .normal)
        amountView.titleLabel.text = R.string.localizable.transferAmount()
        let placeholder = self.actionType == .toVitex ? R.string.localizable.fundDepositPlaceholder() : R.string.localizable.fundWithdrawPlaceholder()
        amountView.textField.attributedPlaceholder = NSAttributedString.init(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(netHex: 0x3E4A59, alpha: 0.45)])
    }

    lazy var balanceLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(netHex: 0x3e4a59, alpha: 0.45)
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "\(R.string.localizable.transferAvailable())-- \(self.token.symbol)"
        return label
    }()

    lazy var handleButton = { () -> UIButton in
        let title = R.string.localizable.transferTitle()
        return UIButton.init(style: .blue, title: title)
    }()

    let token: TokenInfo
    var walletBalance = Amount(0)
    var vitexBalance = Amount(0)

    var balance: Amount {
        if self.actionType == .toVitex {
            return walletBalance
        } else {
            return vitexBalance
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        bind()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        kas_activateAutoScrollingForView(view)
        ViteBalanceInfoManager.instance.registerFetch(tokenCodes: [token.tokenCode])
        FetchQuotaManager.instance.retainQuota()
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        FetchQuotaManager.instance.releaseQuota()
        ViteBalanceInfoManager.instance.unregisterFetch(tokenCodes: [token.tokenCode])
    }

    func setUpView() {
        navigationTitleView = PageTitleView.onlyTitle(title: R.string.localizable.transferTitle())
        navigationTitleView?.backgroundColor = UIColor.white

        amountView.symbolLabel.textColor = UIColor.init(netHex: 0x3E4A59,alpha: 0.7)
        amountView.textField.keyboardType = .decimalPad

        view.addSubview(handleButton)
        view.addSubview(topContainerView)
        topContainerView.addSubview(leftImageView)
        topContainerView.addSubview(fromTitleLabel)
        topContainerView.addSubview(fromLabel)
        topContainerView.addSubview(destTitleLabel)
        topContainerView.addSubview(destLabel)
        topContainerView.addSubview(seperator)
        topContainerView.addSubview(switchButton)

        view.addSubview(amountView)
        view.addSubview(balanceLabel)

        topContainerView.snp.makeConstraints { (m) in
            m.height.equalTo(157)
            m.left.right.equalToSuperview()
            m.top.equalTo(navigationTitleView!.snp.bottom)
        }

        leftImageView.snp.makeConstraints { (m) in
            m.width.equalTo(6)
            m.height.equalTo(72)
            m.centerY.equalToSuperview()
            m.left.equalToSuperview().inset(24)
        }

        seperator.snp.makeConstraints { (m) in
            m.height.equalTo(0.5)
            m.centerY.equalToSuperview()
            m.left.equalToSuperview().offset(46)
            m.right.equalToSuperview().offset(-2)
        }

        switchButton.snp.makeConstraints { (m) in
            m.width.height.equalTo(30)
            m.centerY.equalToSuperview()
            m.right.equalToSuperview().inset(024)
        }


        fromLabel.snp.makeConstraints { (m) in
            m.bottom.equalTo(seperator.snp.top).offset(-13)
            m.left.equalToSuperview().offset(46)
        }

        fromTitleLabel.snp.makeConstraints { (m) in
            m.bottom.equalTo(fromLabel.snp.top).offset(-11)
            m.left.equalToSuperview().offset(46)
        }



        destTitleLabel.snp.makeConstraints { (m) in
            m.top.equalTo(seperator.snp.bottom).offset(14)
            m.left.equalToSuperview().offset(46)
        }

        destLabel.snp.makeConstraints { (m) in
            m.top.equalTo(destTitleLabel.snp.bottom).offset(11)
            m.left.equalToSuperview().offset(46)
        }

        amountView.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview().inset(24)
            m.top.equalTo(topContainerView.snp.bottom)
         }

        handleButton.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview().inset(24)
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom).offset(-24)
        }

        balanceLabel.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview().inset(24)
            m.top.equalTo(amountView.snp.bottom).offset(11)
        }
    }

    func bind() {

        amountView.button.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            self.amountView.textField.text = self.balance.amount(decimals: self.token.decimals, count: min(8,self.token.decimals),groupSeparator: false)
            }.disposed(by: rx.disposeBag)

        ViteBalanceInfoManager.instance.balanceInfoDriver(forViteTokenId: token.id)
            .drive(onNext: { [weak self] balanceInfo in
                guard let `self` = self else { return }
                self.walletBalance = balanceInfo?.balance ?? Amount(0)
                if self.actionType == .toVitex {
                    self.balanceLabel.text =  R.string.localizable.transferAvailable() + self.balance.amountFullWithGroupSeparator(decimals: self.token.decimals) + " " + self.token.symbol
                }
            }).disposed(by: rx.disposeBag)
        ViteBalanceInfoManager.instance.dexBalanceInfoDriver(forViteTokenId: token.id)
            .drive(onNext: { [weak self] dexBalanceInfo in
                guard let `self` = self else { return }
                self.vitexBalance = dexBalanceInfo?.available ?? Amount(0)
                if self.actionType == .toWallet {
                    self.balanceLabel.text =  R.string.localizable.transferAvailable() +   self.balance.amountFullWithGroupSeparator(decimals: self.token.decimals) +  " " + self.token.symbol
                }
            }).disposed(by: rx.disposeBag)

        handleButton.rx.tap.bind { [weak self] _ in
            guard let `self` = self else { return }

            guard self.balance > 0 else {
                Toast.show(self.actionType == .toVitex ? R.string.localizable.fundCannotDeposit() : R.string.localizable.fundCannotWithDraw())
                   return
           }

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

        switchButton.rx.tap.bind {  [weak self] _ in
            guard let `self` = self else { return }
            if self.actionType == .toVitex {
                self.actionType = .toWallet
                self.fromLabel.text = R.string.localizable.transferDexAccount()
                self.destLabel.text = R.string.localizable.transferWalletAccount()
                self.balanceLabel.text =  R.string.localizable.transferAvailable() + self.balance.amountFullWithGroupSeparator(decimals: self.token.decimals) +  " " + self.token.symbol
            } else {
                self.actionType = .toVitex
                self.destLabel.text = R.string.localizable.transferDexAccount()
                self.fromLabel.text = R.string.localizable.transferWalletAccount()
                self.balanceLabel.text =  R.string.localizable.transferAvailable() + self.balance.amountFullWithGroupSeparator(decimals: self.token.decimals) +  " " + self.token.symbol
            }

        }.disposed(by: rx.disposeBag)
    }

    func fundFromWalletToVitex(amount: Amount) {
        guard let account = HDWalletManager.instance.account else { return }
        Workflow.dexDepositWithConfirm(account: account, tokenInfo: token, amount: amount) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case .success(_):
                if self.autoDismiss {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    Alert.show(title: R.string.localizable.fundDepositSuccess(), message: nil, actions: [
                    (.default(title: R.string.localizable.cancel()), { _ in
                        self.navigationController?.popViewController(animated: true)
                    }),
                    (.default(title: R.string.localizable.confirm()), { _ in
                        let webvc = WKWebViewController(url: self.vitexPageUrl())
                        var vcs = self.navigationController?.viewControllers
                        vcs?.popLast()
                        vcs?.append(webvc)
                        if let vcs = vcs {
                            self.navigationController?.setViewControllers(vcs, animated: true)
                        }
                    })])
                }
            case .failure(let e):
                Toast.show(e.localizedDescription)
            }
        }
    }

    func fundFromVitexToWallet(amount: Amount) {
        guard let account = HDWalletManager.instance.account else { return }
        Workflow.dexWithdrawWithConfirm(account: account, tokenInfo: token, amount: amount) { [weak self] (result) in
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
            + "&currency=" + AppSettingsService.instance.appSettings.currency.rawValue
        return URL.init(string:urlStr)!
    }

}
