//
//  EthAddressView.swift
//  ViteBusiness
//
//  Created by Water on 2019/2/28.
//

import UIKit
import SnapKit
import ViteEthereum

class EthAddressView: UILabel {
    init() {
        super.init(frame: CGRect.zero)
        self.textAlignment = .center
        self.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        self.lineBreakMode = .byTruncatingMiddle
        self.textColor = UIColor(netHex: 0xFFFFFF,alpha:0.7)
        self.text = EtherWallet.account.address
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



