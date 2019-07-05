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
import Web3swift

class WalletHomeViewController: BaseTableViewController {

    typealias DataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, WalletHomeBalanceInfoViewModel>>

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
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

    let walletDriver = HDWalletManager.instance.walletDriver
    var tableViewModel: WalletHomeBalanceInfoTableViewModel!
    var navViewModel: WalletHomeNavViewModel!

    let navView = WalletHomeNavView(frame: CGRect.zero)
    let headerView = WalletHomeHeaderView()

    lazy var isHidePriceDriver: Driver<Bool> = self.isHidePriceBehaviorRelay.asDriver()
    var isHidePriceBehaviorRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    fileprivate func setupView() {

        statisticsPageName = Statistics.Page.WalletHome.name

        view.addSubview(navView)

        navView.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.right.equalToSuperview()
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpTop).offset(130)
        }


        tableView.snp.remakeConstraints { (m) in
            m.top.equalTo(navView.snp.bottom)
            m.bottom.right.left.equalTo(view)
        }

        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        tableView.rowHeight = WalletHomeBalanceInfoCell.cellHeight
        tableView.estimatedRowHeight = WalletHomeBalanceInfoCell.cellHeight
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 56)).then {
            $0.backgroundColor = UIColor.clear
            $0.addSubview(headerView)
            headerView.snp.makeConstraints { (m) in
                m.top.equalToSuperview()
                m.left.right.equalToSuperview()
            }
        }

        if #available(iOS 11.0, *) {

        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }

    fileprivate let dataSource = DataSource(configureCell: { (_, tableView, indexPath, item) -> UITableViewCell in
        let cell: WalletHomeBalanceInfoCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(viewModel: item)
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
            }.disposed(by: rx.disposeBag)

        navView.hideButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            self.isHidePriceBehaviorRelay.accept(!self.isHidePriceBehaviorRelay.value)
            }.disposed(by: rx.disposeBag)

        tableViewModel.balanceInfosDriver.asObservable()
            .map { balanceInfoViewModels in
                [SectionModel(model: "balanceInfo", items: balanceInfoViewModels)]
            }
            .bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: rx.disposeBag)

        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        tableView.rx.itemSelected
            .bind { [weak self] indexPath in
                guard let `self` = self else { fatalError() }
                if let viewModel = (try? self.dataSource.model(at: indexPath)) as? WalletHomeBalanceInfoViewModel {
                    self.tableView.deselectRow(at: indexPath, animated: true)
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
                            let storyboard =
                                balanceInfoDetailViewController = UIStoryboard(name: "GrinInfo", bundle: businessBundle())
                                    .instantiateInitialViewController()!
                        }
                    }
                    self.navigationController?.pushViewController(balanceInfoDetailViewController, animated: true)
                }
            }
            .disposed(by: rx.disposeBag)
    }

    func scan() {
        let scanViewController = ScanViewController()
        scanViewController.reactor = ScanViewReactor.init()
        _ = scanViewController.rx.result.bind { [weak scanViewController, self] result in
            if case .success(let uri) = ViteURI.parser(string: result) {
                self.handleScanResult(with: uri, scanViewController: scanViewController)
            } else if case .success(let uri) = ETHURI.parser(string: result) {
                self.handleScanResultForETH(with: uri, scanViewController: scanViewController)
            } else if let url = URL.init(string: result), (result.hasPrefix("http://") || result.hasPrefix("https://")) {
                self.handleScanResult(with: url, scanViewController: scanViewController)
            } else {
                scanViewController?.showAlertMessage(result)
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

                if !tokenInfo.isContains {
                    MyTokenInfosService.instance.append(tokenInfo: tokenInfo)
                }
                
                switch uri.type {
                case .transfer:
                    if let data = uri.data {
                        if data.contentType == .utf8string,
                            let contentData = data.rawContent,
                            let note = String(bytes: contentData, encoding: .utf8) {

                            let sendViewController = SendViewController(tokenInfo: tokenInfo, address: uri.address, amount: uri.amount != nil ? amount : nil, note: note)
                            guard var viewControllers = self.navigationController?.viewControllers else { return }
                            _ = viewControllers.popLast()
                            viewControllers.append(sendViewController)
                            scanViewController?.navigationController?.setViewControllers(viewControllers, animated: true)
                        } else {
                            self.navigationController?.popViewController(animated: true)
                            Workflow.sendTransactionWithConfirm(account: HDWalletManager.instance.account!, toAddress: uri.address, tokenInfo: tokenInfo, amount: amount, data: uri.data, completion: { _ in })
                        }
                    } else {
                        let sendViewController = SendViewController(tokenInfo: tokenInfo, address: uri.address, amount: uri.amount != nil ? amount : nil, note: nil)
                        guard var viewControllers = self.navigationController?.viewControllers else { return }
                        _ = viewControllers.popLast()
                        viewControllers.append(sendViewController)
                        scanViewController?.navigationController?.setViewControllers(viewControllers, animated: true)
                    }
                case .contract:
                    self.navigationController?.popViewController(animated: true)
                    Workflow.callContractWithConfirm(account: HDWalletManager.instance.account!,
                                                     toAddress: uri.address,
                                                     tokenInfo: tokenInfo,
                                                     amount: amount,
                                                     data: uri.data,
                                                     completion: { _ in })
                }
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
                guard var viewControllers = self.navigationController?.viewControllers else { return }
                _ = viewControllers.popLast()
                viewControllers.append(sendViewController)
                scanViewController?.navigationController?.setViewControllers(viewControllers, animated: true)
            case .failure(let error):
                scanViewController?.showToast(string: error.viteErrorMessage)
            }
        }
    }

    func handleScanResult(with url: URL, scanViewController: ScanViewController?) {

        func goWeb() {
            guard var viewControllers = self.navigationController?.viewControllers else { return }
            let webvc = WKWebViewController.init(url: url)
            _ = viewControllers.popLast()
            viewControllers.append(webvc)
            scanViewController?.navigationController?.setViewControllers(viewControllers, animated: true)
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
}
