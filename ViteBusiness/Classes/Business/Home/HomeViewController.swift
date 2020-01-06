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

//        let defiVc = DeFiHomeViewController().then {
//            $0.automaticallyShowDismissButton = false
//        }

        let marketVC = MarketViewController()

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

//        let defiNav = BaseNavigationController(rootViewController: defiVc).then {
//            $0.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
//
//            if UserDefaults.standard.bool(forKey: "defi_selected") == true {
//                $0.tabBarItem.image = R.image.icon_tabbar_defi_unselected()?.withRenderingMode(.alwaysOriginal)
//            } else {
//                $0.tabBarItem.image = R.image.icon_tabbar_defi_hot()?.withRenderingMode(.alwaysOriginal)
//            }
//            $0.tabBarItem.selectedImage = R.image.icon_tabbar_defi()?.withRenderingMode(.alwaysOriginal)
//            $0.tabBarItem.tag = 1001
//        }

        let marketNav = BaseNavigationController(rootViewController: marketVC).then {
            $0.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            $0.tabBarItem.image = ViteBusiness.R.image.icon_tabbar_market()?.withRenderingMode(.alwaysOriginal)
            $0.tabBarItem.selectedImage = ViteBusiness.R.image.icon_tabbar_market_select()?.withRenderingMode(.alwaysOriginal)
            $0.tabBarItem.tag = 1002
            $0.interactivePopGestureRecognizer?.isEnabled = false
            $0.tabBarItem.title = nil
        }

        let exchangeVC = ExchangeViewController().then {
            $0.automaticallyShowDismissButton = false
        }

        let exchangeNav = BaseNavigationController(rootViewController: exchangeVC).then {
            $0.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            $0.tabBarItem.image = R.image.exchange_tabbar_icon_unseleted()?.withRenderingMode(.alwaysOriginal)
            $0.tabBarItem.selectedImage = R.image.exchange_tabbar_icon()?.withRenderingMode(.alwaysOriginal)
            $0.tabBarItem.tag = 1001
        }


        #if DAPP
            var subViewControlles: [UIViewController] = [walletNav, myNav, DebugHomeViewController.createNavVC()]
        #else
            var subViewControlles: [UIViewController] = [walletNav, exchangeNav, marketNav, myNav]
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

        GCD.delay(1) { AppUpdateService.checkUpdate() }

        
//        self.rx.observeWeakly(UIViewController.self, #keyPath(UITabBarController.selectedViewController))
//            .filterNil()
//            .bind { [weak self] vc in
//                if vc.tabBarItem.tag == 1001 {
//                    UserDefaults.standard.set(true, forKey: "defi_selected")
//                    vc.tabBarItem.image = R.image.icon_tabbar_defi_unselected()?.withRenderingMode(.alwaysOriginal)
//                    if self?.deFiImageView.superview != nil {
//                        self?.deFiImageView.removeFromSuperview()
//                    }
//                } else if  vc.tabBarItem.tag == 1002 {
//                    Statistics.log(eventId: "charts_home")
//                }
//        }.disposed(by: rx.disposeBag)

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

        DispatchQueue.main.async {
            AppSettingsService.instance.appSettingsDriver.map{ $0.guide.vitexInvite}.distinctUntilChanged().drive(onNext: { [weak self] (ret) in
                if ret {
                    self?.tabBar.showBadgeDot(at: 4)
                } else {
                    self?.tabBar.hideBadgeDot(at: 4)
                }
            }).disposed(by: self.rx.disposeBag)
//            self.showDefiAlertIfNeeded()
        }


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


    let deFiImageView = UIImageView().then {
        $0.image = R.image.defi_alert_cn()
    }

//    func showDefiAlertIfNeeded() {
//        return
//        if UserDefaults.standard.bool(forKey: "defi_selected") == true {
//           return
//       }
//        var items = tabBar.subviews
//            .filter { (view) -> Bool in
//                return view.isKind(of: UIControl.self)
//        }
//        .sorted { (v0, v1) -> Bool in
//            return v0.frame.origin.x < v1.frame.origin.x
//        }
//        let item = items[1]
//        let frame = item.convert(item.frame, to:  UIApplication.shared.keyWindow!)
//        let origin = CGPoint.init(x: item.frame.origin.x+item.frame.size.width/2-59, y: frame.origin.y-30)
//        deFiImageView.frame.origin = origin
//        deFiImageView.frame.size = CGSize.init(width: 118, height: 41)
//        UIApplication.shared.keyWindow?.addSubview(deFiImageView)
//        GCD.delay(5) {
//            if self.deFiImageView.superview != nil {
//                self.deFiImageView.removeFromSuperview()
//            }
//        }
//
//        for vc in self.viewControllers! {
//            vc.rx.methodInvoked(#selector(UINavigationController.pushViewController(_:animated:))).subscribe(onNext: {[weak self] (_) in
//            if self?.deFiImageView.superview != nil {
//                self?.deFiImageView.removeFromSuperview()
//            }
//            }).disposed(by: rx.disposeBag)
//        }
//
//    }

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
