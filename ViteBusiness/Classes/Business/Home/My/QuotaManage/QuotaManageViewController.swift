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
import ViteUtils

class QuotaManageViewController: BaseViewController {
    // FIXME: Optional
    let account = HDWalletManager.instance.account!

    var address: Address?
    var balance: Balance

    init() {
        self.balance = Balance(value: BigInt(0))
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
        kas_activateAutoScrollingForView(scrollView.stackView)
        FetchQuotaService.instance.retainQuota()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        FetchQuotaService.instance.releaseQuota()
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
    lazy var headerView = SendHeaderView(address: account.address.description)

    // money
    lazy var amountView = TitleMoneyInputView(title: R.string.localizable.quotaManagePageQuotaMoneyTitle(), placeholder: R.string.localizable.quotaManagePageQuotaMoneyPlaceholder(), content: "", desc: ViteWalletConst.viteToken.symbol).then {
        $0.textField.keyboardType = .decimalPad
    }

    //snapshoot height
    lazy var snapshootHeightLab = TitleDescView(title: R.string.localizable.quotaManagePageQuotaSnapshootHeightTitle()).then {
        let str = R.string.localizable.quotaManagePageQuotaSnapshootHeightDesc("3")
        let range = str.range(of: "3")!
        let attributedString = NSMutableAttributedString(string: str)
        attributedString.addAttributes([NSAttributedString.Key.foregroundColor: Colors.titleGray_45], range: NSRange.init(range, in: str))
        $0.descLab.attributedText = attributedString
    }

    lazy var addressView = AddressTextViewView(placeholder: R.string.localizable.quotaSubmitPageQuotaAddressPlaceholder()).then {
        $0.titleLabel.text = R.string.localizable.quotaManagePageInputAddressTitle()
        $0.textView.keyboardType = .default
    }

    lazy var sendButton = UIButton(style: .blue, title: R.string.localizable.quotaManagePageSubmitBtnTitle())

    private func setupNavBar() {
        statisticsPageName = Statistics.Page.WalletQuota.name
        navigationTitleView = createNavigationTitleView()
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
        scrollView.stackView.addPlaceholder(height: 30)
        scrollView.stackView.addArrangedSubview(amountView)
        scrollView.stackView.addPlaceholder(height: 40)
        scrollView.stackView.addArrangedSubview(snapshootHeightLab)
        scrollView.stackView.addPlaceholder(height: 37)
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

    func createNavigationTitleView() -> UIView {
        let view = UIView().then {
            $0.backgroundColor = UIColor.white
        }

        let titleLabel = LabelTipView(R.string.localizable.quotaManagePageTitle()).then {
            $0.titleLab.font = UIFont.systemFont(ofSize: 24)
            $0.titleLab.numberOfLines = 1
            $0.titleLab.adjustsFontSizeToFitWidth = true
            $0.titleLab.textColor = UIColor(netHex: 0x24272B)
        }

        view.addSubview(titleLabel)

        titleLabel.snp.makeConstraints { (m) in
            m.top.equalTo(view).offset(6)
            m.left.equalTo(view).offset(24)
            m.bottom.equalTo(view).offset(-20)
            m.height.equalTo(29)
        }

        titleLabel.tipButton.rx.tap.bind { [weak self] in
            let htmlString = R.string.localizable.popPageTipQuota()
            let vc = PopViewController(htmlString: htmlString)
            vc.modalPresentationStyle = .overCurrentContext
            let delegate =  StyleActionSheetTranstionDelegate()
            vc.transitioningDelegate = delegate
            self?.present(vc, animated: true, completion: nil)
        }.disposed(by: rx.disposeBag)
        return view
    }
}

//bind
extension QuotaManageViewController {

    func initBtnAction() {
        sendButton.rx.tap
            .bind { [weak self] in
                Statistics.log(eventId: Statistics.Page.WalletQuota.submit.rawValue)
                guard let `self` = self else { return }
                let address = Address(string: self.addressView.textView.text ?? "")

                guard address.isValid else {
                    Toast.show(R.string.localizable.sendPageToastAddressError())
                    return
                }

                guard let amountString = self.amountView.textField.text,
                    !amountString.isEmpty,
                    let amount = amountString.toBigInt(decimals: ViteWalletConst.viteToken.decimals) else {
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

                guard amount >= "1000".toBigInt(decimals: ViteWalletConst.viteToken.decimals)! else {
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
                [R.string.localizable.sendPageMyAddressTitle(),
                 R.string.localizable.sendPageAddContactsButtonTitle(),
                 R.string.localizable.sendPageScanAddressButtonTitle()]).show()
            }.disposed(by: rx.disposeBag)
    }

    func refreshDataBySuccess() {
        self.addressView.textView.text = ""
        self.amountView.textField.text = ""
    }

    func initBinds() {
        ViteBalanceInfoManager.instance.balanceInfoDriver(forViteTokenId: ViteWalletConst.viteToken.id)
            .drive(onNext: { [weak self] balanceInfo in
                guard let `self` = self else { return }
                if let balanceInfo = balanceInfo {
                    self.balance = balanceInfo.balance
                    self.headerView.balanceLabel.text = balanceInfo.balance.amountFull(decimals: ViteWalletConst.viteToken.decimals)
                } else {
                    // no balanceInfo, set 0.0
                    self.headerView.balanceLabel.text = "0.0"
                }
            }).disposed(by: rx.disposeBag)

    FetchQuotaService.instance.quotaDriver
        .map({ R.string.localizable.sendPageQuotaContent($0) })
        .drive(headerView.quotaLabel.rx.text).disposed(by: rx.disposeBag)
    }
}

extension QuotaManageViewController: FloatButtonsViewDelegate {
    func didClick(at index: Int) {
        if index == 0 {
            let viewModel = AddressListViewModel.createMyAddressListViewModel()
            let vc = AddressListViewController(viewModel: viewModel)
            vc.selectAddress.asObservable().bind(to: addressView.textView.rx.text).disposed(by: rx.disposeBag)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        } else if index == 1 {
            let viewModel = AddressListViewModel.createAddressListViewModel(for: CoinType.vite)
            let vc = AddressListViewController(viewModel: viewModel)
            vc.selectAddress.asObservable().bind(to: addressView.textView.rx.text).disposed(by: rx.disposeBag)
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

extension QuotaManageViewController: QuotaSubmitPopViewControllerDelegate {
    func confirmAction(beneficialAddress: Address, amountString: String, amount: BigInt) {
        Statistics.log(eventId: Statistics.Page.WalletQuota.confirm.rawValue)
        let amount = Balance(value: amountString.toBigInt(decimals: ViteWalletConst.viteToken.decimals)!)
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
