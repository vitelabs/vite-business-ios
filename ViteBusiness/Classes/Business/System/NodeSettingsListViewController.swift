//
//  NodeSettingsListViewController.swift
//  ViteBusiness
//
//  Created by stone on 2021/3/26.
//

import Foundation
import RxSwift
import RxCocoa
import ViteWallet

class NodeSettingsListViewController: BaseTableViewController {

    init() {
        super.init(.grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = R.string.localizable.nodeSettingsPageTitle()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.contentInsetAdjustmentBehavior = .never
        
        AppSettingsService.instance.appSettingsDriver.map { $0.chainNodeConfigs }.drive(onNext: { [weak self] (_) in
            self?.tableView.reloadData()
        }).disposed(by: rx.disposeBag)
    }
}

extension NodeSettingsListViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NodeSettingsListCell = tableView.dequeueReusableCell(for: indexPath)
        let config = AppSettingsService.instance.appSettings.chainNodeConfigs[indexPath.row]
        cell.titleLabel.text = config.type.rawValue
        cell.valueLabel.text = AppSettingsService.instance.getNode(type: config.type)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NodeSettingsListCell.cellHeight()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let config = AppSettingsService.instance.appSettings.chainNodeConfigs[indexPath.row]
        let vc = NodeSettingsDetailViewController(chainType: config.type)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
