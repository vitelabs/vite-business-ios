//
//  CoreLeftRightItemView.swift
//  ViteBusiness
//
//  Created by Stone on 2020/6/4.
//

import Foundation

class CoreTitleTextItemView: UIView {

    let titleLabel = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.numberOfLines = 1
    }

    let textLabel = UILabel().then {
        $0.textColor = UIColor(netHex: 0x007AFF, alpha: 0.7)
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.numberOfLines = 1
        $0.textAlignment = .right
    }

    init(title: String, text: String) {
        super.init(frame: .zero)

        let horizontal: CGFloat = 24

        titleLabel.text = title
        textLabel.text = text

        backgroundColor = UIColor(netHex: 0x007AFF, alpha: 0.06)

        addSubview(titleLabel)
        addSubview(textLabel)

        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.left.equalToSuperview().offset(horizontal)
        }

        textLabel.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.left.equalTo(titleLabel.snp.right).offset(10)
            m.right.equalToSuperview().offset(-horizontal)
        }

        snp.makeConstraints { (m) in
            m.height.equalTo(50)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
