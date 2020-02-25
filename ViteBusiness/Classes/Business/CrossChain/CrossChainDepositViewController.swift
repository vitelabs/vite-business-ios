//
//  CrossChainDepositViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2019/9/18.
//

import UIKit
import web3swift
import BigInt
import PromiseKit
import ViteWallet

class CrossChainDepositViewController: BaseViewController {

    init(gatewayInfoService: CrossChainGatewayInfoService, depositInfo: DepositInfo) {
        self.gatewayInfoService = gatewayInfoService
        self.depositInfo = depositInfo
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let gatewayInfoService: CrossChainGatewayInfoService
    var depositInfo: DepositInfo
    var exchangeAll = false
    var balance = Amount(0)

    lazy var scrollView = ScrollableView(insets: UIEdgeInsets(top: 10, left: 24, bottom: 50, right: 24)).then {
        $0.layer.masksToBounds = false
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }

    lazy var headerView = EthSendPageTokenInfoView(address: ETHWalletManager.instance.account!.address).then {
        $0.addressTitleLabel.text = R.string.localizable.ethViteExchangePageMyAddressTitle()
    }

    let addressView = EthViteExchangeViteAddressView.addressView(style: .chouseAddressButton).then {
        $0.textLabel.text = HDWalletManager.instance.account?.address ?? ""
    }

    lazy var amountView = EthViteExchangeAmountView().then {
        $0.textField.keyboardType = .decimalPad
        let info = self.depositInfo
        guard let symble = self.gatewayInfoService.tokenInfo.gatewayInfo?.mappedToken.symbol else {
            return
        }
        if let amount = Amount(info.minimumDepositAmount)?.amountShort(decimals: self.viteChainTokenDecimals) {
            $0.textField.placeholder = "\(R.string.localizable.crosschainDepositMin())\(amount) \(symble)"
        }
    }

    let gasSliderView = EthGasFeeSliderView(gasLimit: ETHWalletManager.defaultGasLimitForTokenTransfer).then {
        $0.value = 1.0
    }

    let exchangeButton = UIButton(style: .blue, title: R.string.localizable.ethViteExchangePageSendButtonTitle())

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
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ETHBalanceInfoManager.instance.unregisterFetch(tokenCodes: [TokenInfo.BuildIn.eth_vite.value.tokenCode])
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

}

extension CrossChainDepositViewController {

    func bind() {
        exchangeButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }

            let address = self.addressView.textLabel.text ?? ""
            guard address.isViteAddress else {
                Toast.show(R.string.localizable.sendPageToastAddressError())
                return
            }

            let decimalsForAmountView = self.mappedChainTokenDecimals!
            guard let amountString = self.amountView.textField.text, !amountString.isEmpty,
                let a = amountString.toAmount(decimals: decimalsForAmountView) else {
                    Toast.show(R.string.localizable.sendPageToastAmountEmpty())
                    return
            }

            let amount: Amount
            if self.exchangeAll {
                amount = self.trueAmout(for: self.balance)
            } else {
                amount = a
            }

            guard
                let minimumDepositAmount = Amount(self.depositInfo.minimumDepositAmount ?? "")
                 else  {
                    return
            }

            let minStr = minimumDepositAmount.amountFull(decimals: self.viteChainTokenDecimals)

            guard let min = Double(minStr),
                let current = Double(amountString) else { return }
            if current < min {
                let minSymbol = self.gatewayInfoService.tokenInfo.gatewayInfo?.mappedToken.symbol ?? ""
                Toast.show(R.string.localizable.crosschainDepositMinAlert() + minStr + minSymbol)
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

            self.exchangeEthCoinToViteToken(viteAddress: address, amount: amount, gasPrice: Float(self.gasSliderView.value))

            }.disposed(by: rx.disposeBag)


