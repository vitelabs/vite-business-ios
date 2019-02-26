//
//  TokenListInfoCell.swift
//  ViteBusiness
//
//  Created by Water on 2019/2/22.
//

import UIKit
import RxSwift
import ViteUtils

class TokenListInfoCell: UITableViewCell {
    let symbolLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textAlignment = .left
        $0.textColor = UIColor.init(netHex: 0x3E4A59)
    }

    let tokenNameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 11)
        $0.textAlignment = .left
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.6)
    }

    let tokenAddressLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 11)
        $0.textAlignment = .left
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.6)
    }

    let tokenLogoImg = UIImageView().then {
        $0.isUserInteractionEnabled = true
    }

    let rightContentView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.separatorInset = UIEdgeInsets.init(top: 0, left: 24, bottom: 0, right: 24)
        self.selectionStyle = .none

        self.contentView.addSubview(tokenLogoImg)
        tokenLogoImg.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-24)
            m.centerY.equalToSuperview()
            m.width.equalTo(32)
            m.height.equalTo(32)
        }

        self.contentView.addSubview(rightContentView)
        rightContentView.snp.makeConstraints { (m) in
            m.left.equalTo(self.tokenLogoImg.snp.right).offset(9)
            m.right.equalTo(self.contentView).offset(100)
            m.centerY.equalTo(self.contentView)
        }

        rightContentView.addSubview(symbolLabel)
        symbolLabel.snp.makeConstraints { (m) in
            m.left.equalTo(rightContentView)
            m.width.equalTo(110)
            m.height.equalTo(17)
        }

        rightContentView.addSubview(tokenNameLabel)
        tokenNameLabel.snp.makeConstraints { (m) in
            m.left.equalTo(rightContentView)
            m.top.equalTo(self.symbolLabel.snp.bottom).offset(2)
            m.width.equalTo(110)
            m.height.equalTo(15)
        }

        rightContentView.addSubview(tokenAddressLabel)
        tokenAddressLabel.snp.makeConstraints { (m) in
            m.left.equalTo(rightContentView)
            m.top.equalTo(self.tokenNameLabel.snp.bottom).offset(2)
            m.width.equalTo(110)
            m.height.equalTo(15)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

