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

    enum ExchangeType {
        case erc20ViteTokenToViteCoin
        case ethChainToViteToken
    }

    var gatewayInfoService: CrossChainGatewayInfoService?
    var depositInfo: DepositInfo?

    var tokenInfo : TokenInfo? {
        return gatewayInfoService?.tokenInfo
    }


    let myEthAddress = EtherWallet.shared.address!
    var exchangeAll = false
    var balance = Amount(0)
    var exchangeType: ExchangeType = .erc20ViteTokenToViteCoin

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
        ETHBalanceInfoManager.instance.unregisterFetch(tokenInfos: [TokenInfo.viteERC20])
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    // View
    lazy var scrollView = ScrollableView(insets: UIEdgeInsets(top: 10, left: 24, bottom: 50, right: 24)).then {
        $0.layer.masksToBounds = false
        $0.stackView.spacing = 0
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

    let addressView = EthViteExchangeViteAddressView.addressView(style: .chouseAddressButton).then {
        $0.textLabel.text = HDWalletManager.instance.account?.address ?? ""
    }
    let amountView = EthViteExchangeAmountView().then {
        $0.textField.keyboardType = .decimalPad
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

        if exchangeType == .ethChainToViteToken {
            addressView.button?.isHidden = true
            amountView.symbolLabel.text = self.gatewayInfoService?.tokenInfo.gatewayInfo?.mappedToken.symbol
            amountView.symbolLabel.textColor = UIColor.init(netHex: 0x3E4A59,alpha: 0.7)
            amountView.button.setTitle(R.string.localizable.crosschainDepositAll(), for: .normal)
            amountView.titleLabel.text = R.string.localizable.crosschainDepositAmount()
            exchangeButton.setTitle(R.string.localizable.crosschainDepositBtnTitle(), for: .normal)
        }
    }

    private func setupNavBar() {
        navigationTitleView = createNavigationTitleView()
        let title = exchangeType == .erc20ViteTokenToViteCoin ? R.string.localizable.ethViteExchangePageExchangeHistoryButtonTitle() : R.string.localizable.crosschainDepositHistory()

        let rightItem = UIBarButtonItem(title: title, style: .plain, target: self, action: nil)
        rightItem.setTitleTextAttributes([NSAttributedString.Key.font: Fonts.Font14, NSAttributedString.Key.foregroundColor: Colors.blueBg], for: .normal)
        rightItem.setTitleTextAttributes([NSAttributedString.Key.font: Fonts.Font14, NSAttributedString.Key.foregroundColor: Colors.blueBg], for: .highlighted)
        self.navigationItem.rightBarButtonItem = rightItem
        self.navigationItem.rightBarButtonItem?.rx.tap.bind { [weak self] in
            if self?.exchangeType == .erc20ViteTokenToViteCoin {
                var infoUrl = "\(ViteConst.instance.eth.explorer)/address/\(HDWalletManager.instance.ethAddress ?? "")#tokentxns"
                guard let url = URL(string: infoUrl) else { return }
                let vc = WKWebViewController.init(url: url)
                UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
            } else if self?.exchangeType == .ethChainToViteToken {
                let vc = CrossChainHistoryViewController()
                vc.style = .desposit
                vc.gatewayInfoService = self?.gatewayInfoService
                UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
            }

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

            let decimals = self.exchangeType == .erc20ViteTokenToViteCoin ? TokenInfo.viteERC20.decimals : (self.gatewayInfoService?.tokenInfo.gatewayInfo?.mappedToken.decimals)!
            guard let amountString = self.amountView.textField.text, !amountString.isEmpty,
                let a = amountString.toAmount(decimals: decimals) else {
                    Toast.show(R.string.localizable.sendPageToastAmountEmpty())
                    return
            }

            let amount: Amount
            if self.exchangeAll {
                amount = self.trueAmout(for: self.balance)
            } else {
                amount = a
            }

            if  let depositInfo = self.depositInfo,
                let minimumDepositAmount = Amount(depositInfo.minimumDepositAmount ?? ""), amount < minimumDepositAmount {
                let minStr = minimumDepositAmount.amountShort(decimals: self.gatewayInfoService?.tokenInfo.gatewayInfo?.mappedToken.decimals ?? 0)
                let minSymbol = self.gatewayInfoService?.tokenInfo.gatewayInfo?.mappedToken.symbol ?? ""
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

            if self.exchangeType == .erc20ViteTokenToViteCoin {
                self.exchangeErc20ViteTokenToViteCoin(viteAddress: address, amount: amount, gasPrice: Float(self.gasSliderView.value))
            } else if self.exchangeType == .ethChainToViteToken {
                self.exchangeEthCoinToViteToken(viteAddress: address, amount: amount, gasPrice: Float(self.gasSliderView.value))
            }

            }.disposed(by: rx.disposeBag)


        if exchangeType == .erc20ViteTokenToViteCoin {
            ETHBalanceInfoManager.instance.balanceInfoDriver(for: TokenInfo.viteERC20.tokenCode)
                .drive(onNext: { [weak self] ret in
                    guard let `self` = self else { return }
                    self.balance = ret?.balance ?? self.balance
                    let text = self.balance.amountFullWithGroupSeparator(decimals: TokenInfo.viteERC20.decimals)
                    self.headerView.balanceLabel.text = text
                    self.amountView.textField.placeholder = R.string.localizable.ethViteExchangePageAmountPlaceholder(text)
                    if self.exchangeAll  {
                        self.amountView.textField.text = self.headerView.balanceLabel.text
                    }

                }).disposed(by: rx.disposeBag)
        } else if exchangeType == .ethChainToViteToken {
            ETHBalanceInfoManager.instance.balanceInfoDriver(for: self.gatewayInfoService!.tokenInfo.gatewayInfo!.mappedToken
                .tokenCode)
                .drive(onNext: { [weak self] ret in
                    guard let `self` = self else { return }
                    self.balance = ret?.balance ?? self.balance
                    let text = self.balance.amountFullWithGroupSeparator(decimals: self.gatewayInfoService!.tokenInfo.gatewayInfo!.mappedToken.decimals)
                    self.headerView.balanceLabel.text = text

                    if self.exchangeAll {
//                        self.amountView.textField.text = self.headerView.balanceLabel.text
                    }

                }).disposed(by: rx.disposeBag)

            self.gatewayInfoService?.depositInfo(viteAddress: HDWalletManager.instance.account?.address ?? "")
                .done { [weak self] (info) in
                    guard let `self` = self else { return }
                    self.depositInfo = info
                    guard let decimals = self.gatewayInfoService?.tokenInfo.gatewayInfo?.mappedToken.decimals ,
                    let symble = self.gatewayInfoService?.tokenInfo.gatewayInfo?.mappedToken.symbol else {
                        return
                    }
                    if let amount = Amount(info.minimumDepositAmount)?.amountShort(decimals: decimals) {
                        self.amountView.textField.placeholder = "\(R.string.localizable.crosschainDepositMin())\(amount)\(symble)"
                    }

            }
        }


        addressView.button?.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            FloatButtonsView(targetView: self.addressView.button!, delegate: self, titles:
                [R.string.localizable.sendPageMyAddressTitle(),
                 R.string.localizable.sendPageViteContactsButtonTitle(),
                 R.string.localizable.sendPageScanAddressButtonTitle()]).show()
            }.disposed(by: rx.disposeBag)


        var decimals = TokenInfo.viteERC20.decimals
        if self.exchangeType == .ethChainToViteToken {
            decimals = self.gatewayInfoService!.tokenInfo.decimals
        }

        amountView.button.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            self.exchangeAll = true
            self.amountView.textField.text = self.trueAmout(for: self.balance).amountFull(decimals: decimals)
            }.disposed(by: rx.disposeBag)

        gasSliderView.feeSlider.rx.value.bind{ [unowned self] _ in
            if self.exchangeAll {
                self.amountView.textField.text = self.trueAmout(for: self.balance).amountFull(decimals: decimals)
            }

            }.disposed(by: rx.disposeBag)


        var tokenInfo: TokenInfo
        if self.exchangeType == .erc20ViteTokenToViteCoin {
            tokenInfo = TokenInfo.viteERC20
        } else {
            tokenInfo = self.gatewayInfoService!.tokenInfo.gatewayInfo!.mappedToken
        }

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

        let title = exchangeType == .erc20ViteTokenToViteCoin ? R.string.localizable.ethViteExchangePageTitle() : R.string.localizable.crosschainDeposit()
        let titleLabel = LabelTipView(title).then {
            $0.titleLab.font = UIFont.systemFont(ofSize: 24)
            $0.titleLab.numberOfLines = 1
            $0.titleLab.adjustsFontSizeToFitWidth = true
            $0.titleLab.textColor = UIColor(netHex: 0x24272B)
        }

        var image: UIImage!
        if self.exchangeType == .erc20ViteTokenToViteCoin {
            image = R.image.icon_vite_exchange()
        } else {
            image = R.image.crosschain_depoist()
        }
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

    func showTip() {
        var htmlString = R.string.localizable.popPageTipEthViteExchange()
        if self.exchangeType == .ethChainToViteToken {
            let symble = self.gatewayInfoService!.tokenInfo.gatewayInfo!.mappedToken.symbol
            htmlString =   R.string.localizable.crosschainDepositAbout(symble, symble);
        }
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
                if let e = error as? DisplayableError {
                    Toast.show(e.errorMessage)
                } else {
                    Toast.show((error as NSError).localizedDescription)
                }
            }
        })
    }

    func exchangeEthCoinToViteToken(viteAddress: String, amount: Amount, gasPrice: Float) {
        CrossChainDepositETH.init(gatewayInfoService: gatewayInfoService!) .deposit(to: viteAddress, totId: ViteConst.instance.crossChain.eth.tokenId, amount: String(amount), gasPrice: gasPrice) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }

    func trueAmout(for amount: Amount) -> Amount {
        if self.exchangeAll && self.exchangeType == .ethChainToViteToken &&  self.gatewayInfoService?.tokenInfo.gatewayInfo?.mappedToken.tokenCode == TokenInfo.eth.tokenCode {
            let decimals = self.exchangeType == .erc20ViteTokenToViteCoin ? TokenInfo.viteERC20.decimals : ( self.gatewayInfoService!.tokenInfo.gatewayInfo!.mappedToken.decimals)
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

extension EthViteExchangeViewController: FloatButtonsViewDelegate {
    func didClick(at index: Int) {
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
            scanViewController.reactor = ScanViewReactor()
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

extension EthViteExchangeViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if textField == amountView.textField {
            var decimals = TokenInfo.viteERC20.decimals
            if let d =   self.gatewayInfoService?.tokenInfo.decimals {
                decimals = d
            }
            exchangeAll = false
            let (ret, text) = InputLimitsHelper.allowDecimalPointWithDigitalText(textField.text ?? "", shouldChangeCharactersIn: range, replacementString: string, decimals: min(8, decimals))
            textField.text = text
            return ret
        } else {
            return true
        }
    }
}
