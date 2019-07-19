//
//  BnbWalletSendViewController.swift
//  ViteBusiness
//
//  Created by Water on 2019/6/25.
//

import Foundation
import SnapKit
import RxSwift
import RxCocoa
import NSObject_Rx
import BinanceChain

import ViteWallet

class BnbWalletSendViewController: BaseViewController {
    // FIXME: Optional
    let fromAddress : String = BnbWallet.shared.fromAddress!

    public var tokenInfo : TokenInfo
    var balance = 0.0
    var fee = BnbWallet.shared.fee
    var toAddress:String?
    var amount:String?

    init(_ tokenInfo: TokenInfo,toAddress: String? = nil,amount:String? = nil) {
        self.toAddress = toAddress
        self.amount = amount
        self.tokenInfo = tokenInfo
        BnbWallet.shared.fetchFee()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
        BnbWallet.shared.fetchBalance()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        kas_activateAutoScrollingForView(scrollView)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    // View
    private lazy var scrollView = ScrollableView(insets: UIEdgeInsets(top: 10, left: 24, bottom: 30, right: 24)).then { (scrollView) in
        scrollView.layer.masksToBounds = false
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (m) in
            m.top.equalTo(navigationTitleView!.snp.bottom)
            m.left.right.equalTo(view)
        }
    }
    lazy var logoImgView = TokenIconView().then {(imgView) in
        imgView.tokenInfo =  tokenInfo
    }


    private lazy var headerView = BnbSendPageTokenInfoView(address: self.fromAddress)

    private lazy var amountView = SendAmountView(amount:  self.amount ?? "", token: self.tokenInfo)

    private lazy var gasFeeView = BnbGasFeeView()

    lazy var noteView = SendNoteView(note:"", canEdit: true)

    private lazy var sendButton = UIButton(style: .blue, title: R.string.localizable.sendPageSendButtonTitle()).then { (btn) in
        let bottomView = UIView()
        bottomView.backgroundColor = .white
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { (m) in
            m.top.greaterThanOrEqualTo(scrollView.snp.bottom).offset(10)
            m.left.right.equalTo(view)
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom)
            m.height.equalTo(74)
        }

