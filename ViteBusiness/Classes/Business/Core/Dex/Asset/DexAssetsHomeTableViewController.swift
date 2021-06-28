//
//  DexAssetsHomeTableViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2020/8/26.
//

import Foundation
import RxSwift
import RxCocoa
import ViteWallet

class DexAssetsHomeTableViewController: BaseTableViewController {

    lazy var headerCell = DexAssetsHomeHeaderViewCell(type: self.type)

    let viewModelBehaviorRelay: BehaviorRelay<[DexAssetsHomeCellViewModel]> = BehaviorRelay(value: [])
    let btcValuationBehaviorRelay: BehaviorRelay<BigDecimal> = BehaviorRelay(value: BigDecimal())
    let sortModeBehaviorRelay: BehaviorRelay<DexAssetsHomeViewController.SortMode>

    let type: DexAssetsHomeViewController.PType
    init(type: DexAssetsHomeViewController.PType, sortModeBehaviorRelay: BehaviorRelay<DexAssetsHomeViewController.SortMode>) {
        self.type = type
        self.sortModeBehaviorRelay = sortModeBehaviorRelay
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        tableView.backgroundColor = .white
        tableView.snp.remakeConstraints { (m) in
            m.top.equalTo(view).offset(38)
            m.left.right.bottom.equalToSuperview()
        }

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.contentInsetAdjustmentBehavior = .never
        bind()
    }

    func bind() {

        HDWalletManager.instance.accountDriver.filterNil().map { $0.address }.drive(headerCell.addressButton.rx.title(for: .normal)).disposed(by: rx.disposeBag)

        headerCell.addressButton.rx.tap.bind {
            let vc = MyAddressManageViewController(tableViewModel: MyViteAddressManagerTableViewModel())
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: rx.disposeBag)

        headerCell.transferButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            let vc = ViteXTokenSelectorViewController(type: .wallet, filter: .none) { [weak self] (tokenInfo, vc) in
                guard let `self` = self else { return }
                let transferVC = ManageViteXBanlaceViewController(tokenInfo: tokenInfo, actionType: self.type == .wallet ? .toVitex : .toWallet)
                UIViewController.current?.navigationController?.pushViewController(transferVC, animated: true)
                GCD.delay(0.3) {
                    var vcs = vc.navigationController!.viewControllers
                    vcs.remove(at: vcs.count - 2)
                    vc.navigationController!.setViewControllers(vcs, animated: false)
                }
            }
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: rx.disposeBag)

