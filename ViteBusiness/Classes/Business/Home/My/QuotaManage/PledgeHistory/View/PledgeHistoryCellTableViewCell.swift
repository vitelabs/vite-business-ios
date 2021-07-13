//
//  PledgeHistoryCellTableViewCell.swift
//  Vite
//
//  Created by haoshenyang on 2018/10/29.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit

final class PledgeHistoryCell: BaseTableViewCell {

    let addressTitleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x77808A)
        $0.text = R.string.localizable.peldgeAddressTitle()
    }

    let addressLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
        $0.lineBreakMode = .byTruncatingMiddle
    }

    let addressBackView = UIImageView().then {
        $0.image = UIImage.image(withColor: UIColor(netHex: 0xF3F5F9), cornerRadius: 2).resizable
        $0.highlightedImage = UIImage.color(UIColor(netHex: 0xd9d9d9))
    }

    let timeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .light)
        $0.textColor = UIColor(netHex: 0x3E4A59).withAlphaComponent(0.60)
    }
    
    let timeTitleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .light)
        $0.textColor = UIColor(netHex: 0x3E4A59).withAlphaComponent(0.60)
        $0.text = R.string.localizable.peldgeDeadline()
    }

    let balanceLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
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
        
        contentView.addSubview(addressTitleLabel)
        contentView.addSubview(addressBackView)
        contentView.addSubview(addressLabel)
        contentView.addSubview(balanceLabel)
        contentView.addSubview(symbolLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(timeTitleLabel)
        contentView.addSubview(cancelButton)

        addressTitleLabel.setContentHuggingPriority(.required, for: .horizontal)
        addressTitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        addressTitleLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(11)
            m.left.equalToSuperview().offset(24)
        }

        addressBackView.snp.makeConstraints { (m) in
            m.centerY.equalTo(addressTitleLabel)
            m.height.equalTo(20)
            m.left.equalTo(addressTitleLabel.snp.right).offset(12)
            m.right.equalToSuperview().offset(-24)
        }

        addressLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(addressBackView)
            m.left.equalTo(addressBackView).offset(5)
            m.right.equalTo(addressBackView).offset(-5)
        }

        balanceLabel.snp.makeConstraints { (m) in
            m.top.equalTo(addressBackView.snp.bottom).offset(8)
            m.left.greaterThanOrEqualToSuperview().offset(24)
        }

        symbolLabel.setContentHuggingPriority(.required, for: .horizontal)
        symbolLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        symbolLabel.snp.makeConstraints { (m) in
            m.left.equalTo(balanceLabel.snp.right).offset(8)
            m.right.equalToSuperview().offset(-24)
            m.centerY.equalTo(balanceLabel)
        }
        
        timeLabel.snp.makeConstraints { (m) in
            m.bottom.greaterThanOrEqualTo(timeTitleLabel.snp.top).offset(-5)
            m.left.equalToSuperview().offset(24)
        }

        timeTitleLabel.snp.makeConstraints { (m) in
            m.bottom.equalToSuperview().offset(-13)
            m.left.equalToSuperview().offset(24)
        }

        cancelButton.snp.makeConstraints { (m) in
            m.centerY.equalTo(timeTitleLabel)
            m.right.equalToSuperview().offset(-24)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
