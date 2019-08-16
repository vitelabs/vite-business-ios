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
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        tableView.rowHeight = BifrostTaskCell.cellHeight
        tableView.estimatedRowHeight = BifrostTaskCell.cellHeight

        if #available(iOS 11.0, *) {
            
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }

    fileprivate let dataSource = DataSource(configureCell: { (_, tableView, indexPath, item) -> UITableViewCell in
        let cell: BifrostTaskCell = tableView.dequeueReusableCell(for: indexPath)
//        cell.bind(viewModel: item)
        cell.textLabel?.text = "\(item.timestamp.format("yyyy.MM.dd HH:mm:ss")) \(item.info.title) \(item.status)"
        return cell
    })

    fileprivate func bind() {

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

//                    self.navigationController?.pushViewController(balanceInfoDetailViewController, animated: true)
                }
            }
            .disposed(by: rx.disposeBag)
    }
}
