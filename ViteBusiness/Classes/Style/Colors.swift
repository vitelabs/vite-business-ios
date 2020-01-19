//
//  Colors.swift
//  Vite
//
//  Created by Water on 2018/9/5.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit

public struct Colors {
    public static let darkBlue = UIColor(hex: "3375BB")
    public static let titleGray = UIColor(hex: "3E4A59")
    public static let titleGray_61 = UIColor.init(red: 62, green: 74, blue: 89, alpha: 0.61)
    public static let titleGray_45 = UIColor.init(red: 62, green: 74, blue: 89, alpha: 0.45)
    public static let lineGray = UIColor.init(red: 62, green: 74, blue: 89, alpha: 0.20)
    public static let descGray = UIColor.init(red: 36, green: 39, blue: 43, alpha: 0.8)
    public static let imageBgGray = UIColor(hex: "F8F8F8")
    public static let imageArrowGray = UIColor(hex: "A8ADB4")
    public static let bgGray = UIColor(hex: "EFF0F4")
    public static let blueBg = UIColor(hex: "007AFF")
    public static let cellTitleGray = UIColor(hex: "24272B")
    public static let btnDisableGray = UIColor(hex: "EFF0F4")
}

extension UIColor {
    open class var random: UIColor {
        return UIColor(r: CGFloat(arc4random() % 255), g: CGFloat(arc4random() % 255), b: CGFloat(arc4random() % 255))
    }
}
