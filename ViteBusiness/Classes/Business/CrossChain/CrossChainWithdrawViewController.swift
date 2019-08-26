//
//  GatewayWithdrawViewController.swift
//  Action
//
//  Created by haoshenyang on 2019/6/11.
//

import UIKit
import BigInt
import ViteWallet
import PromiseKit
import web3swift

import RxSwift
import RxCocoa

class GatewayWithdrawViewController: BaseViewController {

    init(gateWayInfoService: CrossChainGatewayInfoService, withdrawInfo: WithdrawInfo) {
        self.gateWayInfoService =  gateWayInfoService
        self.withDrawInfo = withdrawInfo
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var gateWayInfoService: CrossChainGatewayInfoService
    var withDrawInfo: WithdrawInfo

    var token: TokenInfo {
        return gateWayInfoService.tokenInfo
    }

    var withTokenInfo: TokenInfo {
        return gateWayInfoService.tokenInfo.gatewayInfo!.mappedToken
    }

    var balance: Amount = Amount(0)

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        kas_activateAutoScrollingForView(scrollView)
    }

    // View
    lazy var scrollView = ScrollableView(insets: UIEdgeInsets(top: 10, left: 24, bottom: 30, right: 24)).then {
        $0.layer.masksToBounds = false
        $0.stackView.spacing = 10
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }

    let abstractView = WalletAbstractView()

    lazy var addressView: AddressTextViewView =  AddressTextViewView().then {
        if self.gateWayInfoService.tokenInfo.gatewayInfo?.mappedToken.coinType != .eth {
            $0.addButton.setImage(R.image.icon_button_address_scan(), for: .normal)
        }
    }

    let labelView = AddressTextViewView().then { labelView in
        labelView.addButton.setImage(R.image.icon_button_address_scan(), for: .normal)
    }

    lazy var amountView = EthViteExchangeAmountView().then { amountView in
        amountView.textField.keyboardType = .decimalPad
        amountView.symbolLabel.text = self.gateWayInfoService.tokenInfo.gatewayInfo?.mappedToken.symbol
        amountView.symbolLabel.textColor = UIColor.init(netHex: 0x3E4A59,alpha: 0.7)
        amountView.button.setTitle(R.string.localizable.crosschainWithdrawAll(), for: .normal)
        amountView.titleLabel.text = R.string.localizable.crosschainWithdrawAmount()
    }
    
    lazy var feeView: TitleTipContentSymbleItemView = {
        let feeView = TitleTipContentSymbleItemView()
        feeView.titleLabel.text = R.string.localizable.confirmTransactionFeeTitle()
        feeView.symbolLabel.text = self.withTokenInfo.symbol
        feeView.contentLabel.text = ""
        return feeView
    }()

    let withdrawButton = UIButton.init(style: .blue, title: R.string.localizable.crosschainWithdrawBtnTitle())

