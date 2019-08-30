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
import ViteWallet
import BigInt
import web3swift


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
        //config
        #if DAPP
        let url: URL
        if !DebugService.instance.config.rpcCustomUrl.isEmpty,
            let u = URL(string: DebugService.instance.config.rpcCustomUrl) {
            url = u
        } else {
            url = URL(string: ViteConst.Env.premainnet.vite.nodeHttp)!
        }
        Provider.default.update(server: ViteWallet.RPCServer(url: url))
        #else
        Provider.default.update(server: ViteWallet.RPCServer(url: URL(string: ViteConst.instance.vite.nodeHttp)!))
        #endif
        EtherWallet.shared.setProviderURL(URL(string: ViteConst.instance.eth.nodeHttp)!, net: ViteConst.instance.eth.chainType)
        VitePodRawLocalizationService.sharedInstance.setBundleName("ViteBusiness")
        Statistics.initializeConfig()
        handleNotification()
        _ = LocalizationService.sharedInstance

        goShowIntroViewPage()

        AppConfigService.instance.start()
        MyTokenInfosService.instance.start()
        ExchangeRateManager.instance.start()
        TokenListService.instance.fetchTokenListServerData()
        AutoGatheringManager.instance.start()
        ViteBalanceInfoManager.instance.start()
        ETHBalanceInfoManager.instance.start()
        FetchQuotaManager.instance.start()
        AddressManageService.instance.start()

        //web
        self.handleWebUIConfig()
        self.handleWebAppBridgeConfig()
        self.handleWebWalletBridgeConfig()


    }

    func handleWebWalletBridgeConfig()  {
        WKWebViewConfig.instance.fetchViteAddress = { (_ data: [String: Any]?,_ callbackId:String, _ callback:@escaping WKWebViewConfig.NativeCallback)  in

            guard let account = HDWalletManager.instance.account else {
                callback(Response(code: .notLogin, msg: "not login", data: nil), callbackId)
                return
            }

            callback(Response(code:.success,msg: "",data: account.address),callbackId)
        }

        enum ErrorCode: Int {
            case lastTransactionNotCompleted = 4001
            case tokenInfoNotFound = 4002
            case amountError = 4003
            case userCancel = 4004
        }

        WKWebViewConfig.instance.invokeUri = { (_ data: [String: Any]?,_ callbackId:String, _ callback:@escaping WKWebViewConfig.NativeCallback)  in

            guard let data = data else {
                callback(Response(code: .invalidParameter, msg: "invalid parameter: data", data: nil), callbackId)
                return
            }

            guard let addressString = data["address"] as? ViteAddress, addressString.isViteAddress else {
                callback(Response(code: .invalidParameter, msg: "invalid parameter: address", data: nil), callbackId)
                return
            }

            guard let uriString = data["uri"] as? String else {
                callback(Response(code: .invalidParameter, msg: "invalid parameter: uri", data: nil), callbackId)
                return
            }

            guard let account = HDWalletManager.instance.account else {
                callback(Response(code: .notLogin, msg: "not login", data: nil), callbackId)
                return
            }

            guard addressString == account.address else {
                callback(Response(code: .addressDoesNotMatch, msg: "address does not match", data: nil), callbackId)
                return
            }

            guard WKWebViewConfig.instance.isInvokingUri == false else {
                callback(Response(code: .other(code: ErrorCode.lastTransactionNotCompleted.rawValue), msg: "the last transaction was not completed", data: nil), callbackId)
                return
            }

            WKWebViewConfig.instance.isInvokingUri = true
            switch ViteURI.parser(string: uriString) {
            case .success(let uri):
                if uri.address == ViteWalletConst.ContractAddress.dexFund.address ||
                    uri.address == ViteWalletConst.ContractAddress.dexTrade.address {
                    callback(Response(code: .noJurisdiction, msg: "Not Allow Call Dex Contract", data: nil), callbackId)
                    return
                }
                HUD.show()
                MyTokenInfosService.instance.tokenInfo(forViteTokenId: uri.tokenId, completion: { (r) in
                    HUD.hide()
                    switch r {
                    case .success(let tokenInfo):
                        Workflow.sendRawTx(by: uri, accountAddress: account.address, tokenInfo: tokenInfo, completion: { (r) in
                            WKWebViewConfig.instance.isInvokingUri = false
                            switch r {
                            case .success(let accountBlock):
                                callback(Response(code: .success, msg: "", data: accountBlock.toJSON()), callbackId)
                            case .failure(let error):
                                if let e = error as? Workflow.WorkflowError, case .amountInvalid = e {
                                    callback(Response(code: .other(code: ErrorCode.amountError.rawValue), msg: "amount format invalid", data: nil), callbackId)
                                } else if let e = error as? ViteError, case .cancel = e {
                                    callback(Response(code: .other(code: ErrorCode.userCancel.rawValue), msg: "user cancel", data: nil), callbackId)
                                } else {
                                    callback(Response(code: .other(code: error.viteErrorCode.id), msg: error.viteErrorMessage, data: nil), callbackId)
                                }
                            }
                        })
                    case .failure(let error):
                        WKWebViewConfig.instance.isInvokingUri = false
                        if let e = error as? Wallet.WalletError, case .invalidTokenId = e {
                            callback(Response(code: .other(code: ErrorCode.tokenInfoNotFound.rawValue), msg: "token info not found", data: nil), callbackId)
                        } else {
                            callback(Response(code: .other(code: error.viteErrorCode.id), msg: error.viteErrorMessage, data: nil), callbackId)
                        }
                    }
                })
            case .failure(let error):
                WKWebViewConfig.instance.isInvokingUri = false
                callback(Response(code: .invalidParameter, msg: error.localizedDescription, data: nil), callbackId)
            }
        }
    }

    func handleWebAppBridgeConfig()  {
        WKWebViewConfig.instance.share = { (_ data: [String: Any]?) -> Response? in
            if let url = data?["url"] as? String {
                let shareUrl = URL.init(string: url)
                Workflow.share(activityItems: [shareUrl])
            }
            return nil
        }

        WKWebViewConfig.instance.fetchLanguage = { (_ data: [String: Any]?) -> Response? in
            return Response(code:.success,msg: "ok",data: LocalizationService.sharedInstance.currentLanguage.code)
        }

        WKWebViewConfig.instance.fetchAppInfo = { (_ data: [String: Any]?) -> Response? in
            #if DEBUG || TEST
            var env: String!
            switch DebugService.instance.config.appEnvironment {
            case .online, .stage:
                env = "production"
            case .test, .custom:
                env = "test"
            }
            #else
            let env = "production"
            #endif
            let data = [
                "platform": "ios",
                "versionName": Bundle.main.versionNumber,
                "versionCode": Bundle.main.buildNumberInt,
                "env": env,
                "uuid": UUID.stored
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

        WKWebViewConfig.instance.backImg = R.image.icon_nav_back_black()
        WKWebViewConfig.instance.shareImg = R.image.icon_nav_share_black()
        WKWebViewConfig.instance.closeStr  = R.string.localizable.close()
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
            let vc = f__IntroductionViewController()
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

    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        ViteAppSchemeHandler.instance.handle(url)
        return true
    }
}


