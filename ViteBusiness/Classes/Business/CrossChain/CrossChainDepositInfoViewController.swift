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
import RxSwift
import RxCocoa

class GatewayDepositInfoViewController: BaseViewController {

    init(gatewayInfoService: CrossChainGatewayInfoService, depositInfo: DepositInfo) {
        self.gatewayInfoService = gatewayInfoService
        self.depositInfo = BehaviorRelay(value: depositInfo)
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var addressView = EthViteExchangeViteAddressView.addressView(style: .copyButton).then { addressView in
        addressView.titleLabel.text = R.string.localizable.crosschainDepositAddress()
    }

    let scanQRCodeLable0 = UILabel().then {
        $0.text = R.string.localizable.crosschainDepositScanAddress()
        $0.numberOfLines = 0
        $0.font = UIFont.boldSystemFont(ofSize: 18)
    }

    lazy var qrcodeView0 = QRCodeViewWithTokenIcon().then {
        $0.snp.makeConstraints { m in
            m.size.equalTo(CGSize(width: 170, height: 170))
        }
    }

    lazy var labelView = EthViteExchangeViteAddressView.addressView(style: .copyButton)

    lazy var scanQRCodeLable1 = UILabel().then {
        $0.numberOfLines = 0
        $0.font = UIFont.boldSystemFont(ofSize: 18)
    }

    lazy var qrcodeView1 = QRCodeViewWithTokenIcon().then {
        $0.snp.makeConstraints { m in
            m.size.equalTo(CGSize(width: 170, height: 170))
        }
    }

    lazy var descriptionLabel0 = UILabel().then {
        $0.text = R.string.localizable.crosschainDepositMinAmountDesc("-", "-", "-")
        $0.numberOfLines = 0
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59,alpha: 0.8)
    }

