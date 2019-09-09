//
//  WalletHomeViewController.swift
//  Vite
//
//  Created by Stone on 2018/9/7.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import RxDataSources
import Vite_HDWalletKit
import ViteWallet
import BigInt
import web3swift
import DNSPageView
import Then

class WalletHomeViewController: BaseViewController {

    let navView = WalletHomeNavView(frame: CGRect.zero)
    let bifrostStatusView = BifrostStatusView().then {
        $0.isHidden = true
    }
    let headerView = WalletHomeHeaderView()
    lazy var walletTable = UITableView().then { tableView in
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        tableView.rowHeight = WalletHomeBalanceInfoCell.cellHeight
        tableView.estimatedRowHeight = WalletHomeBalanceInfoCell.cellHeight
    }
    lazy var vitexTable = UITableView().then { tableView in
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        tableView.rowHeight = VitexBalanceInfoCell.cellHeight
        tableView.estimatedRowHeight = VitexBalanceInfoCell.cellHeight
    }
    lazy var pageManager = { () -> DNSPageViewManager in
        var pageStyle = DNSPageStyle()
        pageStyle.isShowBottomLine = true
        pageStyle.isTitleViewScrollEnabled = true
        pageStyle.titleViewBackgroundColor = UIColor.clear
        pageStyle.titleSelectedColor = UIColor.init(netHex: 0x3E4A59)
        pageStyle.titleColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.7)
        pageStyle.titleFont = UIFont.boldSystemFont(ofSize: 13)
        pageStyle.bottomLineColor = Colors.blueBg
        pageStyle.bottomLineHeight = 3

