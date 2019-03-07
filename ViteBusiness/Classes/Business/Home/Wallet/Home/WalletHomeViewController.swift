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
import ViteUtils
import ViteWallet

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
        view.addSubview(headerView)

        navView.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.right.equalToSuperview()
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpTop).offset(130)
        }

        headerView.snp.makeConstraints { (m) in
            m.top.equalTo(navView.snp.bottom)
            m.left.right.equalToSuperview()
        }

        tableView.snp.remakeConstraints { (m) in
            m.top.equalTo(headerView.snp.bottom)
            m.bottom.right.left.equalTo(view)
        }

        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        tableView.rowHeight = WalletHomeBalanceInfoCell.cellHeight
        tableView.estimatedRowHeight = WalletHomeBalanceInfoCell.cellHeight
//        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 18)).then {
//            $0.backgroundColor = UIColor.clear
//        }

        if #available(iOS 11.0, *) {

        } else {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 49, right: 0)
            tableView.scrollIndicatorInsets = tableView.contentInset
        }
    }

    fileprivate let dataSource = DataSource(configureCell: { (_, tableView, indexPath, item) -> UITableViewCell in
        let cell: WalletHomeBalanceInfoCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(viewModel: item)
        return cell
    })

    fileprivate func bind() {

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
                    let balanceInfoDetailViewController : UIViewController
                    if viewModel.tokenInfo.coinType == .eth {
                        balanceInfoDetailViewController = EthTokenInfoController(viewModel.tokenInfo)
                    } else {
                        balanceInfoDetailViewController = BalanceInfoDetailViewController(tokenInfo: viewModel.tokenInfo)
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
                let token = tokenInfo.toViteToken()!
                guard let amount = uri.amountForSmallestUnit(decimals: token.decimals) else {
                    scanViewController?.showToast(string: R.string.localizable.viteUriAmountFormatError())
                    return
                }
                switch uri.type {
                case .transfer:
                    var note = ""
                    if let data = uri.data,
                        let ret = String(bytes: data, encoding: .utf8) {
                        note = ret
                    }
                    let sendViewController = SendViewController(tokenInfo: tokenInfo, address: uri.address, amount: uri.amount != nil ? amount : nil, note: note)
                    guard var viewControllers = self.navigationController?.viewControllers else { return }
                    _ = viewControllers.popLast()
                    viewControllers.append(sendViewController)
                    scanViewController?.navigationController?.setViewControllers(viewControllers, animated: true)
                case .contract:
                    self.navigationController?.popViewController(animated: true)
                    Workflow.callContractWithConfirm(account: HDWalletManager.instance.account!,
                                                     toAddress: uri.address,
                                                     token: token,
                                                     amount: Balance(value: amount),
                                                     data: uri.data?.toBase64(),
                                                     completion: { _ in })
                }
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
