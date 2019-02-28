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

    typealias DataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, n_WalletHomeBalanceInfoViewModel>>

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }

    let walletDriver = HDWalletManager.instance.walletDriver
    let addressView = WalletHomeAddressView()
    var addressViewModel: WalletHomeAddressViewModel!
    var tableViewModel: n_WalletHomeBalanceInfoTableViewModel!
    weak var balanceInfoDetailViewController: BalanceInfoDetailViewController?

    fileprivate func setupView() {

        statisticsPageName = Statistics.Page.WalletHome.name
        let qrcodeItem = UIBarButtonItem(image: R.image.icon_nav_qrcode_black(), style: .plain, target: nil, action: nil)
        let scanItem = UIBarButtonItem(image: R.image.icon_nav_scan_black(), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = qrcodeItem
        navigationItem.rightBarButtonItem = scanItem

        navigationTitleView = NavigationTitleView(title: nil)
        customHeaderView = addressView
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        tableView.rowHeight = WalletHomeBalanceInfoCell.cellHeight
        tableView.estimatedRowHeight = WalletHomeBalanceInfoCell.cellHeight
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 18)).then {
            $0.backgroundColor = UIColor.clear
        }

        if #available(iOS 11.0, *) {

        } else {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 49, right: 0)
            tableView.scrollIndicatorInsets = tableView.contentInset
        }

        let shadowView = UIView().then {
            $0.backgroundColor = UIColor.white
            $0.layer.shadowColor = UIColor(netHex: 0x000000).cgColor
            $0.layer.shadowOpacity = 0.1
            $0.layer.shadowOffset = CGSize(width: 0, height: 5)
            $0.layer.shadowRadius = 20
        }

        view.insertSubview(shadowView, belowSubview: tableView)
        shadowView.snp.makeConstraints { (m) in
            m.left.right.equalTo(tableView)
            m.bottom.equalTo(tableView.snp.top)
            m.height.equalTo(10)
        }

        qrcodeItem.rx.tap.bind { [weak self] _ in
            self?.navigationController?.pushViewController(ReceiveViewController(token: TokenCacheService.instance.viteToken), animated: true)
        }.disposed(by: rx.disposeBag)

        scanItem.rx.tap.bind { [unowned self] _ in
            self.scan()
        }.disposed(by: rx.disposeBag)
    }

    fileprivate let dataSource = DataSource(configureCell: { (_, tableView, indexPath, item) -> UITableViewCell in
        let cell: WalletHomeBalanceInfoCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(viewModel: item)
        return cell
    })

    fileprivate func bind() {

        if let navigationTitleView = navigationTitleView as? NavigationTitleView {
            walletDriver.map({ $0.name }).drive(navigationTitleView.titleLabel.rx.text).disposed(by: rx.disposeBag)
        }

        addressViewModel = WalletHomeAddressViewModel()
        tableViewModel = n_WalletHomeBalanceInfoTableViewModel()

        addressView.bind(viewModel: addressViewModel)

        tableViewModel.balanceInfosDriver.asObservable()
            .map { balanceInfoViewModels in
                [SectionModel(model: "balanceInfo", items: balanceInfoViewModels)]
            }
            .bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: rx.disposeBag)

        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        tableView.rx.itemSelected
            .bind { [weak self] indexPath in
                guard let `self` = self else { fatalError() }
                if let viewModel = (try? self.dataSource.model(at: indexPath)) as? n_WalletHomeBalanceInfoViewModel {
                    self.tableView.deselectRow(at: indexPath, animated: true)
                    let balanceInfoDetailViewController : UIViewController
                    if indexPath.row == 0 {
                         balanceInfoDetailViewController = n_BalanceInfoDetailViewController(tokenInfo: viewModel.tokenInfo)
                    }else {
                        balanceInfoDetailViewController = EthTokenInfoController(viewModel.tokenInfo)
                    }
                    self.navigationController?.pushViewController(balanceInfoDetailViewController, animated: true)
//                    self.balanceInfoDetailViewController = balanceInfoDetailViewController
                }
            }
            .disposed(by: rx.disposeBag)

//        tableViewModel.balanceInfosDriver.asObservable().bind { [weak self] in
//            if let viewModelBehaviorRelay = self?.balanceInfoDetailViewController?.viewModelBehaviorRelay {
//                for viewModel in $0 where viewModelBehaviorRelay.value.token.id == viewModel.token.id {
//                    viewModelBehaviorRelay.accept(viewModel)
//                    break
//                }
//            }
//        }.disposed(by: rx.disposeBag)
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
        TokenCacheService.instance.tokenForId(uri.tokenId) {[weak scanViewController] (result) in
            scanViewController?.view.hideLoading()
            switch result {
            case .success(let token):
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
                    let sendViewController = SendViewController(token: token, address: uri.address, amount: uri.amount != nil ? amount : nil, note: note)
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
