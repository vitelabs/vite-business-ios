//
//  MyAddressManageHeaderView.swift
//  Vite
//
//  Created by Stone on 2018/9/19.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit

class MyAddressManageHeaderView: UIView {

    let titleLabel = UILabel().then {
        $0.text = R.string.localizable.addressManageDefaultAddressCellTitle()
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
    }

    let titleBgImageView = UIImageView(image: R.image.icon_address_default_title_frame()?.resizable)

    let nameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59)
    }

    let addressLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x24272B, alpha: 0.7)
        $0.numberOfLines = 2
    }

    let numberButton = UIButton().then {
        $0.isUserInteractionEnabled = false
        $0.setBackgroundImage(UIImage.image(withColor: UIColor(netHex: 0xDFEEFF), cornerRadius: 2).resizable, for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x3E4A59, alpha: 0.45), for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
    }


    let addressListTitleLabel = UILabel().then {
        $0.text = R.string.localizable.addressManageAddressHeaderTitle()
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = UIColor(netHex: 0x3E4A59)
    }

    let tipButton = UIButton().then {
        $0.setImage(R.image.icon_button_infor(), for: .normal)
        $0.setImage(R.image.icon_button_infor()?.highlighted, for: .highlighted)
    }

    init(showAddressesTips: Bool) {
        super.init(frame: .zero)

        tipButton.isHidden = !showAddressesTips

        let backView = UIView()

        backView.backgroundColor = UIColor(netHex: 0x007AFF).withAlphaComponent(0.06)
        backView.layer.borderColor = UIColor(netHex: 0x007AFF).withAlphaComponent(0.12).cgColor
        backView.layer.borderWidth = CGFloat.singleLineWidth

        addSubview(backView)
        addSubview(addressListTitleLabel)
        addSubview(tipButton)

        backView.addSubview(titleBgImageView)
        backView.addSubview(titleLabel)
        backView.addSubview(nameLabel)
        backView.addSubview(addressLabel)
        backView.addSubview(numberButton)

        backView.snp.makeConstraints { (m) in
            m.top.left.right.equalTo(self)
        }

        nameLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(16)
            m.left.equalToSuperview().offset(24)
        }

        titleBgImageView.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(16)
            m.right.equalToSuperview().offset(-16)
            m.height.equalTo(18)
            m.left.equalTo(nameLabel.snp.right).offset(20)
        }

        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        titleLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(titleBgImageView)
            m.left.equalTo(titleBgImageView).offset(5)
            m.right.equalTo(titleBgImageView).offset(-5)
        }

        addressLabel.snp.makeConstraints { (m) in
            m.top.equalTo(titleLabel.snp.bottom).offset(11)
            m.left.equalTo(nameLabel)
            m.right.equalTo(titleBgImageView)
            m.bottom.equalToSuperview().offset(-13)
        }

        numberButton.snp.makeConstraints { (m) in
            m.left.equalTo(addressLabel)
            m.top.equalTo(addressLabel).offset(2)
            m.size.equalTo(CGSize(width: 24, height: 14))
        }

        addressListTitleLabel.snp.makeConstraints { (m) in
            m.top.equalTo(backView.snp.bottom).offset(20)
            m.left.equalTo(self).offset(24)
            m.bottom.equalTo(self).offset(-20)
        }

        tipButton.snp.makeConstraints { (m) in
            m.left.equalTo(addressListTitleLabel.snp.right).offset(10)
            m.centerY.equalTo(addressListTitleLabel)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
