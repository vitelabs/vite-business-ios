//
//  GatewayDepositViewController.swift
//  Action
//
//  Created by haoshenyang on 2019/6/11.
//

import UIKit

import web3swift
import BigInt
import PromiseKit
import ViteWallet

class GatewayDepositViewController: BaseViewController {

    init(gatewayInfoService: CrossChainGatewayInfoService) {
        self.gatewayInfoService = gatewayInfoService
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var tokenInfo: TokenInfo {
        return self.gatewayInfoService.tokenInfo.gatewayInfo!.mappedToken
    }

    let gatewayInfoService: CrossChainGatewayInfoService

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()

        view.addSubview(addressView)
        view.addSubview(scanQRCodeLable)
        view.addSubview(qrcodeView)
        view.addSubview(pointView)
        view.addSubview(descriptionLabel)


        addressView.titleLabel.text = R.string.localizable.crosschainDepositAddress()

        addressView.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(16)
            m.right.equalToSuperview().offset(-16)
            m.top.equalTo(navigationTitleView!.snp.bottom).offset(20)
        }

        scanQRCodeLable.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview()
            m.top.equalTo(addressView.snp.bottom).offset(30)
        }

        qrcodeView.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview()
            m.top.equalTo(scanQRCodeLable.snp.bottom).offset(29)
        }

        pointView.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(20)
            m.height.width.equalTo(6)
            m.top.equalTo(qrcodeView.snp.bottom).offset(29)
        }

        descriptionLabel.snp.makeConstraints { (m) in
            m.left.equalTo(pointView.snp.right).offset(5)
            m.top.equalTo(pointView.snp.bottom).offset(-10)
            m.right.equalToSuperview().offset(-20)
        }

        view.displayLoading()
        self.gatewayInfoService.depositInfo(viteAddress: HDWalletManager.instance.account?.address ?? "")
            .done { [weak self] (info) in
                guard let `self` = self else { return }
                self.view.hideLoading()
                self.addressView.textLabel.text = info.depositAddress
                self.qrcodeView.bind(tokenInfo: TokenInfo.eth, content: info.depositAddress)
                guard let minimumDepositAmountStr = Amount(info.minimumDepositAmount)?.amountShort(decimals: self.tokenInfo.decimals) else {
                    return
                }
                let subStirng = minimumDepositAmountStr + self.tokenInfo.symbol
                let fullString =  R.string.localizable.crosschainDepositMinAmountDesc(subStirng)
                let range = NSString.init(string: fullString).range(of: minimumDepositAmountStr)
                let attributeString = NSMutableAttributedString.init(string: fullString)
                attributeString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.init(netHex: 0x007AFF)], range: range)
                self.descriptionLabel.attributedText = attributeString
            }.catch { (error) in
                self.view.hideLoading()
                Toast.show(error.localizedDescription)
        }

        addressView.button?.rx.tap.bind { [unowned self] in
            if let address = self.addressView.textLabel.text{
                UIPasteboard.general.string = address
                Toast.show(R.string.localizable.walletHomeToastCopyAddress())
            }
        }

    }


    private func setupNavBar() {
        navigationTitleView = createNavigationTitleView()

        let rightItem = UIBarButtonItem(title: R.string.localizable.crosschainDepositHistory(), style: .plain, target: self, action: nil)
        rightItem.setTitleTextAttributes([NSAttributedString.Key.font: Fonts.Font14, NSAttributedString.Key.foregroundColor: Colors.blueBg], for: .normal)
        rightItem.setTitleTextAttributes([NSAttributedString.Key.font: Fonts.Font14, NSAttributedString.Key.foregroundColor: Colors.blueBg], for: .highlighted)
        self.navigationItem.rightBarButtonItem = rightItem
        self.navigationItem.rightBarButtonItem?.rx.tap.bind { [weak self] in
            guard let `self` = self else {
                return
            }
            let vc = CrossChainHistoryViewController()
            vc.style = .desposit
            vc.gatewayInfoService = self.gatewayInfoService
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)

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

        let tokenIconView = UIImageView(image:  R.image.crosschain_depoist())

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

    let addressView = EthViteExchangeViteAddressView.addressView(style: .copyButton)

    let scanQRCodeLable = UILabel().then {
        $0.text = R.string.localizable.crosschainDepositScanAddress()
        $0.numberOfLines = 0
        $0.font = UIFont.boldSystemFont(ofSize: 18)

    }

    let qrcodeView = QRCodeViewWithTokenIcon().then {
        $0.snp.makeConstraints { m in
            m.size.equalTo(CGSize(width: 170, height: 170))
        }
    }

    let descriptionLabel = UILabel().then {
        $0.text = R.string.localizable.crosschainDepositMinAmountDesc("-")
        $0.numberOfLines = 0
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59,alpha: 0.8)
    }

    let descriptionTitleLabel = UILabel().then {
        $0.text = R.string.localizable.grinNoticeTitle()
        $0.numberOfLines = 0
        $0.font = UIFont.boldSystemFont(ofSize: 14)
    }

    let pointView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(netHex:0x007AFF)
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
        return view
    }()


    func showTip() {
        var htmlString = R.string.localizable.crosschainDepositOtherAbout(self.tokenInfo.symbol)

        let vc = PopViewController(htmlString: htmlString)
        vc.modalPresentationStyle = .overCurrentContext
        let delegate =  StyleActionSheetTranstionDelegate()
        vc.transitioningDelegate = delegate
        present(vc, animated: true, completion: nil)
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
