//
//  HomeViewController.swift
//  Vite
//
//  Created by Stone on 2018/9/7.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import Then
import RxCocoa
import RxSwift

class HomeViewController: UITabBarController {

    let tradingVC = TradingHomeViewController().then {
        $0.automaticallyShowDismissButton = false
    }

    init() {
        super.init(nibName: nil, bundle: nil)

        let walletVC = WalletHomeViewController().then {
            $0.automaticallyShowDismissButton = false
        }

        let marketVC = MarketViewController().then {
            $0.automaticallyShowDismissButton = false
        }

        let dexAssetVC = DexAssetsHomeViewController().then {
            $0.automaticallyShowDismissButton = false
        }


        let walletNav = BaseNavigationController(rootViewController: walletVC).then {
            $0.tabBarItem.title = R.string.localizable.tabTitleWallet()
            $0.tabBarItem.image = R.image.icon_tabbar_wallet()?.withRenderingMode(.alwaysOriginal)
            $0.tabBarItem.selectedImage = R.image.icon_tabbar_wallet_select()?.withRenderingMode(.alwaysOriginal)
        }

        let dexAssetNav = BaseNavigationController(rootViewController: dexAssetVC).then {
            $0.tabBarItem.title = R.string.localizable.tabTitleDex()
            $0.tabBarItem.image = R.image.icon_tabbar_dex()?.withRenderingMode(.alwaysOriginal)
            $0.tabBarItem.selectedImage = R.image.icon_tabbar_dex_select()?.withRenderingMode(.alwaysOriginal)
        }

        let marketNav = BaseNavigationController(rootViewController: marketVC).then {
            $0.tabBarItem.title = R.string.localizable.tabTitleMarket()
            $0.tabBarItem.image = ViteBusiness.R.image.icon_tabbar_market()?.withRenderingMode(.alwaysOriginal)
            $0.tabBarItem.selectedImage = ViteBusiness.R.image.icon_tabbar_market_select()?.withRenderingMode(.alwaysOriginal)
            $0.tabBarItem.tag = 1002
            $0.interactivePopGestureRecognizer?.isEnabled = false
        }

        let tradingNav = BaseNavigationController(rootViewController: tradingVC).then {
            $0.tabBarItem.title = R.string.localizable.tabTitleTrading()
            $0.tabBarItem.image = R.image.icon_tabbar_trading()?.withRenderingMode(.alwaysOriginal)
            $0.tabBarItem.selectedImage = R.image.icon_tabbar_trading_select()?.withRenderingMode(.alwaysOriginal)
            $0.tabBarItem.tag = 1001
        }


        #if DAPP
            var subViewControlles: [UIViewController] = [walletNav, dexAssetNav, DebugHomeViewController.createNavVC()]
        #else
            var subViewControlles: [UIViewController] = [walletNav, marketNav, tradingNav, dexAssetNav]
        #endif

        for (viewController, index) in ViteBusinessLanucher.instance.subVCInfo {
            if subViewControlles.count <= index {
                subViewControlles.append(viewController())
            } else {
                subViewControlles.insert(viewController(), at: index)
            }
        }
        self.viewControllers = subViewControlles
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.shadowImage = R.image.tabber_shadow()?.resizable
        tabBar.backgroundImage = UIImage.color(UIColor.white).resizable

        NotificationCenter.default.rx.notification(NSNotification.Name.goTradingPage).bind { [weak self] m in
            guard let `self` = self else { return }
            guard let marketInfo = m.userInfo?["marketInfo"] as? MarketInfo, let isBuy = m.userInfo?["isBuy"] as? Bool else { return }
            UIViewController.current?.navigationController?.popToRootViewController(animated: false)
            self.tradingVC.spotVC.update(marketInfo: marketInfo, isBuy: isBuy)
            self.selectedIndex = 2
        }.disposed(by: rx.disposeBag)

        GCD.delay(1) { AppUpdateService.checkUpdate() }

        self.rx.observeWeakly(UIViewController.self, #keyPath(UITabBarController.selectedViewController))
            .map{ $0?.tabBarItem.tag }
            .filterNil()
            .bind { tag in
                if tag == 1001 {
                    Statistics.log(eventId: "instant_purchase")
                } else if tag == 1002 {
                    Statistics.log(eventId: "charts_home")
                }
        }.disposed(by: rx.disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.post(name: .homePageDidAppear, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



extension UITabBar {
    static let baseTag = 1234
    func showBadgeDot(at index: Int) {
        let tag = UITabBar.baseTag+index
        let count = items?.count ?? 0
        guard count > 0 else { return }

        let view: UIView
        if let v = self.viewWithTag(tag) {
            view = v
            view.isHidden = false
        } else {
            view = UIView().then {
                $0.isUserInteractionEnabled = false
                $0.backgroundColor = UIColor(netHex: 0xFF0008)
                $0.layer.masksToBounds = true
                $0.layer.cornerRadius = 3.5
                $0.tag = tag
            }

            addSubview(view)
            view.snp.makeConstraints { (m) in
                m.size.equalTo(CGSize(width: 7, height: 7))
                m.top.equalToSuperview().offset(10)
                m.left.equalToSuperview().offset(kScreenW * (CGFloat(index)+0.5) / CGFloat(count) + 10)
            }
        }
    }

    func hideBadgeDot(at index: Int) {
        let tag = UITabBar.baseTag+index
        guard let view = self.viewWithTag(tag) else { return }
        view.isHidden = true
    }
}
