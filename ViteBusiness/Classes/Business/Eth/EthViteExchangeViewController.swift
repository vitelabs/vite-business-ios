//
//  EthViteExchangeViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2019/4/24.
//

import UIKit
import ViteEthereum
import Web3swift
import BigInt
import PromiseKit
import ViteWallet

class EthViteExchangeViewController: BaseViewController {

    let myEthAddress = EtherWallet.shared.address!
    var exchangeAll = false
    var balance = Amount(0)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        kas_activateAutoScrollingForView(scrollView)
        ETHBalanceInfoManager.instance.registerFetch(tokenInfos: [TokenInfo.viteERC20])
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ETHBalanceInfoManager.instance.unregisterFetch(tokenInfos: [TokenInfo.viteERC20])
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
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
    lazy var headerView = EthSendPageTokenInfoView(address: myEthAddress).then {
        $0.addressTitleLabel.text = R.string.localizable.ethViteExchangePageMyAddressTitle()

    }

    let addressView = EthViteExchangeViteAddressView().then {
        $0.textLabel.text = HDWalletManager.instance.account?.address ?? ""
    }
    let amountView = EthViteExchangeAmountView().then {
        $0.symbolLabel.text = TokenInfo.viteERC20.symbol
    }

    let gasSliderView = EthGasFeeSliderView(gasLimit: EtherWallet.defaultGasLimitForTokenTransfer).then {
        $0.value = 1.0
    }

    let exchangeButton = UIButton(style: .blue, title: R.string.localizable.ethViteExchangePageSendButtonTitle())

    func setupView() {
        setupNavBar()

        view.addSubview(scrollView)
        view.addSubview(exchangeButton)

        scrollView.snp.makeConstraints { (m) in
            m.top.equalTo(navigationTitleView!.snp.bottom)
            m.left.right.equalTo(view)
        }

        exchangeButton.snp.makeConstraints { (m) in
            m.top.greaterThanOrEqualTo(scrollView.snp.bottom).offset(10)
            m.left.equalTo(view).offset(24)
            m.right.equalTo(view).offset(-24)
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom).offset(-24)
            m.height.equalTo(50)
        }


        scrollView.stackView.addArrangedSubview(headerView)
        scrollView.stackView.addPlaceholder(height: 14)
        scrollView.stackView.addArrangedSubview(addressView)
        scrollView.stackView.addArrangedSubview(amountView)
        scrollView.stackView.addArrangedSubview(gasSliderView)