        ETHBalanceInfoManager.instance.balanceInfoDriver(for: self.gatewayInfoService.tokenInfo.gatewayInfo!.mappedToken
            .tokenCode)
            .drive(onNext: { [weak self] ret in
                guard let `self` = self else { return }
                self.balance = ret?.balance ?? self.balance
                let text = self.balance.amountFullWithGroupSeparator(decimals: self.mappedChainTokenDecimals!)
                self.headerView.balanceLabel.text = text
            }).disposed(by: rx.disposeBag)

        self.gatewayInfoService.depositInfo(viteAddress: HDWalletManager.instance.account?.address ?? "")
            .done { [weak self] (info) in
                guard let `self` = self else { return }
                self.depositInfo = info
                guard let symble = self.gatewayInfoService.tokenInfo.gatewayInfo?.mappedToken.symbol else {
                        return
                }
                if let amount = Amount(info.minimumDepositAmount)?.amountShort(decimals: self.viteChainTokenDecimals) {
                    self.amountView.textField.placeholder = "\(R.string.localizable.crosschainDepositMin())\(amount) \(symble)"
                }

        }

        addressView.button?.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            FloatButtonsView(targetView: self.addressView.button!, delegate: self, titles:
                [R.string.localizable.sendPageMyAddressTitle(),
                 R.string.localizable.sendPageViteContactsButtonTitle(),
                 R.string.localizable.sendPageScanAddressButtonTitle()]).show()
            }.disposed(by: rx.disposeBag)


        guard let mappedChainTokenDecimals = self.mappedChainTokenDecimals else {
            return
        }
        var decimalsForAmountView = mappedChainTokenDecimals

        amountView.button.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            self.exchangeAll = true
            self.amountView.textField.text = self.trueAmout(for: self.balance).amountFull(decimals: decimalsForAmountView)
            }.disposed(by: rx.disposeBag)

        gasSliderView.feeSlider.rx.value.bind{ [unowned self] _ in
            if self.exchangeAll {
                self.amountView.textField.text = self.trueAmout(for: self.balance).amountFull(decimals: decimalsForAmountView)
            }

            }.disposed(by: rx.disposeBag)


        var tokenInfo: TokenInfo = self.mappedTokenInfo!

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

    func exchangeEthCoinToViteToken(viteAddress: String, amount: Amount, gasPrice: Float) {
        CrossChainDepositETH.init(gatewayInfoService: gatewayInfoService) .deposit(to: viteAddress, totId: ViteConst.instance.crossChain.eth.tokenId, amount: String(amount), gasPrice: gasPrice) {

        }
    }

    func showTip() {
        let symble = self.gatewayInfoService.tokenInfo.gatewayInfo!.mappedToken.symbol
        var htmlString =  R.string.localizable.crosschainDepositAbout(symble, symble);
        let vc = PopViewController(htmlString: htmlString)
        vc.modalPresentationStyle = .overCurrentContext
        let delegate =  StyleActionSheetTranstionDelegate()
        vc.transitioningDelegate = delegate
        present(vc, animated: true, completion: nil)
    }

    func trueAmout(for amount: Amount) -> Amount {
        if self.exchangeAll && self.mappedTokenInfo?.tokenCode == TokenInfo.BuildIn.eth.value.tokenCode {
            let decimals = ( self.mappedChainTokenDecimals!)
            var ethStr = self.gasSliderView.ethStr
            let trueAmout = amount - (ethStr.toAmount(decimals: decimals) ?? Amount(0))
            if trueAmout <= Amount(0) {
                return Amount(0)
            } else {
                return trueAmout
            }
        } else {
            return amount
        }
    }
}

extension CrossChainDepositViewController {
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

