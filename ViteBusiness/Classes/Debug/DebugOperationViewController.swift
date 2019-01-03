//
//  DebugOperationViewController.swift
//  Action
//
//  Created by Stone on 2019/1/3.
//
#if DEBUG || TEST
import UIKit
import Eureka
import Crashlytics
import ViteWallet
import ViteUtils

class DebugOperationViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func setupView() {
        form
            +++
            Section {
                $0.header = HeaderFooterView(title: "")
            }
            <<< LabelRow("getTestToken") {
                $0.title =  "Get Test Token"
                }.onCellSelection({ _, _  in
                    if let address = HDWalletManager.instance.account?.address {
                        Provider.default.getTestToken(address: address)
                            .done { (ret) in
                                Toast.show("\(address.description) get test token complete")
                            }
                            .catch { (error) in
                                Toast.show(error.viteErrorMessage)
                        }
                    } else {
                        Toast.show("Login firstly")
                    }
                })
            <<< LabelRow("del intro page version") {
                $0.title =  "del intro page version"
                }.onCellSelection({ _, _  in
                    UserDefaultsService.instance.setObject("", forKey: "IntroView", inCollection: "IntroViewPageVersion")
                    Toast.show("del intro page version")
                })
            <<< LabelRow("reloadConfig") {
                $0.title =  "Reload Config"
                }.onCellSelection({ _, _  in
                    AppSettingsService.instance.start()
                    Toast.show("Operation complete")
                })
            <<< LabelRow("checkUpdate") {
                $0.title =  "Check Update"
                }.onCellSelection({ _, _  in
                    AppUpdateService.checkUpdate()
                    Toast.show("Operation complete")
                })
            <<< LabelRow("deleteAllWallets") {
                $0.title =  "Delete All Wallets"
                }.onCellSelection({ _, _  in
                    HUD.show(R.string.localizable.systemPageLogoutLoading())
                    DispatchQueue.global().async {
                        HDWalletManager.instance.deleteAllWallets()
                        KeychainService.instance.clearCurrentWallet()
                        DispatchQueue.main.async {
                            HUD.hide()
                            NotificationCenter.default.post(name: .logoutDidFinish, object: nil)
                        }
                    }
                })
            <<< LabelRow("resetCurrentWalletBagCount") {
                $0.title =  "Reset Current Wallet Bag Count"
                }.onCellSelection({ _, _  in
                    HDWalletManager.instance.resetBagCount()
                    Toast.show("Operation complete")
                })
            <<< LabelRow("deleteTokenCache") {
                $0.title =  "Delete Token Cache"
                }.onCellSelection({ _, _  in
                    TokenCacheService.instance.deleteCache()
                    Toast.show("Operation complete")
                })
            <<< LabelRow("exportLogFile") {
                $0.title =  "Export Log File"
                }.onCellSelection({ _, _  in
                    let cachePath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
                    let logURL = cachePath.appendingPathComponent("logger.log")
                    let activityViewController = UIActivityViewController(activityItems: [logURL], applicationActivities: nil)
                    UIViewController.current?.present(activityViewController, animated: true)
                })
            <<< LabelRow("test crash") {
                $0.title =  "test crash"
                }.onCellSelection({_, _  in
                    Crashlytics.sharedInstance().throwException()
                })
    }
}
#endif
