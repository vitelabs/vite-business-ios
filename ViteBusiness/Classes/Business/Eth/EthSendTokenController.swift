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
import web3swift

class EthSendTokenController: BaseViewController {
    // FIXME: Optional
    let fromAddress = ETHWalletManager.instance.account!.address

    var address:  String? = nil
    var amount: Amount? = nil

    public var tokenInfo : TokenInfo

    init(_ tokenInfo: TokenInfo, toAddress: EthereumAddress? = nil,amount:Amount? = nil) {
        self.tokenInfo = tokenInfo

        self.address = toAddress?.address
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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        kas_activateAutoScrollingForView(scrollView)
        ETHBalanceInfoManager.instance.registerFetch(tokenCodes: [tokenInfo.tokenCode])
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ETHBalanceInfoManager.instance.unregisterFetch(tokenCodes: [tokenInfo.tokenCode])
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    // View
    private lazy var scrollView = ScrollableView(insets: UIEdgeInsets(top: 10, left: 24, bottom: 30, right: 24)).then { (scrollView) in
        scrollView.layer.masksToBounds = false
        scrollView.stackView.spacing = 10
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
        let gasSliderView = EthGasFeeSliderView(gasLimit: self.tokenInfo.ethChainGasLimit)
        gasSliderView.value = 1.0
        return gasSliderView
    }()

    private lazy var headerView = EthSendPageTokenInfoView(address: self.fromAddress, name: AddressManageService.instance.name(for: self.fromAddress))

    private let noteView = SendNoteView(note: "", canEdit: true)
    private lazy var amountView = SendAmountView(amount: self.amount?.amountFull(decimals: self.tokenInfo.decimals) ?? "", token: self.tokenInfo)

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
        if let address = self.address {
            return AddressLabelView(address: address)
        } else {
            let view = AddressTextViewView()
            view.addButton.rx.tap.bind { [weak self] in
                guard let `self` = self else { return }
                FloatButtonsView(targetView: view.addButton, delegate: self, titles:
                    [R.string.localizable.sendPageMyAddressTitle(CoinType.eth.rawValue),
                     R.string.localizable.ethSendPageEthContactsButtonTitle(),
                     R.string.localizable.sendPageScanAddressButtonTitle()]).show()
                }.disposed(by: rx.disposeBag)
            return  view
        }
    }()

    private func setupView() {
        navigationTitleView = NavigationTitleView(title: "\(R.string.localizable.sendPageTitle()) \(self.tokenInfo.uniqueSymbol)")

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
        if tokenInfo.isEtherCoin {
            scrollView.stackView.addArrangedSubview(noteView)
        }
        scrollView.stackView.addPlaceholder(height: 1)
        scrollView.stackView.addArrangedSubview(gasSliderView)
        scrollView.stackView.addPlaceholder(height: 50)

        addressView.textView.keyboardType = .default
        amountView.textField.keyboardType = .decimalPad

        addressView.textView.kas_setReturnAction(.next(responder: amountView.textField))
        if tokenInfo.isEtherCoin {
            amountView.textField.kas_setReturnAction(.next(responder: noteView.textField), delegate: self)
            noteView.textField.kas_setReturnAction(.done(block: { $0.resignFirstResponder() }))
        } else {
            amountView.textField.kas_setReturnAction(.done(block: { $0.resignFirstResponder() }), delegate: self)
        }
    }

    private func checkSendParameterLegal()->Bool {
        return true
    }

    private func bind() {

        amountView.allButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            var balance = ETHBalanceInfoManager.instance.balanceInfo(for: self.tokenInfo.tokenCode)?.balance ?? Amount(0)
            if self.tokenInfo.isEtherCoin {
                let gas = String(format:"%f", self.gasSliderView.eth).toAmount(decimals: TokenInfo.BuildIn.eth.value.decimals)!
                balance = balance > gas ? balance - gas : Amount(0)
            }
            self.amountView.textField.text = balance.amountFull(decimals: self.tokenInfo.decimals)
            self.amountView.calcPrice()
        }.disposed(by: rx.disposeBag)

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
                    let amount = amountString.toAmount(decimals: self.tokenInfo.decimals) else {
                        Toast.show(R.string.localizable.sendPageToastAmountEmpty())
                        return
                }

                guard amount > 0 else {
                    Toast.show(R.string.localizable.sendPageToastAmountZero())
                    return
                }

                Workflow.sendEthTransactionWithConfirm(toAddress: toAddress.address, tokenInfo: self.tokenInfo, amount: amount, gasPrice: Float(self.gasSliderView.value), note: self.noteView.textField.text ?? "", completion: {[weak self] (r) in
                    if case .success = r {
                        self?.dismiss()
                    } else if case .failure(let error) = r {
                        guard ViteError.conversion(from: error) != ViteError.cancel else { return }
                        if let e = error as? DisplayableError {
                            Alert.show(title: R.string.localizable.sendPageEthFailed(e.errorMessage),
                                                  message: nil,
                                                  actions: [
                                                   (.default(title: R.string.localizable.confirm()), { _ in
                                                   })
                                           ])
                        } else {
                            Alert.show(title: R.string.localizable.sendPageEthFailed(error.localizedDescription),
                                                  message: nil,
                                                  actions: [
                                                   (.default(title: R.string.localizable.confirm()), { _ in
                                                   })
                                           ])
                        }
                    }
                })
            }
            .disposed(by: rx.disposeBag)

        ETHBalanceInfoManager.instance.balanceInfoDriver(for: self.tokenInfo.tokenCode)
            .drive(onNext: { [weak self] ret in
                guard let `self` = self else { return }
                let balance = ret?.balance ?? Amount()
                self.headerView.balanceLabel.text = balance.amountFullWithGroupSeparator(decimals: self.tokenInfo.decimals)
            }).disposed(by: rx.disposeBag)
    }
}

// MARK: FloatButtonsViewDelegate
extension EthSendTokenController: FloatButtonsViewDelegate {
    func didClick(at index: Int, targetView: UIView) {
        if index == 0 {
            let viewModel = AddressListViewModel.createMyAddressListViewModel(for: CoinType.eth)
            let vc = AddressListViewController(viewModel: viewModel)
            vc.selectAddressDrive.drive(addressView.textView.rx.text).disposed(by: rx.disposeBag)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        } else if index == 1 {
            let viewModel = AddressListViewModel.createAddressListViewModel(for: CoinType.eth)
            let vc = AddressListViewController(viewModel: viewModel)
            vc.selectAddressDrive.drive(addressView.textView.rx.text).disposed(by: rx.disposeBag)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        } else if index == 2 {
            let scanViewController = ScanViewController()
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
            let (ret, text) = InputLimitsHelper.allowDecimalPointWithDigitalText(textField.text ?? "", shouldChangeCharactersIn: range, replacementString: string, decimals: min(8, tokenInfo.decimals))
            textField.text = text
            return ret
        }  else {
            return true
        }
    }
}
