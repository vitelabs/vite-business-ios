//
//  ContactsListViewController.swift
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

class ContactsListViewController: BaseTableViewController {

    
    let viewModel: ContactsListViewModel
    let type: CoinType?
    init(viewModel: ContactsListViewModel, type: CoinType?) {
        self.viewModel = viewModel
        self.type = type
        super.init(.plain)
        view.backgroundColor = UIColor.clear
        tableView.backgroundColor = UIColor.clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    typealias DataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, ContactsViewModel>>

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }

    fileprivate func setupView() {
        tableView.rowHeight = ContactsListCell.cellHeight()
        tableView.estimatedRowHeight = ContactsListCell.cellHeight()
        tableView.separatorStyle = .none
    }

    fileprivate let dataSource = DataSource(configureCell: { (_, tableView, indexPath, item) -> UITableViewCell in
        let cell: ContactsListCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(viewModel: item)
        return cell
    })

    fileprivate func bind() {

        viewModel.contactsDriver.asObservable()
            .map { contacts in [SectionModel(model: "contacts", items: contacts.map({ ContactsViewModel(contact: $0)}) )] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)

        viewModel.contactsDriver.map({ $0.count > 0 }).drive(onNext: { [weak self] has in
            self?.dataStatus = has ? .normal : .empty
        }).disposed(by: rx.disposeBag)

        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)

        tableView.rx.itemSelected
            .bind { [weak self] indexPath in
                guard let `self` = self else { fatalError() }
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
            .disposed(by: rx.disposeBag)
    }
}

extension ContactsListViewController: ViewControllerDataStatusable {

    func emptyView() -> UIView {
        return UIView.defaultPlaceholderView(text: R.string.localizable.contactsHomePageSingleNoContactTip(self.type?.name ?? ""), image: R.image.icon_contacts_empty())
    }
}
