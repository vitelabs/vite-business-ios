//
//  CurrencyViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/12.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import RxDataSources

class CurrencyViewController: BaseTableViewController {

    typealias DataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, CurrencyCode>>

    let selectCurrency: BehaviorRelay<CurrencyCode?> = BehaviorRelay(value: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }

    fileprivate func setupView() {
        navigationTitleView = NavigationTitleView(title: R.string.localizable.systemPageCellChangeCurrency())

        tableView.rowHeight = CurrencyCell.cellHeight()
        tableView.estimatedRowHeight = CurrencyCell.cellHeight()
        tableView.separatorStyle = .none
    }

    fileprivate let dataSource = DataSource(configureCell: { (_, tableView, indexPath, item) -> UITableViewCell in
        let cell: CurrencyCell = tableView.dequeueReusableCell(for: indexPath)
        cell.nameLabel.text = item.name
        return cell
    })

    let viewModel = BehaviorRelay(value: CurrencyCode.allValues)
    fileprivate func bind() {

        viewModel.asObservable()
            .map { [SectionModel(model: "currency", items: $0)] }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)

        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)

        tableView.rx.itemSelected
            .bind { [weak self] indexPath in
                guard let `self` = self else { fatalError() }
                if let viewModel = (try? self.dataSource.model(at: indexPath)) as? CurrencyCode {
                    self.tableView.deselectRow(at: indexPath, animated: true)
                    AppSettingsService.instance.updateCurrency(viewModel)
                    self.selectCurrency.accept(viewModel)
                    self.navigationController?.popViewController(animated: true)
                }
            }
            .disposed(by: rx.disposeBag)
    }

}
