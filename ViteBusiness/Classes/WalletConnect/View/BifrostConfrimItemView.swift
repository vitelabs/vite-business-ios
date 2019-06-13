//
//  BifrostConfrimItemView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/6/13.
//

import UIKit

class BifrostConfrimItemView: UIView {

    private let titleLabel = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        $0.numberOfLines = 1
    }

    private let valueLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        $0.numberOfLines = 1
    }

    init(info: BifrostConfrimItemInfo) {
        super.init(frame: CGRect.zero)

        snp.makeConstraints { (m) in
            m.height.equalTo(info.isUnderscored ? 60 : 44)
        }

        addSubview(titleLabel)
        addSubview(valueLabel)

        let gap = info.isUnderscored ? 8 : 0

        titleLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(gap)
            m.left.equalToSuperview().offset(24)
            m.right.equalToSuperview().offset(-24)
        }
        valueLabel.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(24)
            m.right.equalToSuperview().offset(-24)
            m.bottom.equalToSuperview().offset(-gap)
        }

        titleLabel.text = info.title
        valueLabel.text = info.value
        valueLabel.textColor = info.valueColor ?? UIColor(netHex: 0x3E4A59)
        backgroundColor = info.backgroundColor ?? UIColor.clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
