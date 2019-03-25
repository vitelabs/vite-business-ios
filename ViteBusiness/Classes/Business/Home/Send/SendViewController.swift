//
//  SendViewController.swift
//  Vite
//
//  Created by Stone on 2018/9/10.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import ViteWallet
import SnapKit
import Vite_HDWalletKit
import BigInt
import PromiseKit
import JSONRPCKit
import ViteUtils

class SendViewController: BaseViewController {

    // FIXME: Optional
    let account = HDWalletManager.instance.account!

    let tokenInfo: TokenInfo
    var token: Token
    var balance: Balance

    let address: Address?
    let amount: Balance?
    let note: String?

    let noteCanEdit: Bool

    init(tokenInfo: TokenInfo, address: Address?, amount: BigInt?, note: String?, noteCanEdit: Bool = true) {
        self.tokenInfo = tokenInfo
        self.token = tokenInfo.toViteToken()!
        self.address = address
        self.balance = Balance(value: BigInt(0))
        if let amount = amount {
            self.amount = Balance(value: amount)
        } else {
            self.amount = nil
        }
        self.note = note
        self.noteCanEdit = noteCanEdit
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        kas_activateAutoScrollingForView(scrollView)
        FetchQuotaService.instance.retainQuota()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        FetchQuotaService.instance.releaseQuota()
    }

    // View
    lazy var scrollView = ScrollableView(insets: UIEdgeInsets(top: 10, left: 24, bottom: 30, right: 24)).then {
        $0.layer.masksToBounds = false
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }

    // headerView
    var navView = SendNavView()
    lazy var headerView = SendHeaderView(address: account.address.description, name: AddressManageService.instance.name(for: account.address))

    var addressView: SendAddressViewType!
    lazy var amountView = SendAmountView(amount: amount?.amountFull(decimals: token.decimals) ?? "", symbol: token.symbol)
    lazy var noteView = SendNoteView(note: note ?? "", canEdit: noteCanEdit)

