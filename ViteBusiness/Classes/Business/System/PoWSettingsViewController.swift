//
//  PoWSettingsViewController.swift
//  ViteBusiness
//
//  Created by stone on 2021/3/26.
//

import Foundation
import RxSwift
import RxCocoa
import ViteWallet
import JSONRPCKit
import PromiseKit
import BigInt

class PoWSettingsViewController: BaseTableViewController {
    
    let addButton = UIButton(style: .blue, title: R.string.localizable.powSettingsPageAddButtonTitle())
    
    init() {
        super.init(.grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(netHex: 0xf1f2f6)
        navigationItem.title = R.string.localizable.powSettingsPageTitle()
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
        AppSettingsService.instance.appSettingsDriver.map { $0.powConfig }.drive(onNext: { [weak self] (_) in
            self?.tableView.reloadData()
        }).disposed(by: rx.disposeBag)
        
        AppSettingsService.instance.appSettingsDriver.map {
            $0.powConfig.current ?? ViteConst.instance.vite.nodeHttp
        }.distinctUntilChanged().skip(1).drive(onNext: { url in
            Provider.pow.update(server: ViteWallet.RPCServer(url: URL(string: url)!))
        }).disposed(by: rx.disposeBag)
        
        addButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            
            Alert.show(title: R.string.localizable.powSettingsPageAddAlertTitle(), message: R.string.localizable.powSettingsPageAddAlertTip(), actions: [
                (.cancel, nil),
                (.default(title: R.string.localizable.confirm()), { [weak self] alert in
                    guard let `self` = self else { return }
                    let text = alert.textFields?.first?.text ?? ""
                    var config = AppSettingsService.instance.getPowConfig()
                    
                    guard text != ViteConst.instance.vite.nodeHttp else {
                        Toast.show(R.string.localizable.powSettingsPageNodeExistError())
                        return
                    }
                    
                    guard !config.urls.contains(text) else {
                        Toast.show(R.string.localizable.powSettingsPageNodeExistError())
                        return
                    }
                    
                    guard text.hasPrefix("https://") || text.hasPrefix("http://") else {
                        Toast.show(R.string.localizable.nodeSettingsPageNodeInvalidError())
                        return
                    }
                    
                    guard let _ = URL(string: text) else {
                        Toast.show(R.string.localizable.nodeSettingsPageNodeInvalidError())
                        return
                    }
                    
                    config.urls.append(text)
                    config.current = text
                    AppSettingsService.instance.updatePow(config: config)
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
}

extension PoWSettingsViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            let config = AppSettingsService.instance.appSettings.powConfig
            return config.urls.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NodeSettingsDetailCell = tableView.dequeueReusableCell(for: indexPath)
        let config = AppSettingsService.instance.appSettings.powConfig
        
        if indexPath.section == 0 {
            cell.valueLabel.text =  ViteConst.instance.vite.nodeHttp
            cell.flagView.isHidden = config.current != nil
        } else {
            cell.valueLabel.text = config.urls[indexPath.row]
            cell.flagView.isHidden = !(cell.valueLabel.text == config.current)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NodeSettingsDetailCell.cellHeight()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            var config = AppSettingsService.instance.getPowConfig()
            config.current = nil
            AppSettingsService.instance.updatePow(config: config)
        } else {
            var config = AppSettingsService.instance.getPowConfig()
            config.current = config.urls[indexPath.row]
            AppSettingsService.instance.updatePow(config: config)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1 {
            let deleteAction = UIContextualAction(style: .destructive, title: R.string.localizable.delete()) { (action, sourceView, completionHandler) in
                
                var config = AppSettingsService.instance.getPowConfig()
                if config.urls[indexPath.row] == config.current {
                    config.current = nil
                }
                config.urls.remove(at: indexPath.row)
                AppSettingsService.instance.updatePow(config: config)
                completionHandler(true)
            }

            let config = UISwipeActionsConfiguration(actions: [deleteAction])
            config.performsFirstActionWithFullSwipe = false
            return config

        } else {
            return nil
        }

    }
}

