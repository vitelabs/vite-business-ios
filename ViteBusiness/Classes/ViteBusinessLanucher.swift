//
//  ViteBusiness.swift
//  Action
//
//  Created by haoshenyang on 2018/12/12.
//

import UIKit
import RxSwift
import Fabric
import Crashlytics
import NSObject_Rx
import Vite_HDWalletKit
import ViteUtils
import ViteWallet
import BigInt

public class ViteBusinessLanucher: NSObject {

    public static let instance = ViteBusinessLanucher()

    public var window: UIWindow!

    var subVCInfo = [(UIViewController, Int)]()

    public func add(homePageSubTabViewController viewController: UIViewController ,atIndex index: Int) {
        self.subVCInfo.append((viewController,index))
        guard let window = window,
            let rootVC = window.rootViewController as? HomeViewController else { return }
        var subViewControlles = rootVC.viewControllers ?? []
        if subViewControlles.count <= index {
            rootVC.viewControllers?.append(viewController)
        } else {
            subViewControlles.insert(viewController, at: index)
            rootVC.viewControllers = subViewControlles
        }
    }
    
    public func start(with window: UIWindow) {
        self.window = window

        VitePodRawLocalizationService.sharedInstance.setBundleName("ViteBusiness")
        Statistics.initializeConfig()
        handleNotification()
        _ = LocalizationService.sharedInstance

        goShowIntroViewPage()

        AppSettingsService.instance.start()
        TokenCacheService.instance.start()
        AutoGatheringService.instance.start()
        FetchBalanceInfoService.instance.start()
        FetchQuotaService.instance.start()

        //web
        self.handleWebConfig()
    }

    func handleWebConfig() {
       let languageChangedInSetting = NotificationCenter.default.rx.notification(.languageChangedInSetting)

        languageChangedInSetting.subscribe {[weak self] (_) in
            guard let `self` = self else { return }
            WKWebViewConfig.instance.closeStr = R.string.localizable.close()
        }.disposed(by: rx.disposeBag)

        WKWebViewConfig.instance.backImg = R.image.icon_nav_back_black()?.tintColor( UIColor(netHex: 0x3E4A59).withAlphaComponent(0.45)).resizable
        WKWebViewConfig.instance.shareImg = R.image.icon_nav_share_black()?.tintColor( UIColor(netHex: 0x3E4A59).withAlphaComponent(0.45)).resizable
        WKWebViewConfig.instance.closeStr = R.string.localizable.close()

        WKWebViewConfig.instance.share = { (_ data: [String: String]?) -> String? in
            if let url = data?["url"] as? String {
                let shareUrl = URL.init(string: url)
                Workflow.share(activityItems: [shareUrl])
            }
            return nil
        }

        WKWebViewConfig.instance.sendTransaction = { (_ data: [String: String]?) -> String? in
            do {
                if let str = data?["data"] as? String {
                    var data  = str.data(using: .utf8)!
                    let json = try JSONSerialization.jsonObject(with: data as Data, options: []) as! [String: Any]

                    guard let account = HDWalletManager.instance.account else {
                        return nil
                    }
                    if let tokenStr = json["token"] as? String {
                        guard let token = Token(JSONString: tokenStr) else {
                            return nil
                        }
                        if let addressStr = json["toAddress"] as? String {
                            let address = Address.init(string: addressStr)
                            if let amountStr = json["amount"] as? String {
                                let amount =                                 Balance(value: amountStr.toBigInt(decimals: token.decimals) ?? BigInt(0))
                                let noteStr = json["note"] as? String ?? ""

                                Workflow.sendTransactionWithConfirm(account: account, toAddress: address, token: token, amount: amount, note:noteStr , completion: { (r) in
                                })
                            }
                        }
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
            return nil
        }
    }

    func handleNotification() {
        let b = NotificationCenter.default.rx.notification(.logoutDidFinish)
        let c = NotificationCenter.default.rx.notification(.finishShowIntroPage)
        Observable.of(b, c)
            .merge()
            .takeUntil(self.rx.deallocated)
            .subscribe {[weak self] (_) in
                guard let `self` = self else { return }
                self.handleRootVC()
            }.disposed(by: rx.disposeBag)

        let createAccountSuccess = NotificationCenter.default.rx.notification(.createAccountSuccess)
        let loginDidFinish = NotificationCenter.default.rx.notification(.loginDidFinish)
        let languageChangedInSetting = NotificationCenter.default.rx.notification(.languageChangedInSetting)
        let unlockDidSuccess = NotificationCenter.default.rx.notification(.unlockDidSuccess)

        Observable.of(createAccountSuccess, loginDidFinish, languageChangedInSetting, unlockDidSuccess)
            .merge()
            .takeUntil(self.rx.deallocated)
            .subscribe {[weak self] (_) in
                guard let `self` = self else { return }
                self.goHomePage()
            }.disposed(by: rx.disposeBag)
    }

    func handleRootVC() {

        if HDWalletManager.instance.canUnLock {
            if !HDWalletManager.instance.isRequireAuthentication,
                let wallet = KeychainService.instance.currentWallet,
                wallet.uuid == HDWalletManager.instance.wallet?.uuid,
                HDWalletManager.instance.loginCurrent(encryptKey: wallet.encryptKey) {
                self.goHomePage()
                return
            } else {
                self.goLockPage()
                return
            }
        }

        if HDWalletManager.instance.isEmpty {
            let rootVC = CreateAccountHomeViewController()
            rootVC.automaticallyShowDismissButton = false
            let nav = BaseNavigationController(rootViewController: rootVC)
            window.rootViewController = nav
            window.makeKeyAndVisible()
        } else {
            let rootVC = LoginViewController()
            rootVC.automaticallyShowDismissButton = false
            let nav = BaseNavigationController(rootViewController: rootVC)
            window.rootViewController = nav
            window.makeKeyAndVisible()
        }
    }

    func goShowIntroViewPage() {
        let introViewPageVersion = UserDefaultsService.instance.objectForKey("IntroView", inCollection: "IntroViewPageVersion") as? String  ?? ""
        if introViewPageVersion != Constants.IntroductionPageVersion {
            let vc = IntroductionViewController()
            window.rootViewController = vc
            window.makeKeyAndVisible()
        } else {
            handleRootVC()
        }
    }

    func goLockPage() {
        HDWalletManager.instance.locked = true
        let rootVC: BaseViewController
        if HDWalletManager.instance.isAuthenticatedByBiometry {
            rootVC = LockViewController()
        } else {
            rootVC = LockPwdViewController()
            rootVC.automaticallyShowDismissButton = false
        }
        let nav = BaseNavigationController(rootViewController: rootVC)
        window.rootViewController = nav
        window.makeKeyAndVisible()
    }

    func goHomePage() {
        let rootVC = HomeViewController()
        window.rootViewController = rootVC
        window.makeKeyAndVisible()
    }

}

