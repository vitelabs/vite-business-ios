//
//  DebugHomeViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2019/6/17.
//

#if DAPP
import UIKit
import Eureka
import ViteWallet

public class DebugHomeViewController: FormViewController {

    public static func createNavVC() -> BaseNavigationController {
        let vc = DebugHomeViewController()
        let nav = BaseNavigationController(rootViewController: vc).then {
            $0.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            $0.tabBarItem.image = R.image.icon_tabbar_debug()?.withRenderingMode(.alwaysOriginal)
            $0.tabBarItem.selectedImage = R.image.icon_tabbar_debug_select()?.withRenderingMode(.alwaysOriginal)
        }
        return nav
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        updateTitle()
        setupView()
    }

    func updateTitle() {
        navigationItem.title = "Debug"
    }

    func setupView() {
        form
            +++
            Section {
                $0.header = HeaderFooterView(title: "RPC URL")
            }
            <<< LabelRow("rpcCustomUrl") {
                if let _ = URL(string: DebugService.instance.config.rpcCustomUrl) {
                    $0.title = "Custom"
                    $0.value = DebugService.instance.config.rpcCustomUrl
                } else {
                    $0.title = "Pre-Mainnet"
                    $0.value = ViteConst.Env.premainnet.vite.nodeHttp
                }
                }.onCellSelection({ [weak self] _, _  in
                    Alert.show(into: self, title: "RPC Custom URL", message: nil, actions: [
                        (.cancel, nil),
                        (.default(title: "OK"), { [weak self] alert in
                            guard let `self` = self else { return }
                            guard let cell = self.form.rowBy(tag: "rpcCustomUrl") as? LabelRow else { return }
                            if let text = alert.textFields?.first?.text, (text.hasPrefix("http://") || text.hasPrefix("https://")), let url = URL(string: text) {
                                DebugService.instance.config.rpcCustomUrl = text
                                cell.title = "Custom"
                                cell.value = text
                                cell.updateCell()
                                Provider.default.update(server: ViteWallet.RPCServer(url: url))
                            } else if let text = alert.textFields?.first?.text, text.isEmpty {
                                DebugService.instance.config.rpcCustomUrl = ""
                                cell.title = "Pre-Mainnet"
                                cell.value = ViteConst.Env.premainnet.vite.nodeHttp
                                cell.updateCell()
                                Provider.default.update(server: ViteWallet.RPCServer(url: URL(string: ViteConst.Env.premainnet.vite.nodeHttp)!))
                            } else {
                                Toast.show("Error Format")
                            }
                            self.updateTitle()
                        }),
                        ], config: { alert in
                            alert.addTextField(configurationHandler: { (textField) in
                                textField.clearButtonMode = .always
                                textField.text = DebugService.instance.config.rpcCustomUrl
                                textField.placeholder = ViteConst.Env.premainnet.vite.nodeHttp
                            })
                    })
                })
            +++
            MultivaluedSection(multivaluedOptions: [],
                               header: "Dapp",
                               footer: "") { section in

                                section <<< LabelRow("Add URL") {
                                    $0.title = "Add URL"
                                    $0.value = ""
                                    }.onCellSelection { [weak self] _, _ in
                                        self?.goToInputUrl()
                                }

                                DebugService.instance.config.urls.forEach({ (string) in
                                    section <<< LabelRow(string) {
                                        $0.title =  string
                                        }.onCellSelection({ [weak self] _, _  in
                                            guard let `self` = self else { return }
                                            let url = URL(string: string)!
                                            let vc = WKWebViewController(url: url)
                                            self.navigationController?.pushViewController(vc, animated: true)
                                        })
                                })
        }
    }

    func goToInputUrl() {
        let controller = AlertControl(title: "Input URL", message: nil)
        let cancelAction = AlertAction(title: "Cancel", style: .light, handler: nil)
        let okAction = AlertAction(title: "Go", style: .light) { [weak self] controller in
            let textField = (controller.textFields?.first)! as UITextField
            guard let text = textField.text, (text.lowercased().hasPrefix("http://") || text.lowercased().hasPrefix("https://")), let url = URL(string:text) else {
                Toast.show("Invalid URL")
                return
            }
            let vc = WKWebViewController(url: url)
            self?.navigationController?.pushViewController(vc, animated: true)
            DebugService.instance.config.urls.append(url.absoluteString)
            self?.form.removeAll()
            self?.setupView()
        }
        controller.addTextField { (textField) in
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
            textField.placeholder = "http:// or https://"
        }
        controller.addAction(cancelAction)
        controller.addAction(okAction)
        controller.show()
    }
}

#endif