    let pointView0: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(netHex:0x007AFF)
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
        return view
    }()

    lazy var descriptionLabel1 = UILabel().then {
        $0.numberOfLines = 0
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59,alpha: 0.8)
    }

    let pointView1: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(netHex:0x007AFF)
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var descriptionLabel2 = UILabel().then {
        $0.text = R.string.localizable.crosschainDepositSelectDesc()
        $0.numberOfLines = 0
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor.init(netHex: 0x3E4A59,alpha: 0.8)
    }

    let pointView2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(netHex:0x007AFF)
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
        return view
    }()


    lazy var useViteWalletButton = UIButton.init(style: .add).then {
        $0.setImage(R.image.crosschain_deposie_switch(), for: .normal)
        $0.setImage(R.image.crosschain_deposie_switch(), for: .highlighted)
        $0.setTitle(R.string.localizable.crosschainDepositVitewallet(), for: .normal)
    }

    lazy var scrollView = ScrollableView(insets: UIEdgeInsets(top: 10, left: 24, bottom: 30, right: 24)).then {
        $0.layer.masksToBounds = false
        $0.stackView.spacing = 10
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }

    var depositInfo: BehaviorRelay<DepositInfo>
    
    let gatewayInfoService: CrossChainGatewayInfoService
    var tokenInfo: TokenInfo {
        return gatewayInfoService.tokenInfo
    }
    var mappedTokenInfo: TokenInfo {
        return gatewayInfoService.tokenInfo.gatewayInfo!.mappedToken
    }
    var viteChainTokenDecimals: Int {
        return gatewayInfoService.tokenInfo.decimals
    }
    var mappedChainTokenDecimals: Int {
        return gatewayInfoService.tokenInfo.gatewayInfo?.mappedToken.decimals ?? viteChainTokenDecimals
    }
    
    lazy var chainSelectView = ChainSelectView(mappedTokenExtraInfos: self.gatewayInfoService.tokenInfo.gatewayInfo!.allMappedTokenExtraInfos)

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpViews()

        useViteWalletButton.snp.makeConstraints { (m) in
            m.bottom.equalTo(view.snp.bottomMargin).offset(-20)
            m.height.equalTo(50)
            m.centerX.equalToSuperview()
        }

        addressView.button?.rx.tap.bind { [unowned self] in
            if let address = self.addressView.textLabel.text{
                UIPasteboard.general.string = address
                Toast.show(R.string.localizable.walletHomeToastCopyAddress())
            }
        }.disposed(by: rx.disposeBag)

        labelView.button?.rx.tap.bind { [unowned self] in
            if let address = self.labelView.textLabel.text{
                UIPasteboard.general.string = address
                Toast.show(R.string.localizable.copyed())
            }
        }.disposed(by: rx.disposeBag)

        useViteWalletButton.rx.tap.bind { [unowned self] in
            let vc = CrossChainDepositViewController.init(gatewayInfoService: self.gatewayInfoService, depositInfo: self.depositInfo.value)

            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: rx.disposeBag)

        // 需要查看index所有为0的时候的逻辑！！！！！！！！！！❌❌❌❌❌❌❌❌
        chainSelectView.clicked = { [weak self] index in
            guard let `self` = self else { return }
            guard let address = HDWalletManager.instance.account?.address else {
                return
            }
            self.view.displayLoading()
            self.gatewayInfoService.depositInfo(viteAddress: address, index: index).done { [weak self] info in
                guard let `self` = self else { return }
                self.view.hideLoading()
                
                self.chainSelectView.select(index)
                self.depositInfo.accept(info)
            }.catch { [weak self] (e) in
                self?.view.hideLoading()
                Toast.show(e.localizedDescription)
            }
        }
        
        depositInfo.asDriver().drive { [weak self] info in
            guard let `self` = self else { return }
            
            self.addressView.textLabel.text = info.depositAddress
            self.qrcodeView0.bind(tokenInfo: self.gatewayInfoService.currentMappedToken.tokenInfo, content: info.depositAddress)
            
            self.labelView.titleLabel.text = info.labelName
            self.labelView.textLabel.text = info.label
            
            self.scanQRCodeLable1.text = R.string.localizable.crosschainDepositScanLabel(info.labelName ?? "")
            self.qrcodeView1.bind(tokenInfo: self.gatewayInfoService.currentMappedToken.tokenInfo, content: info.label ?? "")
            
            
            let mapped = self.gatewayInfoService.currentMappedToken
            let chainName = mapped.chainName
            
            if let minimumDepositAmountStr = Amount(info.minimumDepositAmount)?.amountShort(decimals: self.viteChainTokenDecimals)  {
                let symbol = "\(mapped.symbol)(\(chainName))"
                let num = "\(minimumDepositAmountStr) \(symbol)"
                let fullString =  R.string.localizable.crosschainDepositMinAmountDesc(symbol, num, num)
                let attributeString = NSMutableAttributedString.init(string: fullString)
                attributeString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.init(netHex: 0x007AFF)], range: NSString.init(string: fullString).range(of: symbol))
                attributeString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.init(netHex: 0x007AFF)], range: NSString.init(string: fullString).range(of: num))
                attributeString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.init(netHex: 0x007AFF)], range: NSString.init(string: fullString).range(of: num, options: .backwards))
                self.descriptionLabel0.attributedText = attributeString
            }
            
            self.descriptionLabel1.text = R.string.localizable.crosschainDepositMinComfirm(String(info.confirmationCount))
            
            self.useViteWalletButton.isHidden = self.gatewayInfoService.currentMappedToken.coinType != .eth
            
            
            if let labelName = info.labelName, let _ = info.label {
                self.scrollView.addSubview(self.labelView)
                self.scrollView.addSubview(self.scanQRCodeLable1)
                self.scrollView.addSubview(self.qrcodeView1)

                self.qrcodeView0.snp.remakeConstraints { (m) in
                    m.centerX.equalToSuperview()
                    m.top.equalTo(self.scanQRCodeLable0.snp.bottom).offset(29)
                }

                self.labelView.snp.makeConstraints { (m) in
                    m.left.equalToSuperview().offset(16)
                    m.right.equalToSuperview().offset(-16)
                    m.top.equalTo(self.qrcodeView0.snp.bottom).offset(40)
                }

                self.scanQRCodeLable1.snp.makeConstraints { (m) in
                    m.centerX.equalToSuperview()
                    m.top.equalTo(self.labelView.snp.bottom).offset(30)
                }

                self.qrcodeView1.snp.makeConstraints { (m) in
                    m.centerX.equalToSuperview()
                    m.top.equalTo(self.scanQRCodeLable1.snp.bottom).offset(29)
                    m.bottom.equalToSuperview().offset(-10)
                }

                Alert.show(title: R.string.localizable.grinNoticeTitle(), message: R.string.localizable.crosschainDepositLabelDesc(labelName), actions: [
                    (.default(title: R.string.localizable.confirm()), nil),
                    ])

            } else {
                self.labelView.removeFromSuperview()
                self.scanQRCodeLable1.removeFromSuperview()
                self.qrcodeView1.removeFromSuperview()
                
                self.qrcodeView0.snp.remakeConstraints { (m) in
                    m.centerX.equalToSuperview()
                    m.top.equalTo(self.scanQRCodeLable0.snp.bottom).offset(29)
                    m.bottom.equalToSuperview().offset(-10)
                }
            }
        }.disposed(by: rx.disposeBag)

    }

    func setUpViews()  {
        setupNavBar()
        view.addSubview(scrollView)
        view.addSubview(useViteWalletButton)

        scrollView.snp.makeConstraints { (m) in
            m.right.left.equalToSuperview()
            m.bottom.equalTo(useViteWalletButton.snp.top)
            m.top.equalTo(navigationTitleView!.snp.bottom)
        }

        scrollView.addSubview(pointView0)
        scrollView.addSubview(descriptionLabel0)
        scrollView.addSubview(pointView1)
        scrollView.addSubview(descriptionLabel1)
        scrollView.addSubview(pointView2)
        scrollView.addSubview(descriptionLabel2)
        scrollView.addSubview(chainSelectView)
        scrollView.addSubview(addressView)
        scrollView.addSubview(scanQRCodeLable0)
        scrollView.addSubview(qrcodeView0)

        pointView0.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(20)
            m.height.width.equalTo(6)
            m.top.equalTo(scrollView).offset(10)
        }

        descriptionLabel0.snp.makeConstraints { (m) in
            m.left.equalTo(pointView0.snp.right).offset(5)
            m.top.equalTo(pointView0.snp.bottom).offset(-10)
            m.right.equalToSuperview().offset(-20)
        }

        pointView1.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(20)
            m.height.width.equalTo(6)
            m.top.equalTo(descriptionLabel0.snp.bottom).offset(10)
        }

        descriptionLabel1.snp.makeConstraints { (m) in
            m.left.equalTo(pointView1.snp.right).offset(5)
            m.top.equalTo(pointView1.snp.bottom).offset(-10)
            m.right.equalToSuperview().offset(-20)
        }
        
        pointView2.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(20)
            m.height.width.equalTo(6)
            m.top.equalTo(descriptionLabel1.snp.bottom).offset(10)
        }

        descriptionLabel2.snp.makeConstraints { (m) in
            m.left.equalTo(pointView2.snp.right).offset(5)
            m.top.equalTo(pointView2.snp.bottom).offset(-10)
            m.right.equalToSuperview().offset(-20)
        }
        
        chainSelectView.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview().inset(24)
            m.top.equalTo(descriptionLabel2.snp.bottom).offset(20)
        }

        addressView.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(16)
            m.right.equalToSuperview().offset(-16)
            m.top.equalTo(chainSelectView.snp.bottom).offset(18)
        }

        scanQRCodeLable0.snp.makeConstraints { (m) in
            m.centerX.equalToSuperview()
            m.top.equalTo(addressView.snp.bottom).offset(30)
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
            let vc = CrossChainHistoryViewController(tokenInfo: self.tokenInfo, index: self.gatewayInfoService.index, style: .desposit)
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
        titleLabel.tipButton.isHidden = true
        return view
    }

}
