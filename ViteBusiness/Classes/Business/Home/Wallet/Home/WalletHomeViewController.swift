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
        tableView.contentInset = UIEdgeInsets.init(top: 5, left: 0, bottom: 0, right: 0)
    }

    lazy var pageManager = { () -> DNSPageViewManager in
        var pageStyle = DNSPageStyle()
        pageStyle.isShowBottomLine = false
        pageStyle.bottomLineRadius = 0
        pageStyle.isTitleViewScrollEnabled = true
        pageStyle.titleViewBackgroundColor = UIColor.clear
        pageStyle.titleSelectedColor = UIColor.init(netHex: 0x3E4A59)
        pageStyle.titleColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.7)
        pageStyle.titleFont = UIFont.boldSystemFont(ofSize: 13)
        pageStyle.bottomLineColor = Colors.blueBg
        pageStyle.bottomLineHeight = 2
        pageStyle.bottomLineWidth = 20

        let vc0 = UIViewController()
        vc0.view.addSubview(walletTable)
        walletTable.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }

        let m = DNSPageViewManager(style: pageStyle, titles: [R.string.localizable.fundTitleWallet()], childViewControllers: [vc0])
        return m
    }()

    let scanHandler = WalletHomeScanHandler()
    let walletDriver = HDWalletManager.instance.walletDriver
    var tableViewModel: WalletHomeBalanceInfoTableViewModel!
    var navViewModel: WalletHomeNavViewModel!
    lazy var isHidePriceDriver: Driver<Bool> = self.isHidePriceBehaviorRelay.asDriver()
    var isHidePriceBehaviorRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    typealias WalletDataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, WalletHomeBalanceInfoViewModel>>

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
        if CreateWalletService.sharedInstance.needBackup && !HDWalletManager.instance.isBackedUp {
            CreateWalletService.sharedInstance.showBackUpTipAlert()
        }
        if let code = CreateWalletService.sharedInstance.vitexInviteCode {
            WalletManager.instance.update(vitexInviteCode: code)
        }

        GCD.delay(1) {
            CreateWalletService.sharedInstance.GoExportMnemonicIfNeeded()
            WalletManager.instance.bindInviteIfNeeded()
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
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
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
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpTop).offset(144)
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

    fileprivate let walletDataSource = WalletDataSource(configureCell: { (_, tableView, indexPath, item) -> UITableViewCell in
        let cell: WalletHomeBalanceInfoCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(viewModel: item)
        return cell
    })

    fileprivate func bind() {

        pageManager.titleView.clickHandler = { [unowned self] (titleView, index) in
            self.refreshNavInfo(index)
        }

        ViteBalanceInfoManager.instance.unselectBalanceInfoVMsDriver.drive(onNext: { (vms) in
            //plog(level: .debug, log: "vm: \(vms.reduce("", { (ret, vm) -> String in ret + vm.tokenInfo.uniqueSymbol + " " }))")
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
            self?.scanHandler.scan()
            Statistics.log(eventId: Statistics.Page.WalletHome.scanClicked.rawValue)
        }.disposed(by: rx.disposeBag)

        navView.myButton.rx.tap.bind { [weak self] in
            let vc = MyHomeViewController()
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
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

        walletTable.rx.setDelegate(self).disposed(by: rx.disposeBag)

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
                    TokenInfoCacheService.instance.updateTokenInfoIfNeeded(for: viewModel.tokenInfo.tokenCode)
                    let balanceInfoDetailViewController : UIViewController
                    switch viewModel.tokenInfo.coinType {
                    case .eth, .vite,.bnb:
                        balanceInfoDetailViewController = BalanceInfoDetailViewController(tokenInfo: viewModel.tokenInfo)
                    case .unsupport:
                        fatalError()
                    }
                    self.navigationController?.pushViewController(balanceInfoDetailViewController, animated: true)
                    Statistics.log(eventId: String(format: Statistics.Page.WalletHome.enterTokenDetails.rawValue, viewModel.tokenInfo.statisticsId))
                }
            }
            .disposed(by: rx.disposeBag)

        BifrostManager.instance.statusDriver.drive(onNext: { [weak self] (status) in
            guard let `self` = self else { return }
            if status == .disconnect {
                self.bifrostStatusView.isHidden = true
                self.bifrostStatusView.snp_remakeConstraints({ (m) in
                    m.top.equalTo(self.navView.snp.bottom)
                    m.left.right.equalToSuperview()
                    m.height.equalTo(0)
                })
            } else {
                self.bifrostStatusView.isHidden = false
                self.bifrostStatusView.snp_remakeConstraints({ (m) in
                    m.top.equalTo(self.navView.snp.bottom)
                    m.left.right.equalToSuperview()
                    m.height.equalTo(30)
                })
            }
            self.walletTable.reloadData()
        }).disposed(by: rx.disposeBag)
    }

    func refreshNavInfo(_ index: Int) {
        let infoType = [WalletHomeNavViewModel.InfoType.wallet,WalletHomeNavViewModel.InfoType.viteX][index]
        self.navViewModel.infoTypeBehaviorRelay.accept(infoType)
    }

    func vitexTableAccessoryButton(_ accessoryButton: UIButton, didTappedForRowWith indexPath: IndexPath) {
        guard indexPath.row <= (self.tableViewModel.lastViteXBalanceInfos.count - 1) else {
            return
        }
        let viteXBalanceInfo = self.tableViewModel.lastViteXBalanceInfos[indexPath.row]
        let tokenInfo = viteXBalanceInfo.tokenInfo
        let vc = ManageViteXBanlaceViewController(tokenInfo: tokenInfo)
        self.navigationController?.pushViewController(vc, animated: true)
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
        self.refreshNavInfo(index)
    }

    func contentView(_ contentView: DNSPageContentView, scrollingWith sourceIndex: Int, targetIndex: Int, progress: CGFloat) {
        self.pageManager.titleView.contentView(contentView, scrollingWith: sourceIndex, targetIndex: targetIndex, progress: progress)
    }
}

extension WalletHomeViewController: UITableViewDelegate {

}