        let toolbar = UIToolbar()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: R.string.localizable.finish(), style: .done, target: nil, action: nil)
        toolbar.items = [flexSpace, done]
        toolbar.sizeToFit()
        done.rx.tap.bind { [weak self] in self?.amountView.textField.resignFirstResponder() }.disposed(by: rx.disposeBag)
        amountView.textField.inputAccessoryView = toolbar
        amountView.textField.delegate = self
    }

    private func setupNavBar() {
        navigationTitleView = createNavigationTitleView()
        let rightItem = UIBarButtonItem(title: R.string.localizable.ethViteExchangePageExchangeHistoryButtonTitle(), style: .plain, target: self, action: nil)
        rightItem.setTitleTextAttributes([NSAttributedString.Key.font: Fonts.Font14, NSAttributedString.Key.foregroundColor: Colors.blueBg], for: .normal)
        rightItem.setTitleTextAttributes([NSAttributedString.Key.font: Fonts.Font14, NSAttributedString.Key.foregroundColor: Colors.blueBg], for: .highlighted)
        self.navigationItem.rightBarButtonItem = rightItem
        self.navigationItem.rightBarButtonItem?.rx.tap.bind {
            var infoUrl = String.init(format: "%@%@",EtherWallet.network.getEtherInfoH5Url(), HDWalletManager.instance.ethAddress ?? "")
            guard let url = URL(string: infoUrl) else { return }
            let vc = WKWebViewController.init(url: url)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: rx.disposeBag)
    }

    func bind() {

        exchangeButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }

            let address = self.addressView.textLabel.text ?? ""
            guard address.isViteAddress else {
                Toast.show(R.string.localizable.sendPageToastAddressError())
                return
            }

            guard let amountString = self.amountView.textField.text, !amountString.isEmpty,
                let a = amountString.toAmount(decimals: TokenInfo.viteERC20.decimals) else {
                    Toast.show(R.string.localizable.sendPageToastAmountEmpty())
                    return
            }

            let amount: Amount
            if self.exchangeAll {
                amount = self.balance
            } else {
                amount = a
            }

            guard amount > Amount(0) else {
                Toast.show(R.string.localizable.sendPageToastAmountZero())
                return
            }

            guard amount <= self.balance else {
                Toast.show(R.string.localizable.sendPageToastAmountError())
                return
            }

            Workflow.ethViteExchangeWithConfirm(viteAddress: address, amount: amount, gasPrice: Float(self.gasSliderView.value), completion: { [weak self] (r) in
                guard let `self` = self else { return }
                if case .success = r {
                    AlertControl.showCompletion(R.string.localizable.submitSuccess())
                    GCD.delay(1) { self.dismiss() }
                } else if case .failure(let error) = r {
                    if let web3Error = error as? Web3Error {
                        Toast.show(web3Error.localizedDescription)
                    }else if let walletError = error as? WalletError {
                        let viteError = ViteError.init(code: ViteErrorCode(type: .rpc, id: walletError.id), rawMessage: walletError.rawValue, rawError: walletError)
                        Toast.show(viteError.viteErrorMessage)
                    }else {
                        Toast.show(error.viteErrorMessage)
                    }
                }
            })
            }.disposed(by: rx.disposeBag)

        ETHBalanceInfoManager.instance.balanceInfoDriver(for: TokenInfo.viteERC20.tokenCode)
            .drive(onNext: { ret in

                self.balance = ret?.balance ?? self.balance
                let text = self.balance.amountFull(decimals: TokenInfo.viteERC20.decimals)
                self.headerView.balanceLabel.text = text
                self.amountView.textField.placeholder = R.string.localizable.ethViteExchangePageAmountPlaceholder(text)

                if self.exchangeAll {
                    self.amountView.textField.text = self.headerView.balanceLabel.text
                }

            }).disposed(by: rx.disposeBag)

        addressView.button.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            let viewModel = AddressListViewModel.createMyAddressListViewModel()
            let vc = AddressListViewController(viewModel: viewModel)
            vc.selectAddressDrive.drive(self.addressView.textLabel.rx.text).disposed(by: self.rx.disposeBag)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: rx.disposeBag)

        amountView.button.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            self.exchangeAll = true
            self.amountView.textField.text = self.headerView.balanceLabel.text
            }.disposed(by: rx.disposeBag)
    }


    func createNavigationTitleView() -> UIView {
        let view = UIView().then {
            $0.backgroundColor = UIColor.white
        }

        let titleLabel = LabelTipView(R.string.localizable.ethViteExchangePageTitle()).then {
            $0.titleLab.font = UIFont.systemFont(ofSize: 24)
            $0.titleLab.numberOfLines = 1
            $0.titleLab.adjustsFontSizeToFitWidth = true
            $0.titleLab.textColor = UIColor(netHex: 0x24272B)
        }

        let tokenIconView = UIImageView(image: R.image.icon_vite_exchange())

        view.addSubview(titleLabel)
        view.addSubview(tokenIconView)

        titleLabel.snp.makeConstraints { (m) in
            m.top.equalTo(view).offset(6)
            m.left.equalTo(view).offset(24)
            m.bottom.equalTo(view).offset(-20)
            m.height.equalTo(29)
        }

        tokenIconView.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-22)
            m.top.equalToSuperview()
            m.size.equalTo(CGSize(width: 50, height: 50))
        }

        titleLabel.tipButton.rx.tap.bind { [weak self] in
            let htmlString = R.string.localizable.popPageTipEthViteExchange()
            let vc = PopViewController(htmlString: htmlString)
            vc.modalPresentationStyle = .overCurrentContext
            let delegate =  StyleActionSheetTranstionDelegate()
            vc.transitioningDelegate = delegate
            self?.present(vc, animated: true, completion: nil)
            }.disposed(by: rx.disposeBag)
        return view
    }
}

extension EthViteExchangeViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == amountView.textField {
            exchangeAll = false
            let (ret, text) = InputLimitsHelper.allowDecimalPointWithDigitalText(textField.text ?? "", shouldChangeCharactersIn: range, replacementString: string, decimals: min(8, TokenInfo.viteERC20.decimals))
            textField.text = text
            return ret
        } else {
            return true
        }
    }
}
