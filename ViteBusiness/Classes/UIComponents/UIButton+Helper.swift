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
        case add
        case navigationItemCustomView
        case red
        case green
        case gray
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
            setBackgroundImage(UIImage.color(UIColor(netHex: 0x00BEFF)).resizable, for: .normal)
            setBackgroundImage(UIImage.color(UIColor(netHex: 0x00BEFF)).highlighted.resizable, for: .highlighted)
            setBackgroundImage(UIImage.color(UIColor(netHex: 0xEFF0F4)).resizable, for: .disabled)
            clipsToBounds = true
            layer.cornerRadius = 15
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
            setTitleColor(UIColor.white, for: .disabled)
            setBackgroundImage(R.image.background_button_blue()?.tintColor(UIColor(netHex: 0xEFF0F4)).resizable, for: .disabled)
        case .whiteWithShadow:
            setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
            setBackgroundImage(R.image.background_button_white()?.resizable, for: .normal)
            setBackgroundImage(R.image.background_button_white()?.tintColor(UIColor(netHex: 0xFAFAFA)).resizable, for: .highlighted)
            setTitleColor(UIColor.white, for: .disabled)
            setBackgroundImage(R.image.background_button_blue()?.tintColor(UIColor(netHex: 0xEFF0F4)).resizable, for: .disabled)
            backgroundColor = nil
            layer.shadowColor = UIColor(netHex: 0x000000, alpha: 0.1).cgColor
            layer.shadowOpacity = 1
            layer.shadowOffset = CGSize(width: 0, height: 0)
            layer.shadowRadius = 20
        case .add:
            setImage(R.image.icon_button_add(), for: .normal)
            setImage(R.image.icon_button_add(), for: .highlighted)
            setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
            titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            setBackgroundImage(R.image.background_add_button_white()?.resizable, for: .normal)
            setBackgroundImage(R.image.background_add_button_white()?.tintColor(UIColor(netHex: 0xefefef)).resizable, for: .highlighted)
            contentEdgeInsets = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25 + 10)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.1
            layer.shadowRadius = 3
            layer.shadowOffset = CGSize(width: 0, height: 0)
        case .navigationItemCustomView:
            titleLabel?.font = UIFont.systemFont(ofSize: 14)
            titleLabel?.adjustsFontSizeToFitWidth = true
            setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
        case .red:
            setTitleColor(UIColor.white, for: .normal)
            setBackgroundImage(R.image.background_button_blue()?.tintColor(UIColor(netHex: 0xE5494D)).resizable, for: .normal)
            setBackgroundImage(R.image.background_button_blue()?.tintColor(UIColor(netHex: 0xE5494D)).highlighted.resizable, for: .highlighted)
            setBackgroundImage(R.image.background_button_blue()?.tintColor(UIColor(netHex: 0xEFF0F4)).resizable, for: .disabled)
        case .green:
            setTitleColor(UIColor.white, for: .normal)
            setBackgroundImage(R.image.background_button_blue()?.tintColor(UIColor(netHex: 0x01D764)).resizable, for: .normal)
            setBackgroundImage(R.image.background_button_blue()?.tintColor(UIColor(netHex: 0x01D764)).highlighted.resizable, for: .highlighted)
            setBackgroundImage(R.image.background_button_blue()?.tintColor(UIColor(netHex: 0xEFF0F4)).resizable, for: .disabled)
        case .gray:
            setTitleColor(UIColor(netHex: 0x3E4A59, alpha: 0.7), for: .normal)
            setBackgroundImage(R.image.background_button_gray()?.resizable, for: .normal)
            setBackgroundImage(R.image.background_button_gray()?.highlighted.resizable, for: .highlighted)
            setTitleColor(UIColor.white, for: .disabled)
            setBackgroundImage(R.image.background_button_blue()?.tintColor(UIColor(netHex: 0xEFF0F4)).resizable, for: .disabled)
        }
    }

    static func topImage(_ image: UIImage?, bottomTitle title: String) -> UIButton {
        let icon = UIImageView(image: image)
        let label = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12)
            $0.textColor = UIColor(netHex: 0xA1A9CB)
            $0.text = title
        }

        let button = UIButton()
        button.setBackgroundImage(UIImage.color(.white), for: .normal)
        button.setBackgroundImage(UIImage.color(UIColor.black.withAlphaComponent(0.1)), for: .highlighted)

        let layoutGuide = UILayoutGuide()
        button.addSubview(icon)
        button.addSubview(label)
        button.addLayoutGuide(layoutGuide)

        layoutGuide.snp.makeConstraints { (m) in
            m.center.equalToSuperview()
            m.width.equalToSuperview()
        }

        icon.snp.makeConstraints { (m) in
            m.top.equalTo(layoutGuide)
            m.centerX.equalToSuperview()
        }

        label.snp.makeConstraints { (m) in
            m.top.equalTo(icon.snp.bottom).offset(8)
            m.centerX.equalToSuperview()
            m.bottom.equalTo(layoutGuide)
        }

        button.setupShadow(CGSize(width: 0, height: 5))

        return button
    }
}
