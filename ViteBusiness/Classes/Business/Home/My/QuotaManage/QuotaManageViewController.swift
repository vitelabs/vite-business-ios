//
//  QuotaManageViewController.swift
//  Vite
//
//  Created by Stone on 2018/10/25.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import ViteWallet
import SnapKit
import RxSwift
import RxCocoa
import NSObject_Rx
import BigInt

class QuotaManageViewController: BaseViewController {
    // FIXME: Optional
    let account = HDWalletManager.instance.account!

    var address: ViteAddress?

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        initBinds()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        kas_activateAutoScrollingForView(scrollView)
        FetchQuotaManager.instance.retainQuota()
        ViteBalanceInfoManager.instance.registerFetch(tokenCodes: [TokenInfo.BuildIn.vite.value.tokenCode])
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        FetchQuotaManager.instance.releaseQuota()
        ViteBalanceInfoManager.instance.unregisterFetch(tokenCodes: [TokenInfo.BuildIn.vite.value.tokenCode])
    }

    // View
    lazy var scrollView = ScrollableView(insets: UIEdgeInsets(top: 10, left: 24, bottom: 50, right: 24)).then {
        $0.layer.masksToBounds = false
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }

    // headerView
    lazy var headerView = SendHeaderView(address: account.address, name: AddressManageService.instance.name(for: account.address), type: .pledge)

    // money
    lazy var amountView = TitleMoneyInputView(title: R.string.localizable.quotaManagePageQuotaMoneyTitle(), placeholder: R.string.localizable.quotaManagePageQuotaMoneyPlaceholder(), content: "", desc: ViteWalletConst.viteToken.symbol).then {
        $0.textField.keyboardType = .decimalPad
    }

    //snapshoot height
    lazy var pledgeView = SendPledgeItemView()

    let quotaView = SendQuotaItemView(utString: ABI.BuildIn.stakeForQuota.ut.utToString())

    lazy var addressView = AddressTextViewView(placeholder: R.string.localizable.quotaSubmitPageQuotaAddressPlaceholder()).then {
        $0.titleLabel.text = R.string.localizable.quotaManagePageInputAddressTitle()
        $0.textView.text = HDWalletManager.instance.account?.address
        $0.textView.keyboardType = .default
    }

    lazy var sendButton = UIButton(style: .blue, title: R.string.localizable.quotaManagePageSubmitBtnTitle())

    private func setupNavBar() {
        statisticsPageName = Statistics.Page.WalletQuota.name
        navigationTitleView = NavigationTitleView(title: R.string.localizable.quotaManagePageTitle())
        let rightItem = UIBarButtonItem(title: R.string.localizable.quotaManagePageCheckQuotaListBtnTitle(), style: .plain, target: self, action: nil)
        rightItem.setTitleTextAttributes([NSAttributedString.Key.font: Fonts.Font14, NSAttributedString.Key.foregroundColor: Colors.blueBg], for: .normal)
        rightItem.setTitleTextAttributes([NSAttributedString.Key.font: Fonts.Font14, NSAttributedString.Key.foregroundColor: Colors.blueBg], for: .highlighted)
        self.navigationItem.rightBarButtonItem = rightItem
        self.navigationItem.rightBarButtonItem?.rx.tap.bind {[weak self] in
            let pledgeHistoryVC = PledgeHistoryViewController()
            pledgeHistoryVC.reactor = PledgeHistoryViewReactor()
            self?.navigationController?.pushViewController(pledgeHistoryVC, animated: true)
        }.disposed(by: rx.disposeBag)
    }

    private func setupView() {
        setupNavBar()

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (m) in
            m.top.equalTo(navigationTitleView!.snp.bottom)
            m.left.right.bottom.equalTo(view)
        }

        sendButton.snp.makeConstraints { (m) in
            m.height.equalTo(50)
        }

        scrollView.stackView.addArrangedSubview(headerView)
        scrollView.stackView.addPlaceholder(height: 30)
        scrollView.stackView.addArrangedSubview(addressView)
        scrollView.stackView.addPlaceholder(height: 20)
        scrollView.stackView.addArrangedSubview(amountView)
        scrollView.stackView.addPlaceholder(height: 40)
        scrollView.stackView.addArrangedSubview(pledgeView)
        scrollView.stackView.addPlaceholder(height: 40)
        scrollView.stackView.addArrangedSubview(quotaView)
        scrollView.stackView.addPlaceholder(height: 30)
        scrollView.stackView.addArrangedSubview(sendButton)

        let toolbar = UIToolbar()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: R.string.localizable.finish(), style: .done, target: nil, action: nil)
        toolbar.items = [flexSpace, done]
        toolbar.sizeToFit()
        done.rx.tap.bind { [weak self] in self?.amountView.textField.resignFirstResponder() }.disposed(by: rx.disposeBag)
        amountView.textField.inputAccessoryView = toolbar

        addressView.textView.kas_setReturnAction(.next(responder: amountView.textField), delegate: addressView)
        amountView.textField.delegate = self

        self.initBtnAction()
    }
}

