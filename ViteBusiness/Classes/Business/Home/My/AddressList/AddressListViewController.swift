//
//  AddressListViewController.swift
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

class AddressListViewController: BaseTableViewController {

    
    let viewModel: AddressListViewModel
    init(viewModel: AddressListViewModel) {
        self.viewModel = viewModel
        super.init(.plain)
    }

    let selectAddress: BehaviorRelay<String?> = BehaviorRelay(value: nil)

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    typealias DataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, AddressViewModel>>

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }

    fileprivate func setupView() {
        navigationTitleView = NavigationTitleView(title: viewModel.title)

        tableView.rowHeight = AddressListCell.cellHeight()
        tableView.estimatedRowHeight = AddressListCell.cellHeight()
        tableView.separatorStyle = .none
    }

    fileprivate let dataSource = DataSource(configureCell: { (_, tableView, indexPath, item) -> UITableViewCell in
        let cell: AddressListCell = tableView.dequeueReusableCell(for: indexPath)
        cell.bind(viewModel: item)
        return cell
    })

    fileprivate func bind() {

        viewModel.addressesDriver.asObservable()
            .map { [SectionModel(model: "addresses", items: $0)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)

        viewModel.addressesDriver.map({ $0.count > 0 }).drive(onNext: { [weak self] has in
            self?.dataStatus = has ? .normal : .empty
        }).disposed(by: rx.disposeBag)

        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)

        tableView.rx.itemSelected
            .bind { [weak self] indexPath in
                guard let `self` = self else { fatalError() }
                if let viewModel = (try? self.dataSource.model(at: indexPath)) as? AddressViewModel {
                    self.tableView.deselectRow(at: indexPath, animated: true)
                    self.selectAddress.accept(viewModel.address)
                    self.navigationController?.popViewController(animated: true)
                }
            }
            .disposed(by: rx.disposeBag)
    }
}

extension AddressListViewController: ViewControllerDataStatusable {

    func emptyView() -> UIView {
        return UIView.defaultPlaceholderView(text: self.viewModel.emptyTip, image: R.image.icon_contacts_empty())
    }
}