        let vc0 = UIViewController()
        let vc1 = UIViewController()
        vc0.view.addSubview(walletTable)
        vc1.view.addSubview(vitexTable)
        walletTable.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }
        vitexTable.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }
        let m = DNSPageViewManager(style: pageStyle, titles: [R.string.localizable.fundTitleWallet(),R.string.localizable.fundTitleVitex()], childViewControllers: [vc0, vc1])
        return m
    }()

    let walletDriver = HDWalletManager.instance.walletDriver
    var tableViewModel: WalletHomeBalanceInfoTableViewModel!
    var navViewModel: WalletHomeNavViewModel!
    lazy var isHidePriceDriver: Driver<Bool> = self.isHidePriceBehaviorRelay.asDriver()
    var isHidePriceBehaviorRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    typealias DataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, WalletHomeBalanceInfoViewModel>>

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
        if CreateWalletService.sharedInstance.needBackup && !HDWalletManager.instance.isBackedUp {
            CreateWalletService.sharedInstance.showBackUpTipAlert()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableViewModel.registerFetchAll()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tableViewModel.unregisterFetchAll()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    fileprivate func setupView() {
        statisticsPageName = Statistics.Page.WalletHome.name
        if #available(iOS 11.0, *) {

        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }

        view.addSubview(navView)
        view.addSubview(bifrostStatusView)
        view.addSubview(pageManager.contentView)
        view.addSubview(pageManager.titleView)
        view.addSubview(headerView)

        navView.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.right.equalToSuperview()
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpTop).offset(130)
        }

        bifrostStatusView.snp.makeConstraints { (m) in
            m.top.equalTo(navView.snp.bottom)
            m.left.right.equalToSuperview()
            m.height.equalTo(0)
        }

        headerView.snp.makeConstraints { (m) in
            m.right.equalToSuperview()
            m.centerY.equalTo(pageManager.titleView)
            m.height.equalTo(60)
            m.width.equalTo(100)
        }

        pageManager.titleView.snp.makeConstraints { (make) in
            make.top.equalTo(bifrostStatusView.snp.bottom).offset(9)
            make.left.equalToSuperview().offset(9)
            make.right.equalToSuperview().offset(-9)
            make.height.equalTo(35)
        }

        pageManager.contentView.snp.makeConstraints { (make) in
            make.top.equalTo(pageManager.titleView.snp.bottom).offset(9)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom)
        }

        pageManager.contentView.delegate = self

    }

    fileprivate let walletDataSource = DataSource(configureCell: { (_, tableView, indexPath, item) -> UITableViewCell in
        let cell: WalletHomeBalanceInfoCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(viewModel: item)

        return cell
    })

    fileprivate lazy var vitexDataSource = DataSource(configureCell: { (_, tableView, indexPath, item) -> UITableViewCell in
        let cell: VitexBalanceInfoCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(viewModel: item)
        cell.handler = { [unowned self] button in
            self.vitexTableAccessoryButton(button, didTappedForRowWith: indexPath)
        }
        return cell
    })

    fileprivate func bind() {

        ViteBalanceInfoManager.instance.unselectBalanceInfoVMsDriver.drive(onNext: { (vms) in
            plog(level: .debug, log: "vm: \(vms.reduce("", { (ret, vm) -> String in ret + vm.tokenInfo.uniqueSymbol + " " }))")
            var tokens = NewAssetService.instance.handleIsNewTipTokens(vms)

            if tokens.count > 0 {
                self.headerView.addButton.pp.badgeView.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
                self.headerView.addButton.pp.badgeView.layer.borderColor = UIColor.white.cgColor
                self.headerView.addButton.pp.badgeView.layer.borderWidth = 1.0
                self.headerView.addButton.pp.setBadge(flexMode: .middle)
//                self.headerView.addButton.pp.setBadge(height: 14)
                self.headerView.addButton.pp.moveBadge(x: -30, y: 15)

                if tokens.count >= 10 {
                     self.headerView.addButton.pp.addBadge(text: "N")
                }else {
                     self.headerView.addButton.pp.addBadge(number: tokens.count)
                }
                self.headerView.addButton.pp.showBadge()
            }else {
                self.headerView.addButton.pp.hiddenBadge()
            }
        }).disposed(by: rx.disposeBag)

        tableViewModel = WalletHomeBalanceInfoTableViewModel(isHidePriceDriver: isHidePriceDriver)
        navViewModel = WalletHomeNavViewModel(isHidePriceDriver: isHidePriceDriver, walletHomeBalanceInfoTableViewModel: tableViewModel)
        navView.bind(viewModel: navViewModel)

        navView.scanButton.rx.tap.bind { [weak self] in
            self?.scan()
            Statistics.log(eventId: Statistics.Page.WalletHome.scanClicked.rawValue)
            }.disposed(by: rx.disposeBag)

        navView.hideButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            self.isHidePriceBehaviorRelay.accept(!self.isHidePriceBehaviorRelay.value)
            }.disposed(by: rx.disposeBag)

        tableViewModel.balanceInfosDriver.asObservable()
            .map { balanceInfoViewModels in
                [SectionModel(model: "balanceInfo", items: balanceInfoViewModels)]
            }
            .bind(to: walletTable.rx.items(dataSource: walletDataSource)).disposed(by: rx.disposeBag)

        tableViewModel.viteXBalanceInfosDriver.asObservable()
            .map { balanceInfoViewModels in
                [SectionModel(model: "balanceInfo", items: balanceInfoViewModels)]
            }
            .bind(to: vitexTable.rx.items(dataSource: vitexDataSource)).disposed(by: rx.disposeBag)

        walletTable.rx.setDelegate(self).disposed(by: rx.disposeBag)
        vitexTable.rx.setDelegate(self).disposed(by: rx.disposeBag)

        self.headerView.addButton.rx.tap.bind { [unowned self] in
            let vc = TokenListManageController()
            vc.onlyShowVite = self.pageManager.contentView.currentIndex == 1
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
            Statistics.log(eventId: Statistics.Page.WalletHome.addTokenclicked.rawValue)
            }.disposed(by: self.rx.disposeBag)

        walletTable.rx.itemSelected
            .bind { [weak self] indexPath in
                guard let `self` = self else { fatalError() }
                if let viewModel = (try? self.walletDataSource.model(at: indexPath)) as? WalletHomeBalanceInfoViewModel {
                    self.walletTable.deselectRow(at: indexPath, animated: true)
                    MyTokenInfosService.instance.updateTokenInfoIfNeeded(for: viewModel.tokenInfo.tokenCode)
                    let balanceInfoDetailViewController : UIViewController
                    switch viewModel.tokenInfo.coinType {
                    case .eth, .vite:
                        balanceInfoDetailViewController = BalanceInfoDetailViewController(tokenInfo: viewModel.tokenInfo)
                    case .grin:
                        if !GrinManager.default.walletCreated.value {
                            Toast.show(R.string.localizable.grinCreating())
                            return
                        } else {
                            balanceInfoDetailViewController = BalanceInfoDetailViewController(tokenInfo: viewModel.tokenInfo)
                        }
                    case .unsupport:
                        fatalError()
                    }
                    self.navigationController?.pushViewController(balanceInfoDetailViewController, animated: true)
                    Statistics.log(eventId: String(format: Statistics.Page.WalletHome.enterTokenDetails.rawValue, viewModel.tokenInfo.statisticsId))
                }
            }
            .disposed(by: rx.disposeBag)

        BifrostManager.instance.isConnectedAndApprovedDriver.drive(onNext: { [weak self] (connected) in
            guard let `self` = self else { return }
            self.bifrostStatusView.isHidden = !connected
            if connected {
                self.bifrostStatusView.snp_remakeConstraints({ (m) in
                    m.top.equalTo(self.navView.snp.bottom)
                    m.left.right.equalToSuperview()
                    m.height.equalTo(30)
                })
            } else {
                self.bifrostStatusView.snp_remakeConstraints({ (m) in
                    m.top.equalTo(self.navView.snp.bottom)
                    m.left.right.equalToSuperview()
                    m.height.equalTo(0)
                })
            }
            self.walletTable.reloadData()
        }).disposed(by: rx.disposeBag)
    }

    func vitexTableAccessoryButton(_ accessoryButton: UIButton, didTappedForRowWith indexPath: IndexPath) {
        let tokenInfo = self.tableViewModel.viteXBalanceInfosDriver
        let a0 = UIAlertAction.init(title: R.string.localizable.fundTitleToVitex(), style: .default) { [unowned self] (_) in
            let vc = ManageViteXBanlaceViewController(tokenInfo: TokenInfo.viteCoin,actionType: .toVitex)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        let a1 = UIAlertAction.init(title: R.string.localizable.fundTitleToWallet(), style: .default) { [unowned self] (_) in
            let vc = ManageViteXBanlaceViewController(tokenInfo: TokenInfo.viteCoin, actionType: .toWallet)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        let a2 = UIAlertAction.init(title: R.string.localizable.cancel(), style: .cancel) { _ in }
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(a0)
        alert.addAction(a1)
        alert.addAction(a2)
        if let popover = alert.popoverPresentationController {
            popover.sourceView = accessoryButton;
            popover.sourceRect = accessoryButton.bounds;
            popover.permittedArrowDirections = .any;
        }
        self.present(alert, animated: true, completion: nil)
    }


}

extension WalletHomeViewController: DNSPageContentViewDelegate {
    func contentView(_ contentView: DNSPageContentView, didEndScrollAt index: Int) {
        self.pageManager.titleView.contentView(contentView, didEndScrollAt: index)
        for (i, label) in self.pageManager.titleView.titleLabels.enumerated() {
            if i == index {
                label.textColor = self.pageManager.titleView.style.titleSelectedColor
            } else {
                label.textColor = self.pageManager.titleView.style.titleColor
            }
        }
        let infoType = [WalletHomeNavViewModel.InfoType.wallet,WalletHomeNavViewModel.InfoType.viteX][index]
        self.navViewModel.infoTypeBehaviorRelay.accept(infoType)
    }

    func contentView(_ contentView: DNSPageContentView, scrollingWith sourceIndex: Int, targetIndex: Int, progress: CGFloat) {
        self.pageManager.titleView.contentView(contentView, scrollingWith: sourceIndex, targetIndex: targetIndex, progress: progress)
    }
}

extension WalletHomeViewController {

    func scan() {
        let scanViewController = ScanViewController()
        scanViewController.reactor = ScanViewReactor.init()
        _ = scanViewController.rx.result.bind { [weak scanViewController, self] result in
            if case .success(let uri) = ViteURI.parser(string: result), !uri.address.isDexAddress {
                self.handleScanResult(with: uri, scanViewController: scanViewController)
            } else if case .success(let uri) = ETHURI.parser(string: result) {
                self.handleScanResultForETH(with: uri, scanViewController: scanViewController)
            } else if let url = URL.init(string: result), (result.hasPrefix("http://") || result.hasPrefix("https://")) {
                self.handleScanResult(with: url, scanViewController: scanViewController)
            } else if case .success(let uri) = BifrostURI.parser(string: result) {
                self.handleScanResultForBifrost(with: uri, scanViewController: scanViewController)
            } else {
                if let url = URL(string: result), ViteAppSchemeHandler.instance.handleViteScheme(url) {
                    // do nothing
                } else {
                    scanViewController?.showAlertMessage(result)
                }
            }
        }
        self.navigationController?.pushViewController(scanViewController, animated: true)
    }

    func handleScanResult(with uri: ViteURI, scanViewController: ScanViewController?) {
        scanViewController?.view.displayLoading(text: "")
        MyTokenInfosService.instance.tokenInfo(forViteTokenId: uri.tokenId) {[weak scanViewController] (result) in
            scanViewController?.view.hideLoading()
            switch result {
            case .success(let tokenInfo):
                guard let amount = uri.amountForSmallestUnit(decimals: tokenInfo.decimals) else {
                    scanViewController?.showToast(string: R.string.localizable.viteUriAmountFormatError())
                    return
                }

                guard let fee = uri.feeForSmallestUnit(decimals: ViteWalletConst.viteToken.decimals) else {
                    scanViewController?.showToast(string: R.string.localizable.viteUriAmountFormatError())
                    return
                }

                if !tokenInfo.isContains {
                    MyTokenInfosService.instance.append(tokenInfo: tokenInfo)
                }

                let sendViewController = SendViewController(tokenInfo: tokenInfo, address: uri.address, amount: uri.amount != nil ? amount : nil, data: uri.data)
                UIViewController.current?.navigationController?.pushViewController(sendViewController, animated: true)
            case .failure(let error):
                scanViewController?.showToast(string: error.viteErrorMessage)
            }
        }
    }

    func handleScanResultForETH(with uri: ETHURI, scanViewController: ScanViewController?) {
        scanViewController?.view.displayLoading(text: "")
        MyTokenInfosService.instance.tokenInfo(forEthContractAddress: uri.contractAddress ?? "") {[weak scanViewController] (result) in
            scanViewController?.view.hideLoading()
            switch result {
            case .success(let tokenInfo):

                if !tokenInfo.isContains {
                    MyTokenInfosService.instance.append(tokenInfo: tokenInfo)
                }

                var balance: Amount? = nil
                if let amount = uri.amount,
                    let b = Amount(amount) {
                    balance = b
                }

                let sendViewController = EthSendTokenController(tokenInfo, toAddress: EthereumAddress(uri.address)!, amount: balance)
                UIViewController.current?.navigationController?.pushViewController(sendViewController, animated: true)
            case .failure(let error):
                scanViewController?.showToast(string: error.viteErrorMessage)
            }
        }
    }

    func handleScanResult(with url: URL, scanViewController: ScanViewController?) {

        func goWeb() {
            let webvc = WKWebViewController.init(url: url)
            UIViewController.current?.navigationController?.pushViewController(webvc, animated: true)
        }

        var showAlert = true
        for string in Constants.whiteList {
            if url.host?.lowercased() == string ||
                (url.host?.lowercased() ?? "").hasSuffix("." + string) {
                showAlert = false
                break
            }
        }

        if showAlert {
            Alert.show(title: R.string.localizable.walletHomeScanUrlAlertTitle(),
                       message: R.string.localizable.walletHomeScanUrlAlertMessage(),
                       actions: [
                        (.cancel, { _ in
                            scanViewController?.startCaptureSession()
                        }),
                        (.default(title: R.string.localizable.confirm()), { _ in
                            goWeb()
                        })
                ])
        } else {
            goWeb()
        }
    }

    func handleScanResultForBifrost(with uri: BifrostURI, scanViewController: ScanViewController?) {
        BifrostManager.instance.tryConnect(uri: uri)
    }
}


extension WalletHomeViewController: UITableViewDelegate {

}

