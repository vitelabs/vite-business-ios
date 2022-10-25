//
//  TokenListAddressView.swift
//  ViteBusiness
//
//  Created by Water on 2019/2/28.
//

import UIKit
import SnapKit


class TokenListAddressView: UILabel {
    init() {
        super.init(frame: CGRect.zero)
        self.textAlignment = .left
        self.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        self.lineBreakMode = .byTruncatingMiddle
        self.textColor = UIColor(netHex: 0xFFFFFF,alpha:0.7)
        self.text = ""
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