        headerCell.depositButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            let vc = ViteXTokenSelectorViewController(type: .wallet, filter: .gateway) { (tokenInfo, vc) in
                let ccVC = CrossChainStatementViewController(tokenInfo: tokenInfo)
                ccVC.isWithDraw = false
                UIViewController.current?.navigationController?.pushViewController(ccVC, animated: true)
                GCD.delay(0.3) {
                    var vcs = vc.navigationController!.viewControllers
                    vcs.remove(at: vcs.count - 2)
                    vc.navigationController!.setViewControllers(vcs, animated: false)
                }
            }
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: rx.disposeBag)

        headerCell.withdrawButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            let vc = ViteXTokenSelectorViewController(type: .wallet, filter: .gateway) { (tokenInfo, vc) in
                let ccVC = CrossChainStatementViewController(tokenInfo: tokenInfo)
                ccVC.isWithDraw = true
                UIViewController.current?.navigationController?.pushViewController(ccVC, animated: true)
                GCD.delay(0.3) {
                    var vcs = vc.navigationController!.viewControllers
                    vcs.remove(at: vcs.count - 2)
                    vc.navigationController!.setViewControllers(vcs, animated: false)
                }
            }
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: rx.disposeBag)

        headerCell.hideButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            var ret = AppSettingsService.instance.appSettings.dexHideSmall
            ret.toggle()
            AppSettingsService.instance.updateDexHideSmall(ret)
        }.disposed(by: rx.disposeBag)

        headerCell.sortButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            let ret = self.sortModeBehaviorRelay.value.next
            self.sortModeBehaviorRelay.accept(ret)
        }.disposed(by: rx.disposeBag)

        AppSettingsService.instance.appSettingsDriver.map { $0.dexHideSmall }.drive(headerCell.hideButton.rx.isSelected).disposed(by: rx.disposeBag)
        sortModeBehaviorRelay.bind{[weak self] sortMode in
            guard let `self` = self else { return }
            switch sortMode {
            case .default:
                self.headerCell.sortButton.setImage(R.image.icon_dex_home_sort_default(), for: .normal)
            case .a2z:
                self.headerCell.sortButton.setImage(R.image.icon_dex_home_sort_a2z(), for: .normal)
            case .z2a:
                self.headerCell.sortButton.setImage(R.image.icon_dex_home_sort_z2a(), for: .normal)
            }
        }.disposed(by: rx.disposeBag)

        switch type {
        case .wallet:
            Driver.combineLatest(ExchangeRateManager.instance.rateMapDriver, ViteBalanceInfoManager.instance.balanceInfosDriver, AppSettingsService.instance.appSettingsDriver.map { $0.dexHideSmall }, sortModeBehaviorRelay.asDriver()).drive(onNext: { [weak self] (_, _, hideSmall, sortMode) in
                guard let `self` = self else { return }
                let dexTokenInfos = TokenInfoCacheService.instance.dexTokenInfos
                var vms: [DexAssetsHomeCellViewModel] = dexTokenInfos.map { tokenInfo in
                    let balance = ViteBalanceInfoManager.instance.balanceInfo(forViteTokenId: tokenInfo.viteTokenId)?.total ?? Amount()
                    let balanceString = tokenInfo.amountString(amount: balance, precision: .short)
                    let legalString = tokenInfo.legalString(amount: balance)
                    let btcValuation = tokenInfo.btcValuationForBasicUnit(amount: balance)
                    return DexAssetsHomeCellViewModel(tokenInfo: tokenInfo, balanceString: balanceString, legalString: legalString, btcValuation: btcValuation)
                }

                self.btcValuationBehaviorRelay.accept(vms.map{ $0.btcValuation }.reduce(BigDecimal(), +))

                if hideSmall {
                    vms = vms.filter { $0.isValuable }
                }

                switch sortMode {
                case .default:
                    vms = vms.sorted { DexAssetsHomeCellViewModel.defaultIncreasingOrder(e1: $0, e2: $1) }
                case .a2z:
                    vms = vms.sorted { $0.tokenInfo.uniqueSymbol < $1.tokenInfo.uniqueSymbol }
                case .z2a:
                    vms = vms.sorted { $0.tokenInfo.uniqueSymbol > $1.tokenInfo.uniqueSymbol }
                }

                self.viewModelBehaviorRelay.accept(vms)
                self.tableView.reloadData()
            }).disposed(by: rx.disposeBag)
        case .vitex:
            Driver.combineLatest(ExchangeRateManager.instance.rateMapDriver, ViteBalanceInfoManager.instance.dexBalanceInfosDriver, AppSettingsService.instance.appSettingsDriver.map { $0.dexHideSmall }, sortModeBehaviorRelay.asDriver()).drive(onNext: { [weak self] (_, _, hideSmall, sortMode) in
                guard let `self` = self else { return }
                let dexTokenInfos = TokenInfoCacheService.instance.dexTokenInfos
                var vms: [DexAssetsHomeCellViewModel] = dexTokenInfos.map { tokenInfo in
                    let balance = ViteBalanceInfoManager.instance.dexBalanceInfo(forViteTokenId: tokenInfo.viteTokenId)?.total ?? Amount()
                    let balanceString = tokenInfo.amountString(amount: balance, precision: .short)
                    let legalString = tokenInfo.legalString(amount: balance)
                    let btcValuation = tokenInfo.btcValuationForBasicUnit(amount: balance)
                    return DexAssetsHomeCellViewModel(tokenInfo: tokenInfo, balanceString: balanceString, legalString: legalString, btcValuation: btcValuation)
                }

                self.btcValuationBehaviorRelay.accept(vms.map{ $0.btcValuation }.reduce(BigDecimal(), +))

                if hideSmall {
                    vms = vms.filter { $0.isValuable }
                }

                switch sortMode {
                case .default:
                    vms = vms.sorted { $0.btcValuation > $1.btcValuation }
                case .a2z:
                    vms = vms.sorted { $0.tokenInfo.uniqueSymbol < $1.tokenInfo.uniqueSymbol }
                case .z2a:
                    vms = vms.sorted { $0.tokenInfo.uniqueSymbol > $1.tokenInfo.uniqueSymbol }
                }

                self.viewModelBehaviorRelay.accept(vms)
                self.tableView.reloadData()
            }).disposed(by: rx.disposeBag)
        }

        btcValuationBehaviorRelay.asDriver().drive(onNext: { [weak self] bigDecimal in
            guard let `self` = self else { return }
            self.headerCell.btcLabel.text = BigDecimalFormatter.format(bigDecimal: bigDecimal, style: .decimalRound(8), padding: .none, options: [.groupSeparator])
            self.headerCell.legalLabel.text = "≈" + ExchangeRateManager.instance.rateMap.btcPriceString(btc: bigDecimal)
        }).disposed(by: rx.disposeBag)
    }
}

extension DexAssetsHomeTableViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return viewModelBehaviorRelay.value.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return headerCell
        } else {
            let cell: DexAssetsHomeCell = tableView.dequeueReusableCell(for: indexPath)
            cell.bind(vm: viewModelBehaviorRelay.value[indexPath.row])
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 199 : 66
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            tableView.deselectRow(at: indexPath, animated: true)
            let vc = DexTokenDetailViewController(tokenInfo: viewModelBehaviorRelay.value[indexPath.row].tokenInfo,type: type)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
