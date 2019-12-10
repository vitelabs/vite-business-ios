//
//  UIColor.swift
//  Vite
//
//  Created by Water on 2018/9/5.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import UIKit

public extension UIColor {
    public convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }

    public convenience init(netHex: Int, alpha: CGFloat = 1.0) {
        self.init(red: (netHex >> 16) & 0xff, green: (netHex >> 8) & 0xff, blue: netHex & 0xff, alpha: alpha)
    }

    public convenience init?(hexa: String) {

        let string: String
        if hexa.hasPrefix("0x") || hexa.hasPrefix("0X") {
            string = String(hexa.dropFirst(2))
        } else {
            string = hexa
        }

        if string.count == 6 {
            self.init(hex: string)
        } else if string.count == 8 {
            let scanner = Scanner(string: string)
            scanner.scanLocation = 0

            var rgbaValue: UInt64 = 0

            scanner.scanHexInt64(&rgbaValue)

            let r = (rgbaValue & 0xff000000) >> 24
            let g = (rgbaValue & 0xff0000) >> 16
            let b = (rgbaValue & 0xff00) >> 8
            let a = rgbaValue & 0xff

            self.init(
                red: CGFloat(r) / 0xff,
                green: CGFloat(g) / 0xff,
                blue: CGFloat(b) / 0xff,
                alpha: CGFloat(a) / 0xff
            )
        } else {
            return nil
        }
    }

    public convenience init(hex: String, alpha: CGFloat = 1.0) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0

        var rgbValue: UInt64 = 0

        scanner.scanHexInt64(&rgbValue)

        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff

        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: alpha
        )
    }

    public var highlighted: UIColor {
        return self.withAlphaComponent(0.6)
    }

    public enum GradientStyle {
        case left2right
        case top2bottom
        case leftTop2rightBottom
        case leftBottom2rightTop
        case custom(start: CGPoint, end: CGPoint)
    }

    public static func gradientColor(style: GradientStyle, frame: CGRect, colors: [UIColor]) -> UIColor {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = frame
        gradientLayer.colors = colors.map({ $0.cgColor })

        switch style {
        case .left2right:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        case .top2bottom:
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        case .leftTop2rightBottom:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        case .leftBottom2rightTop:
            gradientLayer.startPoint = CGPoint(x: 0 , y: 1)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        case .custom(let start, let end):
            gradientLayer.startPoint = start
            gradientLayer.endPoint = end
        }

        UIGraphicsBeginImageContextWithOptions(gradientLayer.bounds.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIColor.white
        }
        gradientLayer.render(in: context)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return UIColor.white
        }
        UIGraphicsEndImageContext()
        return UIColor(patternImage: image)
    }
}
