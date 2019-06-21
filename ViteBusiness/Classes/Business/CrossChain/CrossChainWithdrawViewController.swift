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
import Web3swift
import ViteEthereum
import RxSwift
import RxCocoa

class GatewayWithdrawViewController: BaseViewController {

    init(gateWayInfoService: CrossChainGatewayInfoService, tokenInfo:TokenInfo, withTokenInfo: TokenInfo) {
        self.gateWayInfoService =  gateWayInfoService
        self.token = tokenInfo
        self.withTokenInfo = withTokenInfo
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var gateWayInfoService: CrossChainGatewayInfoService
    var token: TokenInfo
    var withTokenInfo: TokenInfo

    var balance: Amount = Amount(0)


    let abstractView = WalletAbstractView()
    var addressView: AddressTextViewView =  AddressTextViewView()
    lazy var amountView = SendAmountView(amount: "", token: token)

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
        withDrawInfo()
    }

    func setUpview()  {
        navigationTitleView = PageTitleView.titleAndIcon(title: R.string.localizable.crosschainWithdraw(), icon: R.image.icon_vite_exchange())

        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightBarItemBtn)

        view.addSubview(abstractView)
        view.addSubview(addressView)
        view.addSubview(amountView)
        view.addSubview(feeView)
        view.addSubview(withdrawButton)

        abstractView.tl0.text = R.string.localizable.sendPageMyBalanceTitle()

        abstractView.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview().inset(24)
            m.top.equalTo(navigationTitleView!.snp.bottom)
            m.height.equalTo(76)
        }

        addressView.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview().inset(24)
            m.top.equalTo(abstractView.snp.bottom).offset(40)
            m.height.equalTo(78)
        }

        amountView.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview().inset(24)
            m.top.equalTo(addressView.snp.bottom)
            m.height.equalTo(78)
        }

        feeView.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview().inset(24)
            m.top.equalTo(amountView.snp.bottom)
            m.height.equalTo(78)
        }

        withdrawButton.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview().inset(24)
            m.bottom.equalTo(view.snp_bottom).offset(-24)
        }

    }

    func bind() {
        addressView.addButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            FloatButtonsView(targetView: self.addressView.addButton, delegate: self, titles:
                [R.string.localizable.crosschainWithdrawEthMyAddress(),
                 R.string.localizable.ethSendPageEthContactsButtonTitle(),
                 R.string.localizable.sendPageScanAddressButtonTitle()]).show()
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

        ViteBalanceInfoManager.instance.balanceInfoDriver(forViteTokenId: self.token.id)
            .drive(onNext: { [weak self] balanceInfo in
                guard let `self` = self else { return }
                self.balance = balanceInfo?.balance ?? self.balance
                self.abstractView.cl0.text = self.balance.amountFullWithGroupSeparator(decimals: self.token.decimals)
            }).disposed(by: rx.disposeBag)


        amountView.textField.rx.text
            .throttle(0.5, scheduler: MainScheduler.instance).bind { [weak self] text in
            guard let `self` = self else { return }

            guard let viteAddress = HDWalletManager.instance.account?.address else {
                return
            }
            guard let text = text else {
                self.feeView.contentLabel.text = nil
                return
            }
            self.gateWayInfoService.withdrawFee(viteAddress: viteAddress, amount: text, containsFee: false)
                .done { fee in
                    self.feeView.contentLabel.text = Amount(fee)?.amountShort(decimals: self.token.decimals)
                }.catch({ (error) in
                    print(error.localizedDescription)
                })
        }
    }

    func withdraw()  {

        let address = self.addressView.textView.text ?? ""

        guard let amountString = self.amountView.textField.text, !amountString.isEmpty,
            let a = amountString.toAmount(decimals: TokenInfo.eth.decimals) else {
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


        when(fulfilled: metalInfo, verify, withdrawInfo)
            .done { [weak self] args in
                guard let `self` = self else { return }

                let (metalInfo, verify, info) = args
                guard metalInfo.withdrawState == .open else {
                    Toast.show("withdrawState is not open")
                    return
                }

                guard verify == true else {
                    Toast.show("wrong address")
                    return
                }

                if !info.minimumWithdrawAmount.isEmpty,
                    let min = info.minimumWithdrawAmount.toAmount(decimals: self.withTokenInfo.decimals) {
                    guard amount >= min else {
                        Toast.show("less than min amount")
                        return
                    }
                }

                if !info.maximumWithdrawAmount.isEmpty,
                    let max = info.maximumWithdrawAmount.toAmount(decimals: self.withTokenInfo.decimals) {
                    guard amount <= max else {
                        Toast.show("bigger than max amount")
                        return
                    }
                }

                let veptype: UInt16 = 3011
                let tpye: UInt8 = 0
                let withDrawAddressData = withDrawAddress.data(using: .utf8)

                var data = Data()
                data.append(Data(veptype.toBytes))
                data.append(Data(tpye.toBytes))
                data.append(withDrawAddressData!)

                Workflow.sendTransactionWithConfirm(account: account, toAddress: info.gatewayAddress, tokenInfo: self.token, amount: amount, data: data, completion: { (_) in

                })
            }.catch { (error) in
                Toast.show(error.localizedDescription)
        }
    }


}


extension GatewayWithdrawViewController: FloatButtonsViewDelegate {
    func didClick(at index: Int) {
        if index == 0 {
            addressView.textView.text = EtherWallet.shared.ethereumAddress?.address
        } else if index == 1 {
            let viewModel = AddressListViewModel.createAddressListViewModel(for: CoinType.eth)
            let vc = AddressListViewController(viewModel: viewModel)
            vc.selectAddressDrive.drive(addressView.textView.rx.text).disposed(by: rx.disposeBag)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        } else if index == 2 {
            let scanViewController = ScanViewController()
            scanViewController.reactor = ScanViewReactor()
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


    func withDrawInfo() {
        guard let address = HDWalletManager.instance.account?.address else {
            return
        }
        gateWayInfoService.withdrawInfo(viteAddress: address)
            .done { [weak self] (info) in
                guard let `self` = self else { return }
                if !info.minimumWithdrawAmount.isEmpty,
                let amount = Amount(info.minimumWithdrawAmount)?.amountShort(decimals: TokenInfo.eth.decimals) {
                    self.amountView.textField.placeholder = "\(R.string.localizable.crosschainWithdrawMin())\(amount)"
                }
        }

    }
}