    private func setupView() {

        navigationBarStyle = .custom(tintColor: UIColor(netHex: 0x3E4A59).withAlphaComponent(0.45), backgroundColor: UIColor.clear)

        if let address = address {
            addressView = AddressLabelView(address: address.description)
        } else {
            let view = AddressTextViewView()
            view.addButton.rx.tap.bind { [weak self] in
                guard let `self` = self else { return }
                FloatButtonsView(targetView: view.addButton, delegate: self, titles:
                    [R.string.localizable.sendPageMyAddressTitle(),
                     R.string.localizable.sendPageViteContactsButtonTitle(),
                     R.string.localizable.sendPageScanAddressButtonTitle()]).show()
                }.disposed(by: rx.disposeBag)
            addressView = view
        }

        let sendButton = UIButton(style: .blue, title: R.string.localizable.sendPageSendButtonTitle())

        view.addSubview(scrollView)
        view.addSubview(navView)
        view.addSubview(sendButton)

        navView.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.right.equalToSuperview()
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpTop).offset(45)
        }

        scrollView.snp.makeConstraints { (m) in
            m.top.equalTo(navView.snp.bottom)
            m.left.right.equalTo(view)
        }

        scrollView.stackView.addArrangedSubview(headerView)
        scrollView.stackView.addPlaceholder(height: 30)
        scrollView.stackView.addArrangedSubview(addressView)
        scrollView.stackView.addArrangedSubview(amountView)
        scrollView.stackView.addArrangedSubview(noteView)

        sendButton.snp.makeConstraints { (m) in
            m.top.greaterThanOrEqualTo(scrollView.snp.bottom).offset(10)
            m.left.equalTo(view).offset(24)
            m.right.equalTo(view).offset(-24)
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom).offset(-24)
            m.height.equalTo(50)
        }

        addressView.textView.keyboardType = .default
        amountView.textField.keyboardType = .decimalPad
        noteView.textField.keyboardType = .default

        let toolbar = UIToolbar()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let next: UIBarButtonItem = UIBarButtonItem(title: R.string.localizable.sendPageAmountToolbarButtonTitle(), style: .done, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: R.string.localizable.finish(), style: .done, target: nil, action: nil)
        if noteCanEdit {
            toolbar.items = [flexSpace, next]
        } else {
            toolbar.items = [flexSpace, done]
        }
        toolbar.sizeToFit()
        next.rx.tap.bind { [weak self] in self?.noteView.textField.becomeFirstResponder() }.disposed(by: rx.disposeBag)
        done.rx.tap.bind { [weak self] in self?.amountView.textField.resignFirstResponder() }.disposed(by: rx.disposeBag)
        amountView.textField.inputAccessoryView = toolbar

        addressView.textView.kas_setReturnAction(.next(responder: amountView.textField))
        amountView.textField.delegate = self
        noteView.textField.kas_setReturnAction(.done(block: {
            $0.resignFirstResponder()
        }), delegate: self)

        sendButton.rx.tap
            .bind { [weak self] in
                let address = Address(string: self?.addressView.textView.text ?? "")
                guard let `self` = self else { return }
                guard address.isValid else {
                    Toast.show(R.string.localizable.sendPageToastAddressError())
                    return
                }
                guard let amountString = self.amountView.textField.text,
                    !amountString.isEmpty,
                    let amount = amountString.toBigInt(decimals: self.token.decimals) else {
                    Toast.show(R.string.localizable.sendPageToastAmountEmpty())
                    return
                }

                guard amount > BigInt(0) else {
                    Toast.show(R.string.localizable.sendPageToastAmountZero())
                    return
                }

                guard amount <= self.balance.value else {
                    Toast.show(R.string.localizable.sendPageToastAmountError())
                    return
                }

                Workflow.sendTransactionWithConfirm(account: self.account, toAddress: address, tokenInfo: self.tokenInfo, amount: Balance(value: amount), note: self.noteView.textField.text, completion: { (r) in
                    if case .success = r {
                        GCD.delay(1) { self.dismiss() }
                    }
                })
            }
            .disposed(by: rx.disposeBag)
    }

    private func bind() {
        navView.bind(tokenInfo: tokenInfo)

        ViteBalanceInfoManager.instance.balanceInfoDriver(forViteTokenId: self.token.id)
            .drive(onNext: { [weak self] balanceInfo in
            guard let `self` = self else { return }
            if let balanceInfo = balanceInfo {
                self.balance = balanceInfo.balance
                self.headerView.balanceLabel.text = balanceInfo.balance.amountFull(decimals: self.token.decimals)
            } else {
                // no balanceInfo, set 0.0
                self.headerView.balanceLabel.text = "0.0"
            }
        }).disposed(by: rx.disposeBag)

        FetchQuotaService.instance.maxTxCountDriver
            .map({ R.string.localizable.sendPageQuotaContent($0) })
            .drive(headerView.quotaLabel.rx.text).disposed(by: rx.disposeBag)
    }
}

extension SendViewController: FloatButtonsViewDelegate {
    func didClick(at index: Int) {
        if index == 0 {
            let viewModel = AddressListViewModel.createMyAddressListViewModel()
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
            scanViewController.reactor = ScanViewReactor()
            _ = scanViewController.rx.result.bind {[weak self, scanViewController] result in
                if case .success(let uri) = ViteURI.parser(string: result) {
                    self?.addressView.textView.text = uri.address.description
                    scanViewController.navigationController?.popViewController(animated: true)
                } else {
                    scanViewController.showAlertMessage(result)
                }
            }
            UIViewController.current?.navigationController?.pushViewController(scanViewController, animated: true)
        }
    }
}

extension SendViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == amountView.textField {
            let (ret, text) = InputLimitsHelper.allowDecimalPointWithDigitalText(textField.text ?? "", shouldChangeCharactersIn: range, replacementString: string, decimals: min(8, token.decimals))
            textField.text = text
            return ret
        } else if textField == noteView.textField {
            // maxCount is 120, about 40 Chinese characters
            let ret = InputLimitsHelper.allowText(textField.text ?? "", shouldChangeCharactersIn: range, replacementString: string, maxCount: 120)
            if !ret {
                Toast.show(R.string.localizable.sendPageToastNoteTooLong())
            }
            return ret
        } else {
            return true
        }
    }
}
