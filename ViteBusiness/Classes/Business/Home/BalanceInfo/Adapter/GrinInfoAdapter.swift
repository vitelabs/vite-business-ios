//
//  GrinInfoAdapter.swift
//  Action
//
//  Created by haoshenyang on 2019/9/2.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

class GrinInfoAdapter: NSObject, BalanceInfoDetailAdapter {

    required init(tokenInfo: TokenInfo, headerView: UIStackView, tableView: UITableView, vc: UIViewController?) {

        let contentVC = UIStoryboard(name: "GrinInfo", bundle: businessBundle())
            .instantiateInitialViewController() as! GrinInfoViewController
        vc?.addChild(contentVC)


        let view = UIView()
        view.frame = CGRect.init(x: 0, y: 0, width: kScreenW, height: 225)
        view.snp.makeConstraints { (m) in
            m.height.equalTo(225)
        }
        headerView.addArrangedSubview(view)
        view.addSubview(contentVC.view)
        contentVC.view.frame = CGRect.init(x: 0, y: 0, width: kScreenW, height: 225)
        contentVC.didMove(toParent: vc)

        let handler = TableViewHandler(tableView: tableView)
        let delegate = GrinInfoTableViewDelegate.init(tokenInfo: tokenInfo, tableViewHandler: handler)
        handler.delegate = delegate
        delegate.infoVc = contentVC as? GrinInfoViewController
        delegate.bind()

        self.delegate = delegate

        let nib = UINib.init(nibName: "GrinTransactionCell", bundle: businessBundle())
        tableView.register(nib, forCellReuseIdentifier: "GrinTransactionCell")


    }

    var delegate: BalanceInfoDetailTableViewDelegate?

    func viewDidAppear() {

    }
    func viewDidDisappear() {

    }
}


class GrinInfoTableViewDelegate: NSObject {

    let tokenInfo: TokenInfo
    let tableViewHandler: TableViewHandler
    var infoVc: GrinInfoViewController!
    var finished: ((Error?) -> ())?

    required init(tokenInfo: TokenInfo, tableViewHandler: TableViewHandler) {
        self.tokenInfo = tokenInfo
        self.tableViewHandler = tableViewHandler

        super.init()

        tableViewHandler.tableView.separatorStyle = .none
        tableViewHandler.tableView.rowHeight = TransactionCell.cellHeight
        tableViewHandler.tableView.estimatedRowHeight = TransactionCell.cellHeight

        tableViewHandler.tableView.delegate = self
        tableViewHandler.tableView.dataSource = self

        tableViewHandler.didPullDown = { [weak self] finished in
            guard let `self` = self else { return }
            self.refresh(finished: { [weak self] (_) in
                guard let `self` = self else { return }
                finished(false)
            })
        }

    }

    func bind() {
        self.infoVc.walletInfoVM.txsDriver
            .drive(onNext:{  [weak self] txs in
                self?.tableViewHandler.tableView.reloadData()
                if txs.isEmpty {
                    self?.tableViewHandler.status = .empty
                } else  {
                    self?.tableViewHandler.status = .normal
                }
                self?.finished?(nil)
                self?.finished = nil
            })
            .disposed(by: self.rx.disposeBag)
    }

}

extension GrinInfoTableViewDelegate: BalanceInfoDetailTableViewDelegate {

    func getMore(finished: @escaping (Error?) -> ()) {

    }

    func refresh(finished: @escaping (Error?) -> ()) {
        self.finished = finished
        self.infoVc.walletInfoVM.action.onNext(.getTxs(manually: true))
        self.infoVc.walletInfoVM.action.onNext(.getBalance(manually: true))
    }

    var emptyTipView: UIView {
        return TableViewPlaceholderView(imageType: .empty, viewType: .text(R.string.localizable.transactionListPageEmpty()))
    }

    var networkErrorTipView: UIView {
        return emptyTipView
    }
}

extension GrinInfoTableViewDelegate: UITableViewDelegate, UITableViewDataSource {

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


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.infoVc.walletInfoVM.txs.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GrinTransactionCell", for: indexPath) as! GrinTransactionCell
        let tx = self.infoVc.walletInfoVM.txs.value[indexPath.row]
        cell.bind(tx)
        return cell
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let tx = self.infoVc.walletInfoVM.txs.value[indexPath.row]
        var action = [UITableViewRowAction]()
        if let slateId = tx.txLogEntry?.txSlateId {
            let copyAction = UITableViewRowAction.init(style: .default, title:  R.string.localizable.grinTxCopyId()) { (_, _) in
                UIPasteboard.general.string = slateId
                }
                .then { $0.backgroundColor = UIColor(netHex: 0x479FFF)}
            action.append(copyAction)
        }

        if tx.txLogEntry?.canRepost == true {
            let repostAction = UITableViewRowAction.init(style: .default, title: R.string.localizable.grinTxRepost()) { (_, _) in
                self.infoVc.walletInfoVM.action.onNext(.repost(tx.txLogEntry!))
                }
                .then { $0.backgroundColor = UIColor(netHex: 0xFFC900)}
            action.append(repostAction)
        }

        if tx.txLogEntry?.canCancel == true {
            let cancleAction = UITableViewRowAction(style: .default, title:  R.string.localizable.cancel()) { (_, _) in
                self.infoVc.walletInfoVM.action.onNext(.cancel(tx.txLogEntry!))
                }
                .then { $0.backgroundColor = UIColor(netHex: 0xDEDFE0)}
            action.append(cancleAction)
        }
        return action
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.infoVc.parent?.view.displayLoading()
        GCD.delay(0) {
            let fullInfo = self.infoVc.walletInfoVM.txs.value[indexPath.row]
            self.infoVc.walletInfoVM.action.onNext(.getFullInfoDetail(fullInfo))
        }
    }
}
