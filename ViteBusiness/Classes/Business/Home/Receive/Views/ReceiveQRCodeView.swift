//
//  ReceiveQRCodeView.swift
//  Vite
//
//  Created by Stone on 2018/9/26.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit

class ReceiveQRCodeView: UIView {

    let tokenSymbolLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x24272B)
        $0.numberOfLines = 0
    }

    let imageView = UIImageView()
    let iconView = TokenIconView()

    let amountButton = UIButton().then {
        $0.setTitle(R.string.localizable.receivePageTokenAmountButtonTitle(), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x00BEFF), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x00BEFF).highlighted, for: .highlighted)
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(tokenSymbolLabel)
        addSubview(imageView)
        addSubview(amountButton)

        tokenSymbolLabel.snp.makeConstraints { (m) in
            m.top.equalTo(self).offset(28)
            m.left.equalTo(self).offset(24)
            m.right.equalTo(self).offset(-24)
        }

        imageView.snp.makeConstraints { (m) in
            m.top.equalTo(tokenSymbolLabel.snp.bottom).offset(28)
            m.centerX.equalTo(self)
            m.size.equalTo(CGSize(width: 170, height: 170))
        }

        amountButton.snp.makeConstraints { (m) in
            m.top.equalTo(imageView.snp.bottom).offset(20)
            m.centerX.equalTo(self)
            m.bottom.equalTo(self)
        }

        imageView.addSubview(iconView)
        iconView.set(cornerRadius: 20)
        iconView.snp.makeConstraints { (m) in
            m.center.equalToSuperview()
            m.size.equalTo(CGSize(width: 40, height: 40))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
