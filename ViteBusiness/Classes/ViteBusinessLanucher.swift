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

    var subVCInfo = [(() -> UIViewController, Int)]()

    public func add(homePageSubTabViewController viewController: @autoclosure @escaping () -> UIViewController ,atIndex index: Int) {
        self.subVCInfo.append((viewController,index))
        guard let window = window,
            let rootVC = window.rootViewController as? HomeViewController else { return }
        var subViewControlles = rootVC.viewControllers ?? []
        if subViewControlles.count <= index {
            rootVC.viewControllers?.append(viewController())
        } else {
            subViewControlles.insert(viewController(), at: index)
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
        self.handleWebUIConfig()
        self.handleWebAppBridgeConfig()
        self.handleWebWalletBridgeConfig()
    }
    func handleWebWalletBridgeConfig()  {
        WKWebViewConfig.instance.fetchViteAddress = { (_ data: [String: String]?,_ callbackId:String, _ callback:@escaping WKWebViewConfig.NativeCallback)  in
            //handle not login
            //handle lock
            DispatchQueue.main.async {
                Alert.show(title: R.string.localizable.confirmTransactionPageToastPasswordError(), message: nil,
                           titles: [.default(title: R.string.localizable.sendPageConfirmPasswordAuthFailedRetry()),
                                    .cancel],
                           handler: { _, index in
                            if index == 0 {
                                var r = Response(code:.success,msg: "ok111111",data: ["address":HDWalletManager.instance.account?.address.description ?? ""])
                                callback(r,callbackId)
                            }else {
                                var r = Response(code:.success,msg: "cancel",data: ["address":HDWalletManager.instance.account?.address.description ?? ""])
                                callback(r,callbackId)
                            }
                })
            }
        }
        WKWebViewConfig.instance.invokeUri = { (_ data: [String: String]?,_ callbackId:String, _ callback:@escaping WKWebViewConfig.NativeCallback)  in

            //handle
//            Workflow.sendRawTx(by: <#T##ViteURI#>, accountAddress: <#T##Address#>, token: <#T##Token#>, completion: { (Result<AccountBlock>) in
//                <#code#>
//            })
        }
    }

    func handleWebAppBridgeConfig()  {
        WKWebViewConfig.instance.share = { (_ data: [String: String]?) -> Response? in
            if let url = data?["url"] as? String {
                let shareUrl = URL.init(string: url)
                Workflow.share(activityItems: [shareUrl])
            }
            return nil
        }

        WKWebViewConfig.instance.fetchLanguage = { (_ data: [String: String]?) -> Response? in
            return Response(code:.success,msg: "ok",data: LocalizationService.sharedInstance.currentLanguage.rawValue)
        }

        WKWebViewConfig.instance.fetchAppInfo = { (_ data: [String: String]?) -> Response? in
            let data = [
                "platform":"ios",
                "versionName":"1.0.0",
                "versionCode":1024,
                "env":"test"
                ] as [String : Any]
            return Response(code:.success,msg: "ok",data: data)
        }
    }

    func handleWebUIConfig() {
       let languageChangedInSetting = NotificationCenter.default.rx.notification(.languageChangedInSetting)

        languageChangedInSetting.subscribe {[weak self] (_) in
            guard let `self` = self else { return }
            WKWebViewConfig.instance.closeStr = R.string.localizable.close()
        }.disposed(by: rx.disposeBag)

        WKWebViewConfig.instance.backImg = R.image.icon_nav_back_black()?.tintColor( UIColor(netHex: 0x3E4A59).withAlphaComponent(0.45)).resizable
        WKWebViewConfig.instance.shareImg = R.image.icon_nav_share_black()?.tintColor( UIColor(netHex: 0x3E4A59).withAlphaComponent(0.45)).resizable
        WKWebViewConfig.instance.closeStr = R.string.localizable.close()
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

