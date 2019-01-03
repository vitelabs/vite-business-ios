//
//  DebugEnvironmentViewController.swift
//  Pods
//
//  Created by Stone on 2019/1/3.
//

#if DEBUG || TEST
import UIKit
import Eureka

class DebugEnvironmentViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        updateTitle()
        setupView()
    }

    func updateTitle() {
        navigationItem.title = "Environment: \(DebugService.instance.config.appEnvironment.name)"
    }

    func setupView() {
        form
            +++
            Section {
                $0.header = HeaderFooterView(title: "Wallet")
            }
            <<< SwitchRow("useBigDifficulty") {
                $0.title = "Use Big Difficulty (Use GPU)"
                $0.value = DebugService.instance.config.useBigDifficulty
                }.onChange { [weak self] row in
                    guard let `self` = self else { return }
                    guard let ret = row.value else { return }
                    DebugService.instance.config.useBigDifficulty = ret
                    self.updateTitle()
            }
            +++
            Section {
                $0.header = HeaderFooterView(title: "RPC")
            }
            <<< SwitchRow("rpcUseOnlineUrl") {
                $0.title = "Use Online URL"
                $0.value = DebugService.instance.config.rpcUseOnlineUrl
                }.onChange { [weak self] row in
                    guard let `self` = self else { return }
                    guard let ret = row.value else { return }
                    DebugService.instance.config.rpcUseOnlineUrl = ret
                    self.updateTitle()
            }
            <<< LabelRow("rpcCustomUrl") {
                $0.hidden = "$rpcUseOnlineUrl == true"
                if let _ = URL(string: DebugService.instance.config.rpcCustomUrl) {
                    $0.title = "Custom URL"
                    $0.value = DebugService.instance.config.rpcCustomUrl
                } else {
                    $0.title = "Test URL"
                    $0.value = DebugService.instance.rpcDefaultTestEnvironmentUrl.absoluteString
                }
                }.onCellSelection({ [weak self] _, _  in
                    Alert.show(into: self, title: "RPC Custom URL", message: nil, actions: [
                        (.cancel, nil),
                        (.default(title: "OK"), { [weak self] alert in
                            guard let `self` = self else { return }
                            guard let cell = self.form.rowBy(tag: "rpcCustomUrl") as? LabelRow else { return }
                            if let text = alert.textFields?.first?.text, (text.hasPrefix("http://") || text.hasPrefix("https://")), let _ = URL(string: text) {
                                DebugService.instance.config.rpcCustomUrl = text
                                cell.title = "Custom"
                                cell.value = text
                                cell.updateCell()
                            } else if let text = alert.textFields?.first?.text, text.isEmpty {
                                DebugService.instance.config.rpcCustomUrl = ""
                                cell.title = "Test"
                                cell.value = DebugService.instance.rpcDefaultTestEnvironmentUrl.absoluteString
                                cell.updateCell()
                            } else {
                                Toast.show("Error Format")
                            }
                            self.updateTitle()
                        }),
                        ], config: { alert in
                            alert.addTextField(configurationHandler: { (textField) in
                                textField.clearButtonMode = .always
                                textField.text = DebugService.instance.config.rpcCustomUrl
                                textField.placeholder = DebugService.instance.rpcDefaultTestEnvironmentUrl.absoluteString
                            })
                    })
                })
            +++
            Section {
                $0.header = HeaderFooterView(title: "Browser")
            }
            <<< SwitchRow("browserUseOnlineUrl") {
                $0.title = "Use Online URL"
                $0.value = DebugService.instance.config.browserUseOnlineUrl
                }.onChange { [weak self] row in
                    guard let `self` = self else { return }
                    guard let ret = row.value else { return }
                    DebugService.instance.config.browserUseOnlineUrl = ret
                    self.updateTitle()
            }
            <<< LabelRow("browserCustomUrl") {
                $0.hidden = "$browserUseOnlineUrl == true"
                if let _ = URL(string: DebugService.instance.config.browserCustomUrl) {
                    $0.title = "Custom URL"
                    $0.value = DebugService.instance.config.browserCustomUrl
                } else {
                    $0.title = "Test URL"
                    $0.value = DebugService.instance.browserDefaultTestEnvironmentUrl.absoluteString
                }
                }.onCellSelection({ [weak self] _, _  in
                    Alert.show(into: self, title: "Browser Custom URL", message: nil, actions: [
                        (.cancel, nil),
                        (.default(title: "OK"), { [weak self] alert in
                            guard let `self` = self else { return }
                            guard let cell = self.form.rowBy(tag: "browserCustomUrl") as? LabelRow else { return }
                            if let text = alert.textFields?.first?.text, (text.hasPrefix("http://") || text.hasPrefix("https://")), let _ = URL(string: text) {
                                DebugService.instance.config.browserCustomUrl = text
                                cell.title = "Custom"
                                cell.value = text
                                cell.updateCell()
                            } else if let text = alert.textFields?.first?.text, text.isEmpty {
                                DebugService.instance.config.browserCustomUrl = ""
                                cell.title = "Test"
                                cell.value = DebugService.instance.browserDefaultTestEnvironmentUrl.absoluteString
                                cell.updateCell()
                            } else {
                                Toast.show("Error Format")
                            }
                            self.updateTitle()
                        }),
                        ], config: { alert in
                            alert.addTextField(configurationHandler: { (textField) in
                                textField.clearButtonMode = .always
                                textField.text = DebugService.instance.config.browserCustomUrl
                                textField.placeholder = DebugService.instance.browserDefaultTestEnvironmentUrl.absoluteString
                            })
                    })
                })
            +++
            Section {
                $0.header = HeaderFooterView(title: "Config")
            }
            <<< LabelRow("configEnvironment") {
                $0.title = "Config Environment"
                $0.value = DebugService.instance.config.configEnvironment.name
                }.onCellSelection { [weak self] _, _ in
                    var actions = DebugService.ConfigEnvironment.allValues.map { config -> (Alert.UIAlertControllerAletrActionTitle, ((UIAlertController) -> Void)?) in
                        (.default(title: config.name), { [weak self] alert in
                            guard let `self` = self else { return }
                            guard let cell = self.form.rowBy(tag: "configEnvironment") as? LabelRow else { return }
                            DebugService.instance.config.configEnvironment = config
                            cell.value = config.name
                            cell.updateCell()
                            self.updateTitle()
                        })
                    }

                    actions.append((.cancel, nil))
                    DebugActionSheet.show(title: "Select Config Environment", message: nil, actions: actions)
        }
    }
}
#endif
