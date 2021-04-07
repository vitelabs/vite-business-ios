//
//  HistoryViewController.swift
//  Vite
//
//  Created by haoshenyang on 2018/10/26.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import ReactorKit
import MJRefresh
import ViteWallet
import BigInt

extension Pledge {
    fileprivate var withdrawingKey: String {
        if let id = id {
            return id
        } else {
            return beneficialAddress
        }
    }
}

class PledgeHistoryViewController: BaseViewController, View {

    var disposeBag = DisposeBag()

    let tableView = UITableView()

    var withdrawingAddressSet: Set<String> = Set()

    override func viewDidLoad() {
        super.viewDidLoad()

        let navigationTitleView = NavigationTitleView.init(title: R.string.localizable.peldgeTitle(), style: .default)
        view.addSubview(navigationTitleView)
        navigationTitleView.snp.makeConstraints { (m) in
            m.top.equalTo(view.safeAreaLayoutGuideSnpTop)
            m.left.equalTo(view)
            m.right.equalTo(view)
        }

//        let descriptionView = PledgeHistoryDescriptionView()
//        view.addSubview(descriptionView)
//        descriptionView.snp.makeConstraints { (m) in
//            m.top.equalTo(navigationTitleView.snp.bottom).offset(12)
//            m.left.equalTo(self.view).offset(12)
//            m.right.equalTo(self.view).offset(-12)
//            m.height.equalTo(80)
//        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { (m) in
            m.left.right.equalTo(view)
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom)
            m.top.equalTo(navigationTitleView.snp.bottom).offset(12)
        }
        tableView.rowHeight = 100
        tableView.register(PledgeHistoryCell.self, forCellReuseIdentifier: "Cell")
        tableView.separatorColor = UIColor.init(netHex: 0xD3DFEF)
        tableView.tableFooterView = UIView()
        tableView.mj_header.beginRefreshing()
    }

    fileprivate func nameAndAddress(_ address: ViteAddress) -> String {
        let name = AddressManageService.instance.contactName(for: address) ?? AddressManageService.instance.name(for: address)
        return "\(name): \(address)"
    }

    func bind(reactor: PledgeHistoryViewReactor) {

        tableView.mj_header = RefreshHeader(refreshingBlock: { [weak reactor] in
            reactor?.action.onNext(.refresh)
        })

        tableView.mj_footer = RefreshFooter.footer { [weak reactor] in
            reactor?.action.onNext(.loadMore)
        }

        tableView.rx.itemSelected
            .bind { [weak self] indexPath in
                guard let `self` = self else { fatalError() }
                if let pledge = self.reactor?.currentState.pledges[indexPath.row] {
                    self.tableView.deselectRow(at: indexPath, animated: true)
                    WebHandler.openAddressDetailPage(address: pledge.beneficialAddress)
                }
            }
            .disposed(by: rx.disposeBag)

        reactor.state
            .map { $0.pledges }
            .bind(to: tableView.rx.items(cellIdentifier: "Cell")) {[weak self] _, pledge, cell in
                guard let `self` = self else { return }
                let cell = cell as! PledgeHistoryCell
                cell.addressLabel.text = self.nameAndAddress(pledge.beneficialAddress)
                cell.timeLabel.text = pledge.timestamp.format() + R.string.localizable.peldgeDeadline()
                cell.balanceLabel.text =  pledge.amount.amountShortWithGroupSeparator(decimals: ViteWalletConst.viteToken.decimals)
                cell.symbolLabel.text = "VITE"
                if self.withdrawingAddressSet.contains(pledge.withdrawingKey) {
                    cell.cancelButton.setTitle(R.string.localizable.peldgeCancelPledgeWithdrawingTitle(), for: .normal)
                    cell.cancelButton.isEnabled = false
                } else {
                    cell.cancelButton.setTitle(R.string.localizable.peldgeCancelPeldgeButtonTitle(), for: .normal)
                    cell.cancelButton.isEnabled = Date() > pledge.timestamp
                }
                cell.cancelButton.rx.tap.bind { [weak self, weak cell] in

                    guard !pledge.agent else {
                        Toast.show(R.string.localizable.peldgeCancelPledgeAgentErrorToast())
                        return
                    }

                    guard pledge.amount >= BigInt(134) * BigInt(10).power(ViteWalletConst.viteToken.decimals) else {
                        Toast.show(R.string.localizable.peldgeCancelPledgeAmountErrorToast())
                        return
                    }

                    let account = HDWalletManager.instance.account!

                    if let id = pledge.id {
                        Workflow.cancelQuotaStakingWithConfirm(account: account, id:id, beneficialAddress: pledge.beneficialAddress, amount: pledge.amount) { (ret) in
                            switch ret {
                            case .success:
                                self?.withdrawingAddressSet.insert(pledge.withdrawingKey)
                                cell?.cancelButton.setTitle(R.string.localizable.peldgeCancelPledgeWithdrawingTitle(), for: .normal)
                                cell?.cancelButton.isEnabled = false
                            case .failure:
                                break
                            }
                        }
                    } else {
                        Workflow.cancelPledgeWithConfirm(account: account, beneficialAddress: pledge.beneficialAddress, amount: pledge.amount, completion: { (ret) in
                            switch ret {
                            case .success:
                                self?.withdrawingAddressSet.insert(pledge.withdrawingKey)
                                cell?.cancelButton.setTitle(R.string.localizable.peldgeCancelPledgeWithdrawingTitle(), for: .normal)
                                cell?.cancelButton.isEnabled = false
                            case .failure:
                                break
                            }
                        })
                    }
                }.disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.pledges.count }
            .skip(2)
            .distinctUntilChanged()
            .bind { [weak self] in
                guard let `self` = self else { return }
                if $0 == 0 {
                    self.tableView.addSubview(self.emptyView)
                    self.emptyView.snp.makeConstraints({ (m) in
                        m.center.equalTo(self.tableView)
                        m.width.height.equalTo(self.tableView)
                    })
                } else if self.emptyView.superview != nil {
                    self.emptyView.removeFromSuperview()
                }
            }
            .disposed(by: disposeBag)

        reactor.state
            .distinctUntilChanged { $0.finisheLoading != $1.finisheLoading }
            .filter { $0.finisheLoading }
            .bind { [unowned self] _ in
                if self.tableView.mj_header.isRefreshing {
                    self.tableView.mj_header.endRefreshing()
                }
                if self.tableView.mj_footer.isRefreshing {
                    self.tableView.mj_footer.endRefreshing()
                }
            }
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.noMoreData }
            .bind { [unowned self] in
                self.tableView.mj_footer.state = $0 ? .noMoreData : .idle
            }
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.errorMessage }
            .filterNil()
            .bind { Toast.show($0) }
            .disposed(by: disposeBag)

    }

    lazy var emptyView = {
        return UIView.defaultPlaceholderView(text: R.string.localizable.transactionListPageEmpty())
    }()

}
