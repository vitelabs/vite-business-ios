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

        tableViewHandler.tableView.delegate = self
        DispatchQueue.main.async {
            tableViewHandler.status = .empty
        }
    }
    var emptyTipView: UIView {
        return TableViewPlaceholderView(imageType: .empty, viewType: .button(R.string.localizable.balanceInfoDetailShowTransactionsButtonTitle(), {
            var infoUrl = "\(ViteConst.instance.eth.explorer)/address/\(HDWalletManager.instance.ethAddress ?? "")"
            guard let url = URL(string: infoUrl) else { return }
            let vc = WKWebViewController.init(url: url)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        }))
    }
    // BalanceInfoDetailTableViewDelegate End

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
}
