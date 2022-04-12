//
//  Route.swift
//  ViteBusiness
//
//  Created by Water on 2018/12/10.
//
import UIKit

public struct Route {
    public static func getTopVC() -> (UIViewController?) {
        var window = UIApplication.shared.keyWindow
        if window?.windowLevel != UIWindow.Level.normal {
            let windows = UIApplication.shared.windows
            for  windowTemp in windows where windowTemp.windowLevel == UIWindow.Level.normal {
                window = windowTemp
            }
        }

        let vc = window?.rootViewController
        return getTopVC(withCurrentVC: vc)
    }

    ///根据控制器获取 顶层控制器
    public static func getTopVC(withCurrentVC VC: UIViewController?) -> UIViewController? {

        if VC == nil {
            print("🌶： can't find root vc")
            return nil
        }

        if let presentVC = VC?.presentedViewController {
            //modal
            return getTopVC(withCurrentVC: presentVC)
        } else if let tabVC = VC as? UITabBarController {
            // tabBar
            if let selectVC = tabVC.selectedViewController {
                return getTopVC(withCurrentVC: selectVC)
            }
            return nil
        } else if let naiVC = VC as? UINavigationController {
            //nav
            return getTopVC(withCurrentVC: naiVC.visibleViewController)
        } else {
            // result
            return VC
        }
    }

    public static func gotoTokenHomeVC(with tokenInfo: TokenInfo)  {
       let balanceInfoDetailViewController : UIViewController
        switch tokenInfo.coinType {
        case .eth, .vite, .bnb:
            balanceInfoDetailViewController = BalanceInfoDetailViewController(tokenInfo: tokenInfo)
        case .unsupport:
            fatalError()
        }
       Route.getTopVC()?.navigationController?.pushViewController(balanceInfoDetailViewController, animated: true)
    }
}
