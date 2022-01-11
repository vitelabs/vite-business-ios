//
//  MiningColorfulView.swift
//  ViteBusiness
//
//  Created by Stone on 2020/6/3.
//

import Foundation
import UIKit

class MiningColorfulView: UIView {

    static let height: CGFloat = 78

    let leftButton = UIButton().then {
        $0.setTitleColor(UIColor.init(netHex: 0x3E4A59, alpha: 0.6), for: .normal)
        $0.setTitleColor(UIColor.init(netHex: 0x3E4A59, alpha: 0.6), for: .highlighted)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.titleLabel?.adjustsFontSizeToFitWidth = true
        $0.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.titleLabel?.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
    }

    let rightButton = UIButton().then {
        $0.setTitleColor(UIColor.init(netHex: 0x007AFF), for: .normal)
        $0.setTitleColor(UIColor.init(netHex: 0x007AFF).highlighted, for: .highlighted)
        $0.setImage(R.image.icon_mining_trading_right_white()?.tintColor(UIColor.init(netHex: 0x007AFF)), for: .normal)
        $0.setImage(R.image.icon_mining_trading_right_white()?.tintColor(UIColor.init(netHex: 0x007AFF)).highlighted, for: .highlighted)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.titleLabel?.adjustsFontSizeToFitWidth = true
        $0.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.titleLabel?.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 2)
    }

    let valueLabel = UILabel().then {
        $0.textColor = UIColor.init(netHex: 0x24272B)
        $0.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        $0.numberOfLines = 1
        $0.text = "--.--"
    }


    init(leftText: String, leftClicked: (() -> Void)?, rightText: String, rightClicked: @escaping () -> Void) {
        super.init(frame: .zero)

        leftButton.setTitle(leftText, for: .normal)
        rightButton.setTitle(rightText, for: .normal)

        backgroundColor = .white

        addSubview(leftButton)
        addSubview(rightButton)
        addSubview(valueLabel)

        leftButton.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(16)
            m.left.equalToSuperview()
        }

        rightButton.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(16)
            m.right.equalToSuperview()
        }

        valueLabel.snp.makeConstraints { (m) in
            m.top.equalTo(leftButton.snp.bottom).offset(6)
            m.left.right.equalToSuperview()
        }

        snp.makeConstraints { (m) in
            m.height.equalTo(type(of: self).height)
        }

        if let leftClicked = leftClicked {
            leftButton.setImage(R.image.icon_mining_trading_infor()?.tintColor(UIColor.init(netHex: 0x3E4A59, alpha: 0.6)), for: .normal)
            leftButton.setImage(R.image.icon_mining_trading_infor()?.tintColor(UIColor.init(netHex: 0x3E4A59, alpha: 0.6)).highlighted, for: .highlighted)
            leftButton.rx.tap.bind {
                leftClicked()
            }.disposed(by: rx.disposeBag)
        }

        rightButton.rx.tap.bind {
            rightClicked()
        }.disposed(by: rx.disposeBag)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
