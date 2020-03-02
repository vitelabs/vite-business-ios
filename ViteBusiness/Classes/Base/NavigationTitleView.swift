//
//  NavigationTitleView.swift
//  Vite
//
//  Created by Stone on 2018/9/14.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import SnapKit

public class NavigationTitleView: UIView {

    public enum Style {
        case `default`
        case white
        case custom(color: UIColor)
    }

    let titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 24)
        $0.numberOfLines = 1
        $0.adjustsFontSizeToFitWidth = true
    }

    public init(title: String?, style: Style = .default, horizontal: CGFloat = 24) {
        super.init(frame: CGRect.zero)
        titleLabel.text = title
        addSubview(titleLabel)
        // top: 6, bottom: 20
        titleLabel.snp.makeConstraints { (m) in
            m.top.equalTo(self).offset(6)
            m.left.equalTo(self).offset(horizontal)
            m.right.equalTo(self).offset(-horizontal)
            m.bottom.equalTo(self).offset(-20)
            m.height.equalTo(29)
        }

        switch style {
        case .default:
            titleLabel.textColor = UIColor(netHex: 0x24272B)
            backgroundColor = UIColor.white
        case .white:
            titleLabel.textColor = UIColor.white
            backgroundColor = UIColor.clear
        case .custom(let color):
            titleLabel.textColor = color
            backgroundColor = UIColor.clear
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
