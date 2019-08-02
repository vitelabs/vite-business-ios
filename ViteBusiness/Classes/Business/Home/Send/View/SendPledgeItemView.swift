//
//  SendPledgeItemView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/8/1.
//

import UIKit

class SendPledgeItemView: SendStaticItemView {

    init() {
        super.init(title: R.string.localizable.quotaManagePageQuotaSnapshootHeightTitle(), rightViewStyle: .label(style: .attributed(string: {
            let str = R.string.localizable.quotaManagePageQuotaSnapshootHeightDesc("3")
            let range = str.range(of: "3")!
            let attributedString = NSMutableAttributedString(string: str)
            attributedString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor(netHex: 0x3E4A59)], range: NSRange.init(range, in: str))
            return attributedString
        }())))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
