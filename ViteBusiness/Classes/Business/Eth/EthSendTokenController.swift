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
import Web3swift

class EthSendTokenController: BaseViewController {
    // FIXME: Optional
    let fromAddress : EthereumAddress = EtherWallet.shared.ethereumAddress!

    var address:  EthereumAddress? = nil
    var amount: Balance? = nil

    public var tokenInfo : TokenInfo

    init(_ tokenInfo: TokenInfo, toAddress: EthereumAddress? = nil,amount:Balance? = nil) {
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
        kas_activateAutoScrollingForView(scrollView)
        ETHBalanceInfoManager.instance.registerFetch(tokenInfos: [tokenInfo])
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ETHBalanceInfoManager.instance.unregisterFetch(tokenInfos: [tokenInfo])
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

    private lazy var gasSliderView: EthGasFeeSliderView = {
        let gasSliderView = EthGasFeeSliderView(gasLimit: self.tokenInfo.isEtherCoin ? EtherWallet.defaultGasLimitForEthTransfer: EtherWallet.defaultGasLimitForTokenTransfer)
        gasSliderView.value = 1.0
        return gasSliderView
    }()

    private lazy var headerView = EthSendPageTokenInfoView(address: self.fromAddress.address)

    private lazy var amountView = SendAmountView(amount: self.amount?.amountFull(decimals: self.tokenInfo.decimals) ?? "", symbol: self.tokenInfo.symbol)

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
        if self.address != nil {
            return AddressLabelView(address: address!.address)
        }else {
            let view = AddressTextViewView()
            view.addButton.rx.tap.bind { [weak self] in
                guard let `self` = self else { return }
                FloatButtonsView(targetView: view.addButton, delegate: self, titles:
                    [R.string.localizable.ethSendPageEthContactsButtonTitle(),
                     R.string.localizable.sendPageScanAddressButtonTitle()]).show()
                }.disposed(by: rx.disposeBag)
            return  view
        }
    }()

    private func fetchGasPrice() {
        EtherWallet.transaction.fetchGasPrice {
            switch $0 {
            case .success(let price):
                // Gwei = 9
                let b = BigDecimal(number: price, digits: 9)
                self.gasSliderView.value = Float(b.description) ?? 1.0
            case .failure:
                break
            }
        }
    }

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

    private func checkSendParameterLegal()->Bool {
        return true
    }

    private func bind() {
        self.headerView.balanceLabel.text = "0.0"

        self.sendButton.rx.tap
            .bind { [weak self] in
               guard let `self` = self else { return }

                guard let toAddress = EthereumAddress(self.addressView.textView.text ?? ""),
                    toAddress.isValid else {
                    Toast.show(R.string.localizable.sendPageToastAddressError())
                    return
                }
                guard let amountString = self.amountView.textField.text,
                    !amountString.isEmpty,
                    let amount = amountString.toBigInt(decimals: self.tokenInfo.decimals) else {
                        Toast.show(R.string.localizable.sendPageToastAmountEmpty())
                        return
                }

                guard amount > BigInt(0) else {
                    Toast.show(R.string.localizable.sendPageToastAmountZero())
                    return
                }

                Workflow.sendEthTransactionWithConfirm(toAddress: toAddress.address, tokenInfo: self.tokenInfo, amount: amount, gasPrice: Float(self.gasSliderView.value), completion: {[weak self] (r) in
                    if case .success = r {
                        self?.dismiss()
                    } else if case .failure(let error) = r {
                        if let web3Error = error as? Web3Error {
                            Toast.show(web3Error.localizedDescription)
                        }else if let walletError = error as? WalletError{
                            let viteError = ViteError.init(code: ViteErrorCode(type: .rpc, id: walletError.id), rawMessage: walletError.rawValue, rawError: walletError)
                            Toast.show(viteError.viteErrorMessage)
                        }else {
                           Toast.show(error.viteErrorMessage)
                        }
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

        self.gasSliderView.tipButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            Alert.show(into: self, title: R.string.localizable.hint(),
                       message: R.string.localizable.ethPageGasFeeNoticeTitle(),
                       actions: [(Alert.UIAlertControllerAletrActionTitle.default(title: R.string.localizable.addressManageTipAlertOk()), nil)])
            }.disposed(by: rx.disposeBag)
    }
}

// MARK: FloatButtonsViewDelegate
extension EthSendTokenController: FloatButtonsViewDelegate {
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
