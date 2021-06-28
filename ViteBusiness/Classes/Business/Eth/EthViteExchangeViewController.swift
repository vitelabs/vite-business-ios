//
//  EthViteExchangeViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2019/4/24.
//

import UIKit
import web3swift
import BigInt
import PromiseKit
import ViteWallet

class EthViteExchangeViewController: BaseViewController {

    let myEthAddress = ETHWalletManager.instance.account!.address
    var balance = Amount(0)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        kas_activateAutoScrollingForView(scrollView)
        ETHBalanceInfoManager.instance.registerFetch(tokenCodes: [TokenInfo.BuildIn.eth_vite.value.tokenCode])
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        let key = "tipShowed"
        let collection = "EthViewExchange"
        if let hasShowTip = UserDefaultsService.instance.objectForKey(key, inCollection: collection) as? Bool,
            hasShowTip {
            // do nothing
        } else {
            UserDefaultsService.instance.setObject(true, forKey: key, inCollection: collection)
            DispatchQueue.main.async {
                self.showTip()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ETHBalanceInfoManager.instance.unregisterFetch(tokenCodes: [TokenInfo.BuildIn.eth_vite.value.tokenCode])
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

    let addressView = AddressTextViewView().then {
        $0.textView.text = HDWalletManager.instance.account?.address ?? ""
    }
    let amountView = EthViteExchangeAmountView().then {
        $0.textField.keyboardType = .decimalPad
    }

    let gasSliderView = EthGasFeeSliderView(gasLimit: TokenInfo.BuildIn.eth_vite.value.ethChainGasLimit).then {
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
        scrollView.stackView.addPlaceholder(height: 20)
        scrollView.stackView.addArrangedSubview(addressView)
        scrollView.stackView.addArrangedSubview(amountView)
        scrollView.stackView.addPlaceholder(height: 21)
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
        let title = R.string.localizable.ethViteExchangePageExchangeHistoryButtonTitle()

        let rightItem = UIBarButtonItem(title: title, style: .plain, target: self, action: nil)
        rightItem.setTitleTextAttributes([NSAttributedString.Key.font: Fonts.Font14, NSAttributedString.Key.foregroundColor: Colors.blueBg], for: .normal)
        rightItem.setTitleTextAttributes([NSAttributedString.Key.font: Fonts.Font14, NSAttributedString.Key.foregroundColor: Colors.blueBg], for: .highlighted)
        self.navigationItem.rightBarButtonItem = rightItem
        self.navigationItem.rightBarButtonItem?.rx.tap.bind { [weak self] in
            var infoUrl = "\(ViteConst.instance.eth.explorer)/address/\(ETHWalletManager.instance.account?.address ?? "")#tokentxns"
            guard let url = URL(string: infoUrl) else { return }
            let vc = WKWebViewController.init(url: url)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: rx.disposeBag)
    }

    func bind() {

        addressView.addButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            FloatButtonsView(targetView: self.addressView.addButton, delegate: self, titles:
                [R.string.localizable.sendPageMyAddressTitle(CoinType.vite.rawValue),
                 R.string.localizable.sendPageViteContactsButtonTitle(),
                 R.string.localizable.sendPageScanAddressButtonTitle()]).show()
            }.disposed(by: rx.disposeBag)

        exchangeButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }

            let address = self.addressView.textView.text ?? ""
            guard address.isViteAddress else {
                Toast.show(R.string.localizable.sendPageToastAddressError())
                return
            }

            guard let amountString = self.amountView.textField.text, !amountString.isEmpty,
                let amount = amountString.toAmount(decimals: TokenInfo.BuildIn.eth_vite.value.decimals) else {
                    Toast.show(R.string.localizable.sendPageToastAmountEmpty())
                    return
            }

            guard amount > Amount(0) else {
                Toast.show(R.string.localizable.sendPageToastAmountZero())
                return
            }

            guard amount <= self.balance else {
                Toast.show(R.string.localizable.sendPageToastAmountError())
                return
            }

            self.exchangeErc20ViteTokenToViteCoin(viteAddress: address, amount: amount, gasPrice: Float(self.gasSliderView.value))

            }.disposed(by: rx.disposeBag)

        ETHBalanceInfoManager.instance.balanceInfoDriver(for: TokenInfo.BuildIn.eth_vite.value.tokenCode)
            .drive(onNext: { [weak self] ret in
                guard let `self` = self else { return }
                self.balance = ret?.balance ?? self.balance
                let text = self.balance.amountFullWithGroupSeparator(decimals: TokenInfo.BuildIn.eth_vite.value.decimals)
                self.headerView.balanceLabel.text = text
                self.amountView.textField.placeholder = R.string.localizable.ethViteExchangePageAmountPlaceholder(text)
            }).disposed(by: rx.disposeBag)

        amountView.button.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            self.amountView.textField.text = self.balance.amountFull(decimals: TokenInfo.BuildIn.eth_vite.value.decimals)
            }.disposed(by: rx.disposeBag)

        let tokenInfo = TokenInfo.BuildIn.eth_vite.value

        amountView.textField.rx.text.bind { [weak self] text in
            guard let `self` = self else { return }
            let rateMap = ExchangeRateManager.instance.rateMap
            if let amount = text?.toAmount(decimals: tokenInfo.decimals) {
                self.amountView.symbolLabel.text = "≈" + rateMap.priceString(for: tokenInfo, balance: amount)
            } else {
                self.amountView.symbolLabel.text = "≈ 0.0"
            }
            }
            .disposed(by: rx.disposeBag)
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
                self?.showTip()
            }.disposed(by: rx.disposeBag)
        return view
    }

    func showTip() {
        var htmlString = R.string.localizable.popPageTipEthViteExchange()
        let vc = PopViewController(htmlString: htmlString)
        vc.modalPresentationStyle = .overCurrentContext
        let delegate =  StyleActionSheetTranstionDelegate()
        vc.transitioningDelegate = delegate
        present(vc, animated: true, completion: nil)
    }

    func exchangeErc20ViteTokenToViteCoin(viteAddress: String, amount: Amount, gasPrice: Float) {
        Workflow.ethViteExchangeWithConfirm(viteAddress: viteAddress, amount: amount, gasPrice: gasPrice, completion: { [weak self] (r) in
            guard let `self` = self else { return }
            if case .success = r {
                AlertControl.showCompletion(R.string.localizable.workflowToastSubmitSuccess())
                GCD.delay(1) { self.dismiss() }
            } else if case .failure(let error) = r {
                guard ViteError.conversion(from: error) != ViteError.cancel else { return }
                Alert.show(title: R.string.localizable.sendPageEthFailed(error.localizedDescription),
                       message: nil,
                       actions: [
                        (.cancel, nil),
                        (.default(title: R.string.localizable.confirm()), { _ in
                        })
                ])
            }
        })
    }
}

extension EthViteExchangeViewController: FloatButtonsViewDelegate {
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

extension EthViteExchangeViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == amountView.textField {
            return InputLimitsHelper.canDecimalPointWithDigitalText(textField.text ?? "", shouldChangeCharactersIn: range, replacementString: string, decimals: min(8, TokenInfo.BuildIn.eth_vite.value.decimals))
        } else {
            return true
        }
    }
}
