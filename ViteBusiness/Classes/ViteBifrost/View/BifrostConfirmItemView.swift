//
//  BifrostConfirmItemView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/6/13.
//

import UIKit

class BifrostConfirmItemView: UIView {

    private let titleLabel = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        $0.numberOfLines = 0
    }

    private let textLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        $0.numberOfLines = 0
    }

    init(info: BifrostConfirmItemInfo) {
        super.init(frame: CGRect.zero)

        addSubview(titleLabel)
        addSubview(textLabel)

        let gap = info.isUnderscored ? 8 : 0

        titleLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(gap)
            m.left.equalToSuperview().offset(24)
            m.right.equalToSuperview().offset(-24)
        }
        textLabel.snp.makeConstraints { (m) in
            m.top.equalTo(titleLabel.snp.bottom).offset(8)
            m.left.equalToSuperview().offset(24)
            m.right.equalToSuperview().offset(-24)
            m.bottom.equalToSuperview().offset(-gap)
        }

        titleLabel.text = info.title
        textLabel.text = info.text
        textLabel.textColor = info.textColor ?? UIColor(netHex: 0x3E4A59)
        backgroundColor = info.backgroundColor ?? UIColor.clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
