//
//  BifrostStatusView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/6/11.
//

import UIKit

class BifrostStatusView: UIButton {

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 0, height: 32)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        setTitle(R.string.localizable.bifrostConnectTipInWalletHome(), for: .normal)
        setTitleColor(UIColor(netHex: 0x007AFF, alpha: 0.7), for: .normal)
        setTitleColor(UIColor(netHex: 0x007AFF, alpha: 0.7), for: .highlighted)
        backgroundColor = UIColor(netHex: 0xF5FAFF)

        rx.tap.bind {
            BifrostManager.instance.showHomeVC()
        }.disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
