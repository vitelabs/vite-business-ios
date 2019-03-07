//
//  EthSendTokenController.swift
//  ViteBusiness
//
//  Created by Water on 2019/2/21.
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

class EthSendTokenController: BaseViewController {
    // FIXME: Optional
    let fromAddress : EthereumAddress = EtherWallet.shared.ethereumAddress!

    var address:  web3swift.Address? = nil
    var amount: Balance? = nil

    public var tokenInfo : TokenInfo

    init(_ tokenInfo: TokenInfo, toAddress: web3swift.Address? = nil,amount:Balance? = nil) {
        self.tokenInfo = tokenInfo

        self.address = toAddress
        self.amount = amount
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
        fetchGasPrice()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        kas_activateAutoScrollingForView(scrollView.stackView)
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

    private lazy var gasSliderView: EthGasFeeSliderView = {
        let gasSliderView = EthGasFeeSliderView(gasLimit: self.tokenInfo.isEtherCoin ? EtherWallet.shared.defaultGasLimitForEthTransfer: EtherWallet.shared.defaultGasLimitForTokenTransfer)
        gasSliderView.value = 1.0
        return gasSliderView
    }()

    private lazy var headerView = EthSendPageTokenInfoView(address: self.fromAddress.address)

    private lazy var amountView = SendAmountView(amount: "", symbol: "")
    private lazy var sendButton = UIButton(style: .blue, title: R.string.localizable.sendPageSendButtonTitle()).then { (btn) in
        view.addSubview(btn)

        btn.snp.makeConstraints { (m) in
            m.top.greaterThanOrEqualTo(scrollView.snp.bottom).offset(10)
            m.left.equalTo(view).offset(24)
            m.right.equalTo(view).offset(-24)
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom).offset(-24)
            m.height.equalTo(50)
        }
    }

    private lazy var addressView: SendAddressViewType = {
        if self.address != nil {
            return AddressLabelView(address: address!.description)
        }else {
            return  AddressTextViewView()
        }
    }()

    private func fetchGasPrice() {
        EtherWallet.transaction.fetchGasPrice { (result) in
            guard let gas = result else { return }
            self.gasSliderView.value = Float(gas.string(units:.gWei)) ?? 1.0
        }
    }

    private func setupView() {
    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationTitleView = NavigationTitleView(title: String.init(format: "%@转账",self.tokenInfo.tokenCode))

        self.amountView.symbolLabel.text = self.tokenInfo.symbol

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
        scrollView.stackView.addPlaceholder(height: 1)
        scrollView.stackView.addArrangedSubview(gasSliderView)
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
        self.headerView.balanceLabel.text = "0.0"

        self.sendButton.rx.tap
            .bind { [weak self] in
               guard let `self` = self else { return }
                let toAddress = Address(self.addressView.textView.text ?? "")
                guard toAddress.isValid else {
                    Toast.show(R.string.localizable.sendPageToastAddressError())
                    return
                }
                guard let amountString = self.amountView.textField.text,
                    !amountString.isEmpty,
                    let amount = amountString.toBigInt(decimals: 18) else {
                        Toast.show(R.string.localizable.sendPageToastAmountEmpty())
                        return
                }

                guard amount > BigInt(0) else {
                    Toast.show(R.string.localizable.sendPageToastAmountZero())
                    return
                }
                Workflow.sendEthTransactionWithConfirm(toAddress: toAddress.address, token: self.tokenInfo, amount: amountString, gasPrice: Float(self.gasSliderView.value), completion: {[weak self] (r) in
                    if case .success = r {
                        self?.dismiss()
                    } else if case .failure(let error) = r {
                        Toast.show(error.viteErrorMessage)
                    }
                })
            }
            .disposed(by: rx.disposeBag)

        ETHBalanceInfoManager.instance.balanceInfoDriver(for: self.tokenInfo.tokenCode)
            .drive(onNext: { [weak self] ret in
                guard let `self` = self else { return }
                if let balanceInfo = ret {
                    self.headerView.balanceLabel.text = balanceInfo.balance.amountFull(decimals: self.tokenInfo.decimals)
                } else {
                    // no balanceInfo, set 0.0
                    self.headerView.balanceLabel.text = "0.0"
                }
            }).disposed(by: rx.disposeBag)
    }
}

extension EthSendTokenController: UITextFieldDelegate {
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
