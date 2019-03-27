//
//  DebugViewController.swift
//  Vite
//
//  Created by Stone on 2018/10/12.
//  Copyright © 2018年 vite labs. All rights reserved.
//
#if DEBUG || TEST
import UIKit
import Eureka
import Crashlytics
import ViteWallet
import BigInt

class DebugViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func setupView() {

        #if DEBUG || TEST
        navigationItem.title = "Debug"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.icon_nav_back_black(), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(_onCancel))

        form
            +++
            Section {
                $0.header = HeaderFooterView(title: "App")
            }
            <<< LabelRow("appVersion") {
                $0.title = "Version"
                #if INTERNAL
                #if DEBUG
                $0.value = "\(Bundle.main.versionNumber) (DE\(Bundle.main.buildNumber))"
                #else
                $0.value = "\(Bundle.main.versionNumber) (E\(Bundle.main.buildNumber))"
                #endif
                #elseif TEST
                #if DEBUG
                $0.value = "\(Bundle.main.versionNumber) (DT\(Bundle.main.buildNumber))"
                #else
                $0.value = "\(Bundle.main.versionNumber) (T\(Bundle.main.buildNumber))"
                #endif
                #elseif OFFICIAL
                #if DEBUG
                $0.value = "\(Bundle.main.versionNumber) (DA\(Bundle.main.buildNumber))"
                #else
                $0.value = "\(Bundle.main.versionNumber) (A\(Bundle.main.buildNumber))"
                #endif
                #else
                #if DEBUG
                $0.value = "\(Bundle.main.versionNumber) (DD\(Bundle.main.buildNumber))"
                #else
                $0.value = "\(Bundle.main.versionNumber) (D\(Bundle.main.buildNumber))"
                #endif
                #endif
            }.onCellSelection { _, _ in
            }
            <<< LabelRow("appEnvironment") {
                $0.title = "Environment"
                $0.value = DebugService.instance.config.appEnvironment.name
            }.onCellSelection { [weak self] _, _ in

                var actions = DebugService.AppEnvironment.allValues.map { config -> (Alert.UIAlertControllerAletrActionTitle, ((UIAlertController) -> Void)?) in
                    (.default(title: config.name), { [weak self] alert in
                        guard let `self` = self else { return }
                        guard let cell = self.form.rowBy(tag: "appEnvironment") as? LabelRow else { return }
                        DebugService.instance.setAppEnvironment(config)
                        cell.value = config.name
                        cell.updateCell()
                    })
                }

                actions.append((.default(title: "Custom"), { [weak self] alert in
                    self?.navigationController?.pushViewController(DebugEnvironmentViewController(), animated: true)
                }))
                actions.append((.cancel, nil))
                DebugActionSheet.show(title: "Select App Environment", message: nil, actions: actions)
            }
            <<< SwitchRow("ignoreCheckUpdate") {
                $0.title = "Ignore Check Update"
                $0.value = DebugService.instance.config.ignoreCheckUpdate
                }.onChange { [weak self] row in
                    guard let `self` = self else { return }
                    guard let ret = row.value else { return }
                    DebugService.instance.config.ignoreCheckUpdate = ret
            }
            +++
            MultivaluedSection(multivaluedOptions: [],
                               header: "Web",
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
            +++
            MultivaluedSection(multivaluedOptions: [],
                               header: "Others",
                               footer: "") { section in

                                let array: [(String, () -> UIViewController)] =
                                    [("Operation", {DebugOperationViewController()}),
                                     ("Workflow", {DebugWorkflowViewController()}),
                                     ("H5 Bridge", {WKWebViewController.init(url: URL(string: "https://bridge-demo.netlify.com")!)}),
                                     ("Statistics", {DebugStatisticsViewController()})]

                                array.forEach({ (title, block) in
                                    section <<< LabelRow(title) {
                                        $0.title =  title
                                        }.onCellSelection({ [weak self] _, _  in
                                            guard let `self` = self else { return }
                                            let vc = block()
                                            if !(vc is WKWebViewController) {
                                                vc.navigationItem.title = title
                                            }
                                            self.navigationController?.pushViewController(vc, animated: true)
                                        })
                                })

                                DebugService.instance.debugViewControllers.forEach({ (title, vc) in
                                    section <<< LabelRow(title) {
                                        $0.title =  title
                                        }.onCellSelection({ [weak self] _, _  in
                                            guard let `self` = self else { return }
                                            let vc = vc()
                                            if !(vc is WKWebViewController) {
                                                vc.navigationItem.title = title
                                            }
                                            self.navigationController?.pushViewController(vc, animated: true)
                                        })
                                })
        }

        #endif
    }

    func goToInputUrl() {
        let controller = AlertControl(title: "Input URL", message: nil)
        let cancelAction = AlertAction(title: "Cancel", style: .light, handler: nil)
        let okAction = AlertAction(title: "Go", style: .light) { controller in
            let textField = (controller.textFields?.first)! as UITextField
            guard let text = textField.text, (text.lowercased().hasPrefix("http://") || text.lowercased().hasPrefix("https://")), let url = URL(string:text) else {
                Toast.show("Invalid URL")
                return
            }
            let vc = WKWebViewController(url: url)
            self.navigationController?.pushViewController(vc, animated: true)
            DebugService.instance.config.urls.append(url.absoluteString)
        }
        controller.addTextField { (textField) in
            textField.placeholder = "http:// or https://"
        }
        controller.addAction(cancelAction)
        controller.addAction(okAction)
        controller.show()
    }

    @objc fileprivate func _onCancel() {
        dismiss(animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let cell = self.form.rowBy(tag: "appEnvironment") as? LabelRow else { return }
        cell.value = DebugService.instance.config.appEnvironment.name
        cell.updateCell()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Statistics.pageviewStart(with: Statistics.Page.Debug.name)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Statistics.pageviewEnd(with: Statistics.Page.Debug.name)
    }
}
#endif
