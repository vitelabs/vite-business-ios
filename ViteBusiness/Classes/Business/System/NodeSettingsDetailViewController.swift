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
    let addButton = UIButton(style: .blue, title: R.string.localizable.nodeSettingsPageAddButtonTitle())
    
    init(chainType: AppSettingsService.ChainType) {
        self.chainType = chainType
        super.init(.grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(netHex: 0xf1f2f6)
        navigationItem.title = "\(self.chainType.rawValue) \(R.string.localizable.nodeSettingsPageTitle())"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.contentInsetAdjustmentBehavior = .never
        
        
        view.addSubview(addButton)
        addButton.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview().inset(24)
            m.bottom.equalTo(view.safeAreaLayoutGuideSnpBottom).offset(-24)
        }
        
        tableView.snp.remakeConstraints { (m) in
            m.top.left.right.equalToSuperview()
            m.bottom.equalTo(addButton.snp.top)
        }
        
        bind()
    }
    
    func bind() {
        AppSettingsService.instance.appSettingsDriver.map { $0.chainNodeConfigs }.drive(onNext: { [weak self] (_) in
            self?.tableView.reloadData()
        }).disposed(by: rx.disposeBag)
         
        
        let type = self.chainType
        AppSettingsService.instance.appSettingsDriver.map { s -> String? in
            for config in s.chainNodeConfigs where config.type == type {
                return config.current
            }
            fatalError()
        }.distinctUntilChanged().skip(1).drive(onNext: { d in
            ViteBusinessLanucher.instance.configProvider()
        }).disposed(by: rx.disposeBag)
        
        addButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            
            Alert.show(title: R.string.localizable.nodeSettingsPageAddAlertTitle(), message: R.string.localizable.nodeSettingsPageAddAlertTip(self.chainType.rawValue), actions: [
                (.cancel, nil),
                (.default(title: R.string.localizable.confirm()), { [weak self] alert in
                    guard let `self` = self else { return }
                    let text = alert.textFields?.first?.text ?? ""
                    var config = AppSettingsService.instance.getNodeConfig(type: self.chainType)
                    
                    guard !config.nodes.contains(text) else {
                        Toast.show(R.string.localizable.nodeSettingsPageNodeExistError())
                        return
                    }
                    
                    HUD.show()
                    self.chainType.check(node: text) { [weak self] (result) in
                        HUD.hide()
                        guard let `self` = self else { return }
                        if result {
                            config.nodes.append(text)
                            AppSettingsService.instance.updateNode(type: self.chainType, config: config)
                        } else {
                            Toast.show(R.string.localizable.nodeSettingsPageNodeInvalidError())
                        }
                    }
                }),
                ], config: { alert in
                    alert.addTextField(configurationHandler: { (textField) in
                        textField.clearButtonMode = .always
                        textField.text = ""
                        textField.placeholder = "https://"
                    })
            })
        }.disposed(by: rx.disposeBag)
    }
    
    func updateViteNode(config: AppSettingsService.ChainNodeConfig) {
        var srcConfig = AppSettingsService.instance.getNodeConfig(type: AppSettingsService.ChainType.vite)
        let srcViteNetworkType = AppSettingsService.ViteNetworkType.typeFor(node: srcConfig.current)
        let dstViteNetworkType = AppSettingsService.ViteNetworkType.typeFor(node: config.current)
        if srcViteNetworkType == dstViteNetworkType {
            AppSettingsService.instance.updateNode(type: AppSettingsService.ChainType.vite, config: config)
        } else {
            Alert.show(title: R.string.localizable.nodeSettingsPageSwitchNodeAlertTitle(), message: R.string.localizable.nodeSettingsPageSwitchNodeAlertMessage(srcViteNetworkType.name(), dstViteNetworkType.name()), actions: [
                (.default(title: R.string.localizable.cancel()), nil),
                (.default(title: R.string.localizable.confirm()), { _ in
                    AppSettingsService.instance.updateNode(type: AppSettingsService.ChainType.vite, config: config)
                    // change ViteNetworkType need exit
                    exit(0)
                }),
                ])
        }
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
        let config = AppSettingsService.instance.appSettings.chainNodeConfigs.filter { $0.type == self.chainType }[0]
        
        if indexPath.section == 0 {
            switch self.chainType {
            case .vite:
                cell.valueLabel.text = ViteConst.instance.vite.nodeHttp
            }
            cell.flagView.isHidden = config.current != nil
        } else {
            cell.valueLabel.text = config.nodes[indexPath.row]
            cell.flagView.isHidden = !(cell.valueLabel.text == config.current)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NodeSettingsDetailCell.cellHeight()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var config = AppSettingsService.instance.getNodeConfig(type: self.chainType)
        config.current = indexPath.section == 0 ? nil : config.nodes[indexPath.row]

        switch self.chainType {
        case .vite:
            self.updateViteNode(config: config)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1 {
            var config = AppSettingsService.instance.getNodeConfig(type: self.chainType)
            if config.nodes[indexPath.row] == config.current {
                return nil
            } else {
                let deleteAction = UIContextualAction(style: .destructive, title: R.string.localizable.delete()) { (action, sourceView, completionHandler) in
                    config.nodes.remove(at: indexPath.row)
                    AppSettingsService.instance.updateNode(type: self.chainType, config: config)
                    completionHandler(true)
                }

                let actionsConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
                actionsConfiguration.performsFirstActionWithFullSwipe = false
                return actionsConfiguration
            }
        } else {
            return nil
        }
    }
}
