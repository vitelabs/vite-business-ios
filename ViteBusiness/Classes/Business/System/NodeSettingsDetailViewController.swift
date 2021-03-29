//
//  NodeSettingsDetailViewController.swift
//  ViteBusiness
//
//  Created by stone on 2021/3/26.
//

import Foundation
import RxSwift
import RxCocoa
import ViteWallet

class NodeSettingsDetailViewController: BaseTableViewController {
    
    let chainType: AppSettingsService.ChainType
    
    init(chainType: AppSettingsService.ChainType) {
        self.chainType = chainType
        super.init(.grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "\(self.chainType.rawValue) \(R.string.localizable.nodeSettingsPageTitle())"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.contentInsetAdjustmentBehavior = .never
    }
}

extension NodeSettingsDetailViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            let config = AppSettingsService.instance.appSettings.chainNodeConfigs.filter { $0.type == self.chainType }[0]
            return config.nodes.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NodeSettingsDetailCell = tableView.dequeueReusableCell(for: indexPath)
        if indexPath.section == 0 {
            switch self.chainType {
            case .vite:
                cell.valueLabel.text = ViteConst.instance.vite.nodeHttp
            case .eth:
                cell.valueLabel.text = ViteConst.instance.eth.nodeHttp
            }
        } else {
            let config = AppSettingsService.instance.appSettings.chainNodeConfigs.filter { $0.type == self.chainType }[0]
            cell.valueLabel.text = config.nodes[indexPath.row]
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NodeSettingsDetailCell.cellHeight()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

    }
}
