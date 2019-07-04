//
//  BifrostConfrimTitleView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/6/13.
//

import UIKit

class BifrostConfrimTitleView: UIView {

    private let titleLabel = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        $0.numberOfLines = 1
    }

    init(title: String) {
        super.init(frame: CGRect.zero)

        snp.makeConstraints { (m) in
            m.height.equalTo(54)
        }

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.left.equalToSuperview().offset(24)
            m.right.equalToSuperview().offset(-24)
        }

        titleLabel.text = title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
