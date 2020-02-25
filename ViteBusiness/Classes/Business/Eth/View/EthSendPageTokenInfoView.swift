//
//  EthSendPageTokenInfoView.swift
//  ViteBusiness
//
//  Created by Water on 2019/2/21.
//
import UIKit
import SnapKit

class EthSendPageTokenInfoView: UIView {

    let addressTitleLabel = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
    }

    let addressLabel = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        $0.numberOfLines = 2
    }

    let balanceTitleLabel = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        $0.text = R.string.localizable.sendPageMyBalanceTitle()
    }

    let balanceLabel = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
    }

    init(address: String, name: String = R.string.localizable.ethSendPageMyAddressTitle()) {
        super.init(frame: CGRect.zero)
        addressLabel.text = address
        addressTitleLabel.text = name

        let contentView = createContentViewAndSetShadow(width: 0, height: 5, radius: 9)
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 2

        let line = UIView().then { $0.backgroundColor = UIColor(netHex: 0x759BFA) }

        contentView.addSubview(line)
        contentView.addSubview(addressTitleLabel)
        contentView.addSubview(addressLabel)
        contentView.addSubview(balanceTitleLabel)
        contentView.addSubview(balanceLabel)

        line.snp.makeConstraints({ (m) in
            m.top.bottom.left.equalTo(contentView)
            m.width.equalTo(3)
        })

        addressTitleLabel.snp.makeConstraints({ (m) in
            m.top.equalTo(contentView).offset(16)
            m.left.equalTo(contentView).offset(19)
            m.right.equalTo(contentView).offset(-16)
        })

        addressLabel.snp.makeConstraints({ (m) in
            m.top.equalTo(addressTitleLabel.snp.bottom).offset(8)
            m.left.right.equalTo(addressTitleLabel)
        })

        balanceTitleLabel.snp.makeConstraints({ (m) in
            m.top.equalTo(addressLabel.snp.bottom).offset(16)
            m.left.right.equalTo(addressTitleLabel)
        })

        balanceLabel.snp.makeConstraints({ (m) in
            m.top.equalTo(balanceTitleLabel.snp.bottom).offset(8)
            m.left.right.equalTo(addressTitleLabel)
            m.bottom.equalToSuperview().offset(-16)
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

