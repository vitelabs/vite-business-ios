//
//  PledgeHistoryCellTableViewCell.swift
//  Vite
//
//  Created by haoshenyang on 2018/10/29.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit

final class PledgeHistoryCell: BaseTableViewCell {

    let hashLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.lineBreakMode = .byTruncatingMiddle
    }

    let timeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = UIColor(netHex: 0x3E4A59).withAlphaComponent(0.60)
    }

    let balanceLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 16)
        $0.textColor = UIColor(netHex: 0x3E4A59)
    }

    let symbolLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = UIColor(netHex: 0x3E4A59).withAlphaComponent(0.60)
    }

    let cancelButton = UIButton().then {
        $0.setBackgroundImage(UIImage.image(withColor: UIColor(netHex: 0x007AFF), cornerRadius: 11).resizable, for: .normal)
        $0.setBackgroundImage(UIImage.image(withColor: UIColor(netHex: 0x007AFF), cornerRadius: 11).highlighted.resizable, for: .highlighted)
        $0.setBackgroundImage(UIImage.image(withColor: UIColor(netHex: 0xBCC0CA), cornerRadius: 11).resizable, for: .disabled)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.separatorInset = UIEdgeInsets.init(top: 0, left: 24, bottom: 0, right: -24)
        self.selectionStyle = .none

        contentView.addSubview(hashLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(balanceLabel)
        contentView.addSubview(symbolLabel)
        contentView.addSubview(cancelButton)

        hashLabel.snp.makeConstraints { (m) in
            m.top.equalTo(contentView).offset(16)
            m.left.equalTo(contentView.snp.left).offset(24)
        }

        timeLabel.snp.makeConstraints { (m) in
            m.top.equalTo(hashLabel.snp.bottom).offset(11)
            m.left.equalTo(hashLabel)
        }

        balanceLabel.setContentHuggingPriority(.required, for: .horizontal)
        balanceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        balanceLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(hashLabel)
            m.left.greaterThanOrEqualTo(hashLabel.snp.right).offset(22)
        }

        symbolLabel.setContentHuggingPriority(.required, for: .horizontal)
        symbolLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        symbolLabel.snp.makeConstraints { (m) in
            m.left.equalTo(balanceLabel.snp.right).offset(8)
            m.right.equalTo(contentView).offset(-24)
            m.centerY.equalTo(balanceLabel)
        }

        cancelButton.snp.makeConstraints { (m) in
            m.bottom.equalTo(timeLabel)
            m.right.equalTo(symbolLabel)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