    let rightBarItemBtn = UIButton.init(style: .navigationItemCustomView, title: R.string.localizable.crosschainWithdrawHistory())

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpview()
        bind()
        self.configWithdrawInfo()
    }

    func setUpview()  {
        navigationTitleView = PageTitleView.titleAndIcon(title: R.string.localizable.crosschainWithdraw(), icon: R.image.crosschain_withdrwa())
        navigationTitleView?.backgroundColor = UIColor.white

        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBarItemBtn)
        amountView.symbolLabel.textColor = UIColor.init(netHex: 0x3E4A59,alpha: 0.7)
        amountView.textField.keyboardType = .decimalPad

        view.addSubview(scrollView)
        view.addSubview(withdrawButton)


        scrollView.snp.makeConstraints { (m) in
            m.top.equalTo(navigationTitleView!.snp.bottom)
            m.left.right.equalTo(view)
            m.bottom.equalTo(withdrawButton.snp.top)
        }


        scrollView.stackView.addArrangedSubview(abstractView)
        scrollView.stackView.addPlaceholder(height: 30)
        scrollView.stackView.addArrangedSubview(addressView)

        if let labelname = self.withDrawInfo.labelName {
            scrollView.stackView.addPlaceholder(height: 10)
            scrollView.stackView.addArrangedSubview(labelView)
            labelView.snp.makeConstraints { (m) in
                m.height.equalTo(78)
            }
            labelView.titleLabel.text = labelname
        }
        scrollView.stackView.addArrangedSubview(amountView)
        scrollView.stackView.addArrangedSubview(feeView)

        abstractView.tl0.text = R.string.localizable.sendPageMyAddressTitle()
        abstractView.cl0.text = HDWalletManager.instance.account?.address
        abstractView.tl1.text = R.string.localizable.sendPageMyBalanceTitle()

        abstractView.snp.makeConstraints { (m) in
            m.height.equalTo(138)
        }

        addressView.snp.makeConstraints { (m) in
            m.height.equalTo(78)
        }

        amountView.snp.makeConstraints { (m) in
            m.height.equalTo(78)
        }

        feeView.snp.makeConstraints { (m) in
            m.height.equalTo(78)
        }

        withdrawButton.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview().inset(24)
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom).offset(-24)
        }

        let toolbar = UIToolbar()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let next: UIBarButtonItem = UIBarButtonItem(title: R.string.localizable.sendPageAmountToolbarButtonTitle(), style: .done, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: R.string.localizable.finish(), style: .done, target: nil, action: nil)
        toolbar.items = [flexSpace, done]

        toolbar.sizeToFit()
        done.rx.tap.bind { [weak self] in self?.amountView.textField.resignFirstResponder() }.disposed(by: rx.disposeBag)
        amountView.textField.inputAccessoryView = toolbar
        amountView.textField.delegate = self

        if withDrawInfo.labelName != nil {
            addressView.textView.kas_setReturnAction(.next(responder: labelView.textView))
            labelView.textView.kas_setReturnAction(.next(responder: amountView.textField))
        } else {
            addressView.textView.kas_setReturnAction(.next(responder: amountView.textField))
        }

    }

    func bind() {
        addressView.addButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            if self.gateWayInfoService.tokenInfo.gatewayInfo?.mappedToken.coinType == .eth {
                FloatButtonsView(targetView: self.addressView.addButton, delegate: self, titles:
                    [R.string.localizable.crosschainWithdrawEthMyAddress(),
                     R.string.localizable.ethSendPageEthContactsButtonTitle(),
                     R.string.localizable.sendPageScanAddressButtonTitle()]).show()

            } else {
                self.scanAddress()
            }
            }.disposed(by: rx.disposeBag)

        labelView.addButton.rx.tap.bind { [weak self] in
            let scanViewController = ScanViewController()
            scanViewController.reactor = ScanViewReactor()
            _ = scanViewController.rx.result.bind {[weak self, scanViewController] result in
                if case .success(let uri) = ViteURI.parser(string: result) {
                    self?.labelView.textView.text = uri.address
                } else if case .success(let uri) = ETHURI.parser(string: result) {
                    self?.labelView.textView.text = uri.address
                } else {
                    self?.labelView.textView.text = result
                }
                scanViewController.navigationController?.popViewController(animated: true)
            }
            UIViewController.current?.navigationController?.pushViewController(scanViewController, animated: true)
        }.disposed(by: rx.disposeBag)

        rightBarItemBtn.rx.tap.bind { [unowned self] in
            let vc = CrossChainHistoryViewController()
            vc.style = .withdraw
            vc.gatewayInfoService = self.gateWayInfoService
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        }

        withdrawButton.rx.tap.bind { [weak self] in
            self?.withdraw()
        }

        feeView.tipButton.rx.tap.bind { [weak self] in
            Alert.show(title: R.string.localizable.crosschainWithdrawAboutfee(), message: R.string.localizable.crosschainWithdrawFeeDesc(), actions: [
                (.default(title: R.string.localizable.confirm()), nil),
                ])
        }

        ViteBalanceInfoManager.instance.balanceInfoDriver(forViteTokenId: self.token.id)
            .drive(onNext: { [weak self] balanceInfo in
                guard let `self` = self else { return }
                self.balance = balanceInfo?.balance ?? self.balance
                self.abstractView.cl1.text = self.balance.amountFullWithGroupSeparator(decimals: self.token.decimals)
            }).disposed(by: rx.disposeBag)


        amountView.textField.rx.text
            .throttle(0.5, scheduler: MainScheduler.instance).bind { [weak self] text in
                guard let `self` = self else { return }

                guard let viteAddress = HDWalletManager.instance.account?.address else {
                    return
                }
                guard let text = text, !text.isEmpty else {
                    self.feeView.contentLabel.text = nil
                    return
                }

                let decimals = self.withTokenInfo.decimals

                guard let amountString = self.amountView.textField.text, !amountString.isEmpty,
                    let amount = amountString.toAmount(decimals: decimals) else {
                        Toast.show(R.string.localizable.sendPageToastAmountEmpty())
                        return
                }

                let amountStr = amount.amountFull(decimals: 0)
                self.gateWayInfoService.withdrawFee(viteAddress: viteAddress, amount: amountStr, containsFee: false)
                .done { [weak self] fee in
                    guard let `self` = self else { return }
                    self.feeView.contentLabel.text = Amount(fee)?.amountShort(decimals: self.token.decimals)
                }.catch({ (error) in
                    Toast.show(error.localizedDescription)
                })
        }

        amountView.button.rx.tap.bind { [weak self] in
            guard let balance = self?.balance else { return }
            guard let viteAddress = HDWalletManager.instance.account?.address else {
                return
            }

            self?.view.displayLoading()
            let amountStr = balance.amountFull(decimals: 0)
            self?.gateWayInfoService.withdrawFee(viteAddress: viteAddress, amount: amountStr, containsFee: true)
                .done { [weak self] fee in
                    guard let `self` = self else { return }
                    guard let feeAmount = Amount(fee) else {return }
                    self.feeView.contentLabel.text = feeAmount.amountShort(decimals: self.token.decimals)
                    self.amountView.textField.text = (self.balance - feeAmount).amount(decimals: self.gateWayInfoService.tokenInfo.decimals, count: min(8, self.gateWayInfoService.tokenInfo.decimals))
                }.catch({ (error) in
                    Toast.show(error.localizedDescription)
                })
                .finally {
                    self?.view.hideLoading()
            }

        }.disposed(by: rx.disposeBag)
    }

    func withdraw()  {

        let address = self.addressView.textView.text ?? ""

        guard let amountString = self.amountView.textField.text, !amountString.isEmpty,
            let decimals = self.gateWayInfoService.tokenInfo.gatewayInfo?.mappedToken.decimals,
            let a = amountString.toAmount(decimals: decimals) else {
                Toast.show(R.string.localizable.sendPageToastAmountEmpty())
                return
        }

        let amount: Amount = a

        guard amount > 0 else {
            Toast.show(R.string.localizable.sendPageToastAmountZero())
            return
        }

        guard amount <= self.balance else {
            Toast.show(R.string.localizable.sendPageToastAmountError())
            return
        }

        guard let viteAddress = HDWalletManager.instance.account?.address else {
            return
        }
        guard let account = HDWalletManager.instance.account else {
            return
        }

        guard let withDrawAddress = addressView.textView.text else { return }

        let metalInfo = gateWayInfoService.getMetaInfo()
        let verify = gateWayInfoService.verifyWithdrawAddress(withdrawAddress: withDrawAddress)
        let withdrawInfo = gateWayInfoService.withdrawInfo(viteAddress: viteAddress)
        let fee = gateWayInfoService.withdrawFee(viteAddress: viteAddress, amount: amount.amountFull(decimals: 0), containsFee: false)

        view.displayLoading()
        when(fulfilled: metalInfo, verify, withdrawInfo, fee)
            .done { [weak self] args in
                guard let `self` = self else { return }
                self.view.hideLoading()
                let (metalInfo, verify, info, feeStr) = args
                guard metalInfo.withdrawState == .open else {
                    Toast.show("withdrawState is not open")
                    return
                }

                guard verify == true else {
                    Toast.show(R.string.localizable.sendPageToastAddressError())
                    return
                }

                if !info.minimumWithdrawAmount.isEmpty,
                    let min = Amount(info.minimumWithdrawAmount) {
                guard amount >= min else {                        Toast.show("\(R.string.localizable.crosschainWithdrawMin())\(min.amountShort(decimals: self.gateWayInfoService.tokenInfo.gatewayInfo!.mappedToken.decimals))")
                        return
                    }
                }

                if !info.maximumWithdrawAmount.isEmpty,
                    let max = Amount(info.maximumWithdrawAmount) {
                    guard amount <= max else {
                        let decimals = self.gateWayInfoService.tokenInfo.gatewayInfo!.mappedToken.decimals
                        let numString = max.amount(decimals: decimals, count: min(8,decimals), groupSeparator: true)
                        Toast.show(R.string.localizable.crosschainWithdrawGatewayispoor(numString, self.gateWayInfoService.tokenInfo.gatewayInfo!.mappedToken.symbol))
                        return
                    }
                }

                let amountWithFee = amount + (Amount(feeStr) ?? Amount(0))

                let veptype: UInt16 = 3011
                var tpye: UInt8 = UInt8(metalInfo.type.rawValue)
                let withDrawAddressData = withDrawAddress.data(using: .utf8) ?? Data()

                var data = Data()

                if tpye == 1 {
                    data.append(Data(veptype.toBytes))
                    data.append(Data(tpye.toBytes))

                    let addressSize: UInt8  = UInt8(withDrawAddressData.count)
                    data.append(Data(addressSize.toBytes))
                    data.append(withDrawAddressData)


                    let label = self.labelView.textView.text ?? ""
                    let labelData = label.data(using: .utf8) ?? Data()

                    var labelSize: UInt8 = UInt8(labelData.count)

                    data.append(Data(labelSize.toBytes))
                    data.append(labelData )

                } else {
                    data.append(Data(veptype.toBytes))
                    data.append(Data(tpye.toBytes))
                    data.append(withDrawAddressData)
                }


                Workflow.sendTransactionWithConfirm(account: account, toAddress: info.gatewayAddress, tokenInfo: self.token, amount: amountWithFee, data: data, utString:nil,  completion: { (result) in
                    switch result {
                    case .success(_):
                        let vc = CrossChainHistoryViewController()
                        vc.style = .withdraw
                        vc.gatewayInfoService = self.gateWayInfoService
                        UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
                    case .failure(let error):
                        Toast.show(error.localizedDescription)
                    }

                })
            }.catch { [weak self](error) in
                self?.view.hideLoading()
                Toast.show(error.localizedDescription)
        }
    }

    func scanAddress() {
        let scanViewController = ScanViewController()
        scanViewController.reactor = ScanViewReactor()
        _ = scanViewController.rx.result.bind {[weak self, scanViewController] result in
            if case .success(let uri) = ViteURI.parser(string: result) {
                self?.addressView.textView.text = uri.address
            } else if case .success(let uri) = ETHURI.parser(string: result) {
                self?.addressView.textView.text = uri.address
            } else {
                self?.addressView.textView.text = result
            }
            scanViewController.navigationController?.popViewController(animated: true)
        }
        UIViewController.current?.navigationController?.pushViewController(scanViewController, animated: true)
    }

}


