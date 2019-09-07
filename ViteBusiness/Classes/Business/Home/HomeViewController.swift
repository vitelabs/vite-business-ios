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

    init() {
        super.init(nibName: nil, bundle: nil)

        let walletVC = WalletHomeViewController().then {
            $0.automaticallyShowDismissButton = false
        }

        let myVC = MyHomeViewController().then {
            $0.automaticallyShowDismissButton = false
        }

        let exchangeVC = ExchangeViewController().then {
            $0.automaticallyShowDismissButton = false
        }

        let walletNav = BaseNavigationController(rootViewController: walletVC).then {
            $0.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            $0.tabBarItem.image = R.image.icon_tabbar_wallet()?.withRenderingMode(.alwaysOriginal)
            $0.tabBarItem.selectedImage = R.image.icon_tabbar_wallet_select()?.withRenderingMode(.alwaysOriginal)
        }

        let myNav = BaseNavigationController(rootViewController: myVC).then {
            $0.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            $0.tabBarItem.image = R.image.icon_tabbar_me()?.withRenderingMode(.alwaysOriginal)
            $0.tabBarItem.selectedImage = R.image.icon_tabbar_me_select()?.withRenderingMode(.alwaysOriginal)
        }

        let exchangeNav = BaseNavigationController(rootViewController: exchangeVC).then {
            $0.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            $0.tabBarItem.image = R.image.exchange_tabbar_icon_unseleted()?.withRenderingMode(.alwaysOriginal)
            $0.tabBarItem.selectedImage = R.image.exchange_tabbar_icon()?.withRenderingMode(.alwaysOriginal)
            $0.tabBarItem.tag = 1001
        }

        var subViewControlles: [UIViewController] = [walletNav, exchangeNav, myNav]
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
