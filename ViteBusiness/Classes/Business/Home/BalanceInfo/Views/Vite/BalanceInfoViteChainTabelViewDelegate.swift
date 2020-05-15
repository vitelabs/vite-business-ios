//
//  BalanceInfoViteChainTabelViewDelegate.swift
//  ViteBusiness
//
//  Created by Stone on 2019/2/28.
//

import UIKit
import ViteWallet
import RxSwift
import RxCocoa
import NSObject_Rx
import RxDataSources

class BalanceInfoViteChainTabelViewDelegate: NSObject, BalanceInfoDetailTableViewDelegate, UITableViewDelegate {

    let tokenInfo: TokenInfo
    let tableViewHandler: TableViewHandler
    let token: Token


    // BalanceInfoDetailTableViewDelegate Start
    required init(tokenInfo: TokenInfo, tableViewHandler: TableViewHandler) {
        self.tokenInfo = tokenInfo
        self.tableViewHandler = tableViewHandler
        self.token = tokenInfo.toViteToken()!
        super.init()

        tableViewHandler.tableView.separatorStyle = .none
        tableViewHandler.tableView.rowHeight = TransactionCell.cellHeight
        tableViewHandler.tableView.estimatedRowHeight = TransactionCell.cellHeight

        tableViewHandler.didPullDown = { [weak self] finished in
            guard let `self` = self else { return }
            self.refresh(finished: { [weak self] (_) in
                guard let `self` = self else { return }
                finished(self.tableViewModel.hasMore.value)
            })
        }

        tableViewHandler.didPullUp = { [weak self] finished in
            guard let `self` = self else { return }
            self.getMore(finished: { [weak self] (_) in
                guard let `self` = self else { return }
                finished(self.tableViewModel.hasMore.value)
            })
        }

        HDWalletManager.instance.accountDriver.filterNil().drive(onNext: { [weak self] (account) in
            self?.bind(address: account.address)
        }).disposed(by: rx.disposeBag)
    }

    func getMore(finished: @escaping (Error?) -> ()) {
        tableViewHandler.status = .getMore
        self.tableViewModel.getMore { [weak self] error in
            guard let `self` = self else { return }
            self.tableViewHandler.status = .normal
            if let e = error {
                Toast.show(e.localizedDescription)
            }
            finished(error)
        }
    }

    func refresh(finished: @escaping (Error?) -> ()) {
        tableViewHandler.status = .refresh
        tableViewModel.refreshList { [weak self] error in
            guard let `self` = self else { return }
            if let error = error {
                self.tableViewHandler.status = .error
            } else {
                if self.tableViewHandler.tableView.numberOfRows(inSection: 0) > 0 {
                    self.tableViewHandler.status = .normal
                } else {
                    self.tableViewHandler.status = .empty
                }
            }
            finished(error)
        }
    }

    var emptyTipView: UIView {
        return TableViewPlaceholderView(imageType: .empty, viewType: .text(R.string.localizable.transactionListPageEmpty()))
    }

    var networkErrorTipView: UIView {
        return TableViewPlaceholderView(imageType: .networkError, viewType: .button(R.string.localizable.transactionListTransactionNetErrorAndShowAccount(), {
            var urlStr = "\(ViteConst.instance.vite.explorer)/account/\(HDWalletManager.instance.account?.address ?? "")"
            let vc = WKWebViewController(url: URL.init(string: urlStr)!)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        }))
    }

    // BalanceInfoDetailTableViewDelegate End


    typealias DataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, TransactionViewModelType>>

    var tableViewModel: TransactionListTableViewModel!

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return generateSectionHeaderView(title: R.string.localizable.transactionListPageTitle())
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeaderViewHeight
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    let dataSource = DataSource(configureCell: { (_, tableView, indexPath, item) -> UITableViewCell in
        if item.isGenesis {
            let cell: TransactionGenesisCell = tableView.dequeueReusableCell(for: indexPath)
            cell.bind(viewModel: item, index: indexPath.row)
            return cell
        } else {
            let cell: TransactionCell = tableView.dequeueReusableCell(for: indexPath)
            cell.bind(viewModel: item, index: indexPath.row)
            return cell
        }
    })

    func bind(address: ViteAddress) {

        if tableViewModel == nil {
            tableViewModel = TransactionListTableViewModel(address: address, token: token)

            tableViewModel.transactionsDriver.asObservable()
                .map { [SectionModel(model: "transaction", items: $0)] }
                .bind(to: tableViewHandler.tableView.rx.items(dataSource: dataSource)).disposed(by: rx.disposeBag)

            tableViewHandler.tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
            tableViewHandler.tableView.rx.itemSelected
                .bind { [weak self] indexPath in
                    guard let `self` = self else { return }
                    self.tableViewHandler.tableView.deselectRow(at: indexPath, animated: true)
                    if let viewModel = (try? self.dataSource.model(at: indexPath)) as? TransactionViewModel {
                        let vc = TransactionDetailViewController(holder: ViteTransactionDetailHolder(accountBlock: viewModel.accountBlock))
                        UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
//                        if viewModel.isGenesis {
//                            // do nothing
//                            // WebHandler.openTranscationGenesisPage(hash: viewModel.hash)
//                        } else {
//                            WebHandler.openTranscationDetailPage(hash: viewModel.hash)
//                        }
                    }
                }
                .disposed(by: rx.disposeBag)
        } else {
            tableViewModel.update(address: address)
        }
        tableViewHandler.refresh()
    }
}