extension GatewayWithdrawViewController: FloatButtonsViewDelegate {
    func didClick(at index: Int) {
        if self.gateWayInfoService.tokenInfo.gatewayInfo?.mappedToken.coinType == .eth {
            if index == 0 {
                addressView.textView.text = EtherWallet.shared.ethereumAddress?.address
            } else if index == 1 {
                let viewModel = AddressListViewModel.createAddressListViewModel(for: CoinType.eth)
                let vc = AddressListViewController(viewModel: viewModel)
                vc.selectAddressDrive.drive(addressView.textView.rx.text).disposed(by: rx.disposeBag)
                UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
            } else if index == 2 {
                scanAddress()
            }
        }
    }

    func configWithdrawInfo()  {
        let info = self.withDrawInfo
        guard
            let decimals = self.gateWayInfoService.tokenInfo.gatewayInfo?.mappedToken.decimals,
            let symble = self.gateWayInfoService.tokenInfo.gatewayInfo?.mappedToken.symbol else { return }
        if !info.minimumWithdrawAmount.isEmpty,
            let amount = Amount(info.minimumWithdrawAmount)?.amountShort(decimals: decimals) {
            self.amountView.textField.placeholder = "\(R.string.localizable.crosschainWithdrawMin())\(amount) \(symble)"
        }

    }
}

extension GatewayWithdrawViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == amountView.textField {
            let (ret, text) = InputLimitsHelper.allowDecimalPointWithDigitalText(textField.text ?? "", shouldChangeCharactersIn: range, replacementString: string, decimals: min(8, gateWayInfoService.tokenInfo.decimals))
            textField.text = text
            return ret
        } else {
            return true
        }
    }
}