        addressView.button?.isHidden = true
        amountView.symbolLabel.text = self.gatewayInfoService.tokenInfo.gatewayInfo?.mappedToken.symbol
        amountView.symbolLabel.textColor = UIColor.init(netHex: 0x3E4A59,alpha: 0.7)
        amountView.button.setTitle(R.string.localizable.crosschainDepositAll(), for: .normal)
        amountView.titleLabel.text = R.string.localizable.crosschainDepositAmount()
        exchangeButton.setTitle(R.string.localizable.crosschainDepositBtnTitle(), for: .normal)
    }

    func setupNavBar() {
        navigationTitleView = createNavigationTitleView()
        let title = R.string.localizable.crosschainDepositHistory()

        let rightItem = UIBarButtonItem(title: title, style: .plain, target: self, action: nil)
        rightItem.setTitleTextAttributes([NSAttributedString.Key.font: Fonts.Font14, NSAttributedString.Key.foregroundColor: Colors.blueBg], for: .normal)
        rightItem.setTitleTextAttributes([NSAttributedString.Key.font: Fonts.Font14, NSAttributedString.Key.foregroundColor: Colors.blueBg], for: .highlighted)
        self.navigationItem.rightBarButtonItem = rightItem
        self.navigationItem.rightBarButtonItem?.rx.tap.bind { [weak self] in

            let vc = CrossChainHistoryViewController()
            vc.style = .desposit
            vc.gatewayInfoService = self?.gatewayInfoService
            var vcs = UIViewController.current?.navigationController?.viewControllers
            vcs?.popLast()
            vcs?.append(vc)
            if let vcs = vcs {
                UIViewController.current?.navigationController?.setViewControllers(vcs, animated: true)
            }

            }.disposed(by: rx.disposeBag)
    }

    func createNavigationTitleView() -> UIView {
        let view = UIView().then {
            $0.backgroundColor = UIColor.white
        }

        let title = R.string.localizable.crosschainDeposit()
        let titleLabel = LabelTipView(title).then {
            $0.titleLab.font = UIFont.systemFont(ofSize: 24)
            $0.titleLab.numberOfLines = 1
            $0.titleLab.adjustsFontSizeToFitWidth = true
            $0.titleLab.textColor = UIColor(netHex: 0x24272B)
        }

        var image: UIImage! = R.image.crosschain_depoist()

        let tokenIconView = UIImageView(image: image)

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

}

extension CrossChainDepositViewController: FloatButtonsViewDelegate {

    func didClick(at index: Int, targetView: UIView) {
        if index == 0 {
            let viewModel = AddressListViewModel.createMyAddressListViewModel()
            let vc = AddressListViewController(viewModel: viewModel)
            vc.selectAddressDrive.drive(addressView.textLabel.rx.text).disposed(by: rx.disposeBag)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        } else if index == 1 {
            let viewModel = AddressListViewModel.createAddressListViewModel(for: CoinType.vite)
            let vc = AddressListViewController(viewModel: viewModel)
            vc.selectAddressDrive.drive(addressView.textLabel.rx.text).disposed(by: rx.disposeBag)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        } else if index == 2 {
            let scanViewController = ScanViewController()
            _ = scanViewController.rx.result.bind {[weak self, scanViewController] result in
                if case .success(let uri) = ViteURI.parser(string: result) {
                    self?.addressView.textLabel.text = uri.address
                    scanViewController.navigationController?.popViewController(animated: true)
                } else {
                    scanViewController.showAlertMessage(result)
                }
            }
            UIViewController.current?.navigationController?.pushViewController(scanViewController, animated: true)
        }
    }
}

extension CrossChainDepositViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if textField == amountView.textField {
            var decimals = self.mappedChainTokenDecimals!
            exchangeAll = false
            let (ret, text) = InputLimitsHelper.allowDecimalPointWithDigitalText(textField.text ?? "", shouldChangeCharactersIn: range, replacementString: string, decimals: min(8, decimals))
            textField.text = text
            return ret
        } else {
            return true
        }
    }
}

extension CrossChainDepositViewController {

    var tokenInfo: TokenInfo {
        return gatewayInfoService.tokenInfo
    }

    var mappedTokenInfo: TokenInfo? {
        return gatewayInfoService.tokenInfo.gatewayInfo?.mappedToken
    }

    var viteChainTokenDecimals: Int {
        return gatewayInfoService.tokenInfo.decimals
    }

    var mappedChainTokenDecimals: Int? {
        return gatewayInfoService.tokenInfo.gatewayInfo?.mappedToken.decimals ?? viteChainTokenDecimals
    }

}
