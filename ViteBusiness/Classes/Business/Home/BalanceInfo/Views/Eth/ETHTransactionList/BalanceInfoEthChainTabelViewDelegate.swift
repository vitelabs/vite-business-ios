//
//  BalanceInfoEthChainTabelViewDelegate.swift
//  ViteBusiness
//
//  Created by Stone on 2019/8/8.
//

import Foundation

import RxSwift
import RxCocoa
import NSObject_Rx
import RxDataSources

class BalanceInfoEthChainTabelViewDelegate: NSObject, BalanceInfoDetailTableViewDelegate, UITableViewDelegate {

    let tokenInfo: TokenInfo
    let tableViewHandler: TableViewHandler

    // BalanceInfoDetailTableViewDelegate Start
    required init(tokenInfo: TokenInfo, tableViewHandler: TableViewHandler) {
        self.tokenInfo = tokenInfo
        self.tableViewHandler = tableViewHandler
        super.init()

        tableViewHandler.tableView.separatorStyle = .none
        tableViewHandler.tableView.rowHeight = ETHTransactionCell.cellHeight
        tableViewHandler.tableView.estimatedRowHeight = ETHTransactionCell.cellHeight

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

        ETHWalletManager.instance.accountDriver.filterNil().drive(onNext: { [weak self] (account) in
            self?.bind(account: account)
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
        return TableViewPlaceholderView(imageType: .empty, viewType: .button(R.string.localizable.balanceInfoDetailShowTransactionsButtonTitle(), {
            var infoUrl = "\(ViteConst.instance.eth.explorer)/address/\(ETHWalletManager.instance.account?.address ?? "")"
            guard let url = URL(string: infoUrl) else { return }
            let vc = WKWebViewController.init(url: url)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        }))
    }
    // BalanceInfoDetailTableViewDelegate End

    typealias DataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, ETHTransactionViewModel>>

    var tableViewModel: ETHTransactionListTableViewModel!

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
        let cell: ETHTransactionCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(viewModel: item, index: indexPath.row)
        return cell
    })

    func bind(account: ETHAccount) {

        if tableViewModel == nil {
            tableViewModel = ETHTransactionListTableViewModel(account: account, tokenInfo: tokenInfo)

            tableViewModel.transactionsDriver.asObservable()
                .map { [SectionModel(model: "transaction", items: $0)] }
                .bind(to: tableViewHandler.tableView.rx.items(dataSource: dataSource)).disposed(by: rx.disposeBag)

            tableViewHandler.tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
            tableViewHandler.tableView.rx.itemSelected
                .bind { [weak self] indexPath in
                    guard let `self` = self else { return }
                    self.tableViewHandler.tableView.deselectRow(at: indexPath, animated: true)
                    if let viewModel = (try? self.dataSource.model(at: indexPath)) as? ETHTransactionViewModel {
                        if let transaction = viewModel.transaction {
                            let vc = TransactionDetailViewController(holder: ETHTransactionDetailHolder(transaction: transaction))
                            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
                        } else if let unconfirmed = viewModel.unconfirmed {
                            let vc = TransactionDetailViewController(holder: ETHTransactionDetailHolder(unconfirmed: unconfirmed, isShowingInEthList: self.tokenInfo.isEtherCoin))
                            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
                .disposed(by: rx.disposeBag)
        } else {
            tableViewModel.update(account: account)
        }
        self.tableViewHandler.status = .empty
        tableViewHandler.refresh()
    }
}
