//
//  BnbWalletSendViewController.swift
//  ViteBusiness
//
//  Created by Water on 2019/6/25.
//

import Foundation
import ViteWallet
import SnapKit
import RxSwift
import RxCocoa
import NSObject_Rx
import BigInt
import ViteEthereum
import web3swift

import BinanceChain

class BnbWalletSendViewController: BaseViewController {
    // FIXME: Optional
    let fromAddress : String = BnbWallet.shared.fromAddress!

    public var tokenInfo : TokenInfo

    init(_ tokenInfo: TokenInfo) {
        self.tokenInfo = tokenInfo
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
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
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

    private lazy var amountView = SendAmountView(amount: "", token: self.tokenInfo)

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

        let view = AddressTextViewView()
        view.addButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            FloatButtonsView(targetView: view.addButton, delegate: self, titles:
                [R.string.localizable.ethSendPageEthContactsButtonTitle(),
                 R.string.localizable.sendPageScanAddressButtonTitle()]).show()
            }.disposed(by: rx.disposeBag)
        return  view

    }()

    private func setupView() {
        navigationTitleView = NavigationTitleView(title: String.init(format: "%@ \(R.string.localizable.sendPageTitle())",self.tokenInfo.symbol))

        navigationTitleView!.addSubview(logoImgView)
        logoImgView.snp.makeConstraints { (m) in
            m.bottom.equalToSuperview()
            m.right.equalToSuperview().offset(-24)
            m.width.height.equalTo(50)
        }

        scrollView.stackView.addArrangedSubview(headerView)
        scrollView.stackView.addPlaceholder(height: 10)
        scrollView.stackView.addArrangedSubview(addressView)
        scrollView.stackView.addArrangedSubview(amountView)
        scrollView.stackView.addArrangedSubview(gasFeeView)
        scrollView.stackView.addArrangedSubview(noteView)

        scrollView.stackView.addPlaceholder(height: 50)

        addressView.textView.keyboardType = .default
        amountView.textField.keyboardType = .decimalPad

        let toolbar = UIToolbar()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let next: UIBarButtonItem = UIBarButtonItem(title: R.string.localizable.sendPageAmountToolbarButtonTitle(), style: .done, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: R.string.localizable.finish(), style: .done, target: nil, action: nil)

        toolbar.items = [flexSpace, done]
        toolbar.sizeToFit()
        done.rx.tap.bind { [weak self] in self?.amountView.textField.resignFirstResponder() }.disposed(by: rx.disposeBag)
        amountView.textField.inputAccessoryView = toolbar
        addressView.textView.kas_setReturnAction(.next(responder: amountView.textField))
        amountView.textField.delegate = self
    }

    private func bind() {
        BnbWallet.shared.balanceInfoDriver(for: self.tokenInfo.tokenCode).drive(onNext:{[weak self] ret in
            guard let `self` = self else { return }
            guard let balance = ret else { return }
            self.headerView.balanceLabel.text =  String.init(format: "%.6f", balance.free)
        }).disposed(by: rx.disposeBag)

        self.sendButton.rx.tap
            .bind { [weak self] in
                guard let `self` = self else { return }

                Workflow.sendBnbTransactionWithConfirm(toAddress: "bnb157mhtzq8z80x4mtf8ckhvaxfqpsym9hf3cvsqn", tokenInfo: self.tokenInfo, amount: 0.0001, fee: 0.000375, completion: { r in

                })


//                BnbWallet.shared.sendTransaction(toAddress: "bnb157mhtzq8z80x4mtf8ckhvaxfqpsym9hf3cvsqn", amount: 0.0001, symbol: "BNB")

//                guard let toAddress = EthereumAddress(self.addressView.textView.text ?? ""),
//                    toAddress.isValid else {
//                        Toast.show(R.string.localizable.sendPageToastAddressError())
//                        return
//                }
//                guard let amountString = self.amountView.textField.text,
//                    !amountString.isEmpty,
//                    let amount = amountString.toAmount(decimals: self.tokenInfo.decimals) else {
//                        Toast.show(R.string.localizable.sendPageToastAmountEmpty())
//                        return
//                }
//
//                guard amount > 0 else {
//                    Toast.show(R.string.localizable.sendPageToastAmountZero())
//                    return
//                }
        }
    }
}

// MARK: FloatButtonsViewDelegate
extension BnbWalletSendViewController: FloatButtonsViewDelegate {
    func didClick(at index: Int) {
        if index == 0 {
            let viewModel = AddressListViewModel.createAddressListViewModel(for: CoinType.eth)
            let vc = AddressListViewController(viewModel: viewModel)
            vc.selectAddressDrive.drive(addressView.textView.rx.text).disposed(by: rx.disposeBag)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        } else if index == 1 {
            let scanViewController = ScanViewController()
            scanViewController.reactor = ScanViewReactor()
            _ = scanViewController.rx.result.bind {[weak self, scanViewController] result in
                if case .success(let uri) = ETHURI.parser(string: result) {
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
        }  else {
            return true
        }
    }
}


