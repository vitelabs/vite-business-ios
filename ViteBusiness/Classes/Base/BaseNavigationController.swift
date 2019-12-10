//
//  BaseNavigationController.swift
//  Vite
//
//  Created by Stone on 2018/8/27.
//  Copyright © 2018年 Vite. All rights reserved.
//

import UIKit

public class BaseNavigationController: UINavigationController {

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        self.delegate = self
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override public func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if children.count == 1 {
            viewController.hidesBottomBarWhenPushed = true
        }

        // if currect vc is ScanViewController, remove it
        if let _ = viewControllers.last as? ScanViewController {
            var vcs = viewControllers
            _ = vcs.popLast()
            vcs.append(viewController)
            self.setViewControllers(vcs, animated: animated)
        } else {
            super.pushViewController(viewController, animated: animated)
        }
    }

    override public func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        if viewControllers.count > 1 {
            viewControllers.last?.hidesBottomBarWhenPushed = true
        }
        super.setViewControllers(viewControllers, animated: animated)
    }
}

extension BaseNavigationController: UINavigationControllerDelegate {

    open func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = item
    }

    override public var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
}
