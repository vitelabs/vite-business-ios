//
//  BifrostTaskListViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2019/8/20.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import RxDataSources

class BifrostTaskListViewController: BaseTableViewController {


    typealias DataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, BifrostViteSendTxTask>>

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }

    fileprivate func setupView() {
        navigationTitleView = NavigationTitleView(title: R.string.localizable.bifrostListPageTitle())

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.icon_button_vb_disconnect(), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(onDisconnect))
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        tableView.rowHeight = BifrostTaskCell.cellHeight
        tableView.estimatedRowHeight = BifrostTaskCell.cellHeight

        if #available(iOS 11.0, *) {
            
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }

    @objc fileprivate func onDisconnect() {
        Statistics.log(eventId: Statistics.Page.WalletHome.bifrostDis.rawValue)
        Alert.show(title: R.string.localizable.bifrostAlertQuitTitle(),
                   message: nil,
                   actions: [
                    (.cancel, nil),
                    (.default(title: R.string.localizable.quit()), { _ in
                        BifrostManager.instance.disConnectByUser()
                        Statistics.log(eventId: Statistics.Page.WalletHome.bifrostDisConfirm.rawValue)
                    })
            ])
    }

    fileprivate let dataSource = DataSource(configureCell: { (_, tableView, indexPath, item) -> UITableViewCell in
        let cell: BifrostTaskCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(task: item)
        return cell
    })

    fileprivate func bind() {

        BifrostManager.instance.allTasksDriver.map({ $0.count > 0 }).drive(onNext: { [weak self] has in
            self?.dataStatus = has ? .normal : .empty
        }).disposed(by: rx.disposeBag)

        BifrostManager.instance.allTasksDriver.asObservable()
            .map { tasks in
                [SectionModel(model: "task", items: tasks)]
            }
            .bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: rx.disposeBag)

        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        tableView.rx.itemSelected
            .bind { [weak self] indexPath in
                guard let `self` = self else { fatalError() }
                if let task = (try? self.dataSource.model(at: indexPath)) as? BifrostViteSendTxTask {
                    self.tableView.deselectRow(at: indexPath, animated: true)
                    let vc = BifrostTaskDetailViewController(task: task)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .disposed(by: rx.disposeBag)
    }
}

extension BifrostTaskListViewController: ViewControllerDataStatusable {

    func emptyView() -> UIView {
        return UIView.defaultPlaceholderView(text: "", image: R.image.empty())
    }
}