//bind
extension QuotaManageViewController {

    func initBtnAction() {
        sendButton.rx.tap
            .bind { [weak self] in
                Statistics.log(eventId: Statistics.Page.WalletQuota.submit.rawValue)
                guard let `self` = self else { return }
                let address = self.addressView.textView.text ?? ""

                guard address.isViteAddress else {
                    Toast.show(R.string.localizable.sendPageToastAddressError())
                    return
                }

                guard let amountString = self.amountView.textField.text,
                    !amountString.isEmpty,
                    let amount = amountString.toAmount(decimals: ViteWalletConst.viteToken.decimals) else {
                        Toast.show(R.string.localizable.sendPageToastAmountEmpty())
                        return
                }

                guard amount > 0 else {
                    Toast.show(R.string.localizable.sendPageToastAmountZero())
                    return
                }

                guard amount <= self.headerView.balance else {
                    Toast.show(R.string.localizable.sendPageToastAmountError())
                    return
                }

                guard amount >= "134".toAmount(decimals: ViteWalletConst.viteToken.decimals)! else {
                    Toast.show(R.string.localizable.quotaManagePageToastMoneyError())
                    return
                }

                let vc = QuotaSubmitPopViewController(money: amountString, beneficialAddress: address, amount: amount)
                vc.delegate = self
                vc.modalPresentationStyle = .overCurrentContext
                let delegate =  StyleActionSheetTranstionDelegate()
                vc.transitioningDelegate = delegate
                self.present(vc, animated: true, completion: nil)

            }
            .disposed(by: rx.disposeBag)

        addressView.addButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            FloatButtonsView(targetView: self.addressView.addButton, delegate: self, titles:
                [R.string.localizable.sendPageMyAddressTitle(CoinType.vite.rawValue),
                 R.string.localizable.sendPageViteContactsButtonTitle(),
                 R.string.localizable.sendPageScanAddressButtonTitle()]).show()
            }.disposed(by: rx.disposeBag)
    }

    func refreshDataBySuccess() {
        self.addressView.textView.text = ""
        self.amountView.textField.text = ""
    }

    func initBinds() {
        headerView.bind(token: ViteWalletConst.viteToken)
    }
}

extension QuotaManageViewController: FloatButtonsViewDelegate {
    func didClick(at index: Int, targetView: UIView) {
        if index == 0 {
            let viewModel = AddressListViewModel.createMyAddressListViewModel(for: CoinType.vite)
            let vc = AddressListViewController(viewModel: viewModel)
            vc.selectAddressDrive.drive(addressView.textView.rx.text).disposed(by: rx.disposeBag)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        } else if index == 1 {
            let viewModel = AddressListViewModel.createAddressListViewModel(for: CoinType.vite)
            let vc = AddressListViewController(viewModel: viewModel)
            vc.selectAddressDrive.drive(addressView.textView.rx.text).disposed(by: rx.disposeBag)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        } else if index == 2 {
            let scanViewController = ScanViewController()
            _ = scanViewController.rx.result.bind {[weak self, scanViewController] result in
                if case .success(let uri) = ViteURI.parser(string: result) {
                    self?.addressView.textView.text = uri.address
                    scanViewController.navigationController?.popViewController(animated: true)
                } else {
                    scanViewController.showAlertMessage(result)
                }
            }
            UIViewController.current?.navigationController?.pushViewController(scanViewController, animated: true)
        }
    }
}

extension QuotaManageViewController: QuotaSubmitPopViewControllerDelegate {
    func confirmAction(beneficialAddress: ViteAddress, amountString: String, amount: Amount) {
        Statistics.log(eventId: Statistics.Page.WalletQuota.confirm.rawValue)
        let amount = amountString.toAmount(decimals: ViteWalletConst.viteToken.decimals)!
        Workflow.pledgeWithConfirm(account: account, beneficialAddress: beneficialAddress, amount: amount) { (r) in
            if case .success = r {
                self.refreshDataBySuccess()
            }
        }
    }
}

extension QuotaManageViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == amountView.textField {
            let (ret, text) = InputLimitsHelper.allowDecimalPointWithDigitalText(textField.text ?? "", shouldChangeCharactersIn: range, replacementString: string, decimals: min(8, ViteWalletConst.viteToken.decimals))
            textField.text = text
            return ret
        } else {
            return true
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == amountView.textField {
            amountView.symbolLabel.isHidden = false
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == amountView.textField {
            amountView.symbolLabel.isHidden = textField.text?.isEmpty ?? true
        }
    }
}
