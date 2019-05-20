//
//  UIButton+Helper.swift
//  Vite
//
//  Created by Stone on 2018/9/14.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import SnapKit

extension UIButton {

    enum Style {
        case lightBlue
        case blue
        case blueWithShadow
        case white
        case whiteWithShadow
    }

    convenience init(style: Style, title: String? = nil) {
        self.init()

        setTitle(title, for: .normal)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel?.adjustsFontSizeToFitWidth = true
        snp.makeConstraints { $0.height.equalTo(50) }

        switch style {
        case .lightBlue:
            setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
            setBackgroundImage(R.image.background_button_blue()?.tintColor(UIColor(netHex: 0x007AFF,alpha:0.06)).resizable, for: .normal)
            setBackgroundImage(R.image.background_button_blue()?.tintColor(UIColor(netHex: 0x007AFF,alpha:0.06)).resizable, for: .highlighted)
            layer.shadowRadius = 3
            layer.cornerRadius = 2
        case .blue:
            setTitleColor(UIColor.white, for: .normal)
            setBackgroundImage(R.image.background_button_blue()?.resizable, for: .normal)
            setBackgroundImage(R.image.background_button_blue()?.tintColor(UIColor(netHex: 0x006FEA)).resizable, for: .highlighted)
            setBackgroundImage(R.image.background_button_blue()?.tintColor(UIColor(netHex: 0xEFF0F4)).resizable, for: .disabled)
        case .blueWithShadow:
            setTitleColor(UIColor.white, for: .normal)
            setBackgroundImage(R.image.background_button_blue()?.resizable, for: .normal)
            setBackgroundImage(R.image.background_button_blue()?.tintColor(UIColor(netHex: 0x006FEA)).resizable, for: .highlighted)
            setBackgroundImage(R.image.background_button_blue()?.tintColor(UIColor(netHex: 0xEFF0F4)).resizable, for: .disabled)
            backgroundColor = nil
            layer.shadowColor = UIColor(netHex: 0x000000, alpha: 0.1).cgColor
            layer.shadowOpacity = 1
            layer.shadowOffset = CGSize(width: 0, height: 0)
            layer.shadowRadius = 20
        case .white:
            setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
            setBackgroundImage(R.image.background_button_white()?.resizable, for: .normal)
            setBackgroundImage(R.image.background_button_white()?.tintColor(UIColor(netHex: 0xFAFAFA)).resizable, for: .highlighted)
        case .whiteWithShadow:
            setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
            setBackgroundImage(R.image.background_button_white()?.resizable, for: .normal)
            setBackgroundImage(R.image.background_button_white()?.tintColor(UIColor(netHex: 0xFAFAFA)).resizable, for: .highlighted)
            backgroundColor = nil
            layer.shadowColor = UIColor(netHex: 0x000000, alpha: 0.1).cgColor
            layer.shadowOpacity = 1
            layer.shadowOffset = CGSize(width: 0, height: 0)
            layer.shadowRadius = 20
        }
    }

}