        bottomView.addSubview(btn)
        btn.snp.makeConstraints { (m) in
            m.top.equalTo(bottomView)
            m.left.equalTo(bottomView).offset(24)
            m.right.equalTo(bottomView).offset(-24)
            m.height.equalTo(50)
        }
    }

    private lazy var addressView: SendAddressViewType = {
        if let address = self.toAddress {
            return AddressLabelView(address: address)
        }else {
            let view = AddressTextViewView()
            view.addButton.rx.tap.bind { [weak self] in
                guard let `self` = self else { return }
                FloatButtonsView(targetView: view.addButton, delegate: self, titles:
                    [R.string.localizable.bnbSendPageEthContactsButtonTitle(),
                     R.string.localizable.sendPageScanAddressButtonTitle()]).show()
                }.disposed(by: rx.disposeBag)
            return  view
        }
    }()

    private func setupView() {
        navigationTitleView = NavigationTitleView(title: String.init(format: "%@ \(R.string.localizable.sendPageTitle())",self.tokenInfo.symbol))

        navigationTitleView!.addSubview(logoImgView)
        logoImgView.snp.makeConstraints { (m) in
            m.bottom.equalToSuperview()
            m.right.equalToSuperview().offset(-24)
            m.width.height.equalTo(50)
        }


        var feeStr = "\(self.fee)"
        var rateFee = ""
        if let rateFeeStr =  ExchangeRateManager.instance.calculateBalanceWithBnbRate(self.fee) {
            rateFee = String(format: "≈%@",rateFeeStr)
        }
        self.gasFeeView.totalGasFeeLab.text = String(format: "%@ BNB %@", feeStr,rateFee)

        scrollView.stackView.addArrangedSubview(headerView)
        scrollView.stackView.addPlaceholder(height: 10)
        scrollView.stackView.addArrangedSubview(addressView)
        scrollView.stackView.addArrangedSubview(amountView)
        scrollView.stackView.addArrangedSubview(gasFeeView)
        scrollView.stackView.addArrangedSubview(noteView)

        scrollView.stackView.addPlaceholder(height: 50)

        addressView.textView.keyboardType = .default
        amountView.textField.keyboardType = .decimalPad
        noteView.textField.keyboardType = .default

        let toolbar = UIToolbar()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let next: UIBarButtonItem = UIBarButtonItem(title: R.string.localizable.sendPageAmountToolbarButtonTitle(), style: .done, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: R.string.localizable.finish(), style: .done, target: nil, action: nil)

        toolbar.items = [flexSpace, next]
        toolbar.sizeToFit()
        next.rx.tap.bind { [weak self] in self?.noteView.textField.becomeFirstResponder() }.disposed(by: rx.disposeBag)
        done.rx.tap.bind { [weak self] in self?.amountView.textField.resignFirstResponder() }.disposed(by: rx.disposeBag)
        amountView.textField.inputAccessoryView = toolbar

        addressView.textView.kas_setReturnAction(.next(responder: amountView.textField))
        amountView.textField.delegate = self
        noteView.textField.kas_setReturnAction(.done(block: {
            $0.resignFirstResponder()
        }), delegate: self)

    }

    private func bind() {
        BnbWallet.shared.balanceInfoDriver(symbol: self.tokenInfo.id).drive(onNext:{[weak self] r in
            guard let `self` = self else { return }
            self.headerView.balanceLabel.text = r.free
            self.balance = Double.init(string: r.free)!
        }).disposed(by: rx.disposeBag)

        self.sendButton
            .rx.tap.bind { [weak self] in
            guard let `self` = self else { return }

                guard let toAddress : String = self.addressView.textView.text ?? "",
                toAddress.checkBnbAddressIsValid() else {
                    Toast.show(R.string.localizable.sendPageToastAddressError())
                return
            }
            guard let amountString = self.amountView.textField.text,
                !amountString.isEmpty,
                let amount = Double(amountString) else {
                    Toast.show(R.string.localizable.sendPageToastAmountEmpty())
                    return
            }
            guard amount > 0 else {
                Toast.show(R.string.localizable.sendPageToastAmountZero())
                return
            }

            guard amount <= self.balance else {
                Toast.show(R.string.localizable.sendPageToastAmountError())
                return
            }
            Workflow.sendBnbTransactionWithConfirm(toAddress: toAddress, tokenInfo: self.tokenInfo, amount: amount, fee: self.fee, completion: {[weak self] (r) in

                if case .success = r {
                    self?.dismiss()
                } else if case .failure(let error) = r {
                    guard ViteError.conversion(from: error) != ViteError.cancel else { return }
                    if let e = error as? DisplayableError {
                        Toast.show(e.errorMessage)
                    } else {
                        Toast.show((error as NSError).localizedDescription)
                    }
                }
            })
        }
    }
}

// MARK: FloatButtonsViewDelegate
extension BnbWalletSendViewController: FloatButtonsViewDelegate {
    func didClick(at index: Int) {
        if index == 0 {
            let viewModel = AddressListViewModel.createAddressListViewModel(for: CoinType.bnb)
            let vc = AddressListViewController(viewModel: viewModel)
            vc.selectAddressDrive.drive(addressView.textView.rx.text).disposed(by: rx.disposeBag)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        } else if index == 1 {
            let scanViewController = ScanViewController()
            scanViewController.reactor = ScanViewReactor()
            _ = scanViewController.rx.result.bind {[weak self, scanViewController] result in
                if case .success(let uri) = BnbURI.parser(string: result) {
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
// MARK: UITextFieldDelegate
extension BnbWalletSendViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == amountView.textField {
            let (ret, text) = InputLimitsHelper.allowDecimalPointWithDigitalText(textField.text ?? "", shouldChangeCharactersIn: range, replacementString: string, decimals: min(8, 18))
            textField.text = text
            return ret
        }else if textField == noteView.textField {
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


