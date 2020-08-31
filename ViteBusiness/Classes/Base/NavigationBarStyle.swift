//
//  NavigationBarStyle.swift
//  Vite
//
//  Created by Stone on 2018/9/14.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit

public enum NavigationBarStyle {

    case `default`
    case clear
    case custom(tintColor: UIColor, backgroundColor: UIColor)
    case forH5

    public static func configStyle(_ style: NavigationBarStyle, viewController: UIViewController) {

        guard let navigationBar = viewController.navigationController?.navigationBar else { return }

        navigationBar.backIndicatorImage = R.image.icon_nav_back_black_offset()
        navigationBar.backIndicatorTransitionMaskImage = R.image.icon_nav_back_black_offset()
        navigationBar.shadowImage = UIImage()

        switch style {
        case .default:
            let color = UIColor(netHex: 0x3E4A59)
            navigationBar.tintColor = color
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]
            navigationBar.setBackgroundImage(UIImage.color(UIColor.white), for: .default)
        case .clear:
            let color = UIColor.white
            navigationBar.tintColor = color
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]
            navigationBar.setBackgroundImage(UIImage(), for: .default)
        case .custom(let tintColor, let backgroundColor):
            navigationBar.tintColor = tintColor
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: tintColor]
            if backgroundColor == UIColor.clear {
                navigationBar.setBackgroundImage(UIImage(), for: .default)
            } else {
                navigationBar.setBackgroundImage(UIImage.color(backgroundColor), for: .default)
            }
        case .forH5:
            let color = UIColor(netHex: 0x3E4A59).withAlphaComponent(0.45)
            navigationBar.tintColor = color
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]
            navigationBar.setBackgroundImage(UIImage.color(UIColor.white), for: .default)
        }
    }
}
