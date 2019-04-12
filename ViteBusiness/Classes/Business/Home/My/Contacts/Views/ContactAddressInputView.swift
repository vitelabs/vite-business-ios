//
//  ContactAddressInputView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/8.
//

import UIKit

class ContactAddressInputView: UIView {

    let titleLabel = UILabel().then {
        $0.textColor = Colors.titleGray
        $0.font = AppStyle.formHeader.font
    }

    let textView = UITextView().then {
        $0.backgroundColor = UIColor.clear
    }


    let typeButton = UIButton().then {
        $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)
        $0.setImage(R.image.icon_button_address_type(), for: .normal)
        $0.setImage(R.image.icon_button_address_type()?.highlighted, for: .highlighted)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .light)
        $0.titleLabel?.adjustsFontSizeToFitWidth = true
        $0.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.titleLabel?.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
    }

    let scanButton = UIButton()

    init() {
        super.init(frame: CGRect.zero)

        titleLabel.text = R.string.localizable.contactsEditPageAddressTitle()

        addSubview(titleLabel)
        addSubview(typeButton)
        addSubview(textView)
        addSubview(scanButton)

        scanButton.setImage(R.image.icon_button_address_scan(), for: .normal)
        scanButton.setImage(R.image.icon_button_address_scan()?.highlighted, for: .highlighted)

        titleLabel.snp.makeConstraints { (m) in
            m.top.equalTo(self)
            m.left.equalTo(self)
            m.right.equalTo(self)
        }

        typeButton.snp.makeConstraints { (m) in
            m.top.equalTo(titleLabel.snp.bottom)
            m.left.equalTo(titleLabel)
            m.bottom.equalToSuperview()
            m.width.equalTo(40)
        }

        textView.snp.makeConstraints { (m) in
            m.top.equalTo(titleLabel.snp.bottom).offset(10)
            m.left.equalTo(typeButton.snp.right).offset(10)
            m.right.equalTo(scanButton.snp.left).offset(-10)
            m.height.equalTo(55)
            m.bottom.equalTo(self)
        }

        scanButton.snp.makeConstraints { (m) in
            m.right.equalTo(titleLabel)
            m.centerY.equalTo(typeButton)
        }

        textView.textColor = UIColor(netHex: 0x24272B)
        textView.font = UIFont.systemFont(ofSize: 16, weight: .regular)

        let vLine = UIView()
        vLine.backgroundColor = Colors.lineGray
        addSubview(vLine)
        vLine.snp.makeConstraints { (m) in
            m.width.equalTo(CGFloat.singleLineWidth)
            m.height.equalTo(28)
            m.centerY.equalTo(typeButton)
            m.left.equalTo(typeButton.snp.right).offset(5)
        }

        let separatorLine = UIView()
        separatorLine.backgroundColor = Colors.lineGray
        addSubview(separatorLine)
        separatorLine.snp.makeConstraints { (m) in
            m.height.equalTo(CGFloat.singleLineWidth)
            m.left.right.equalTo(titleLabel)
            m.bottom.equalTo(self)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
