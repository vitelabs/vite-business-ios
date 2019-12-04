//
//  SendTextFieldItemView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/8/1.
//

import UIKit

class SendTextFieldItemView: SendItemView {

    let textField = UITextField().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.cellTitleGray
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
    }

    override init(title: String, rightViewStyle: RightViewStyle = .none, titleTipButtonStyle: TitleTipButtonStyle = .none) {
        super.init(title: title, rightViewStyle: rightViewStyle, titleTipButtonStyle: titleTipButtonStyle)

        switch rightViewStyle {
        case .none:
            rightView = nil
        case .label(let style):
            rightView = style.createLabel()
        case .button(let style):
            rightView = style.createButton()
        }

        switch titleTipButtonStyle {
        case .none:
            tipButton = nil
        case .button(let style):
            tipButton = style.createButton()
        }

        addSubview(textField)

        if let tipButton = tipButton {
            addSubview(tipButton)
            titleLabel.snp.remakeConstraints { (m) in
                m.top.left.equalToSuperview()
            }
            tipButton.snp.makeConstraints { (m) in
                m.left.equalTo(titleLabel.snp.right).offset(6)
                m.centerY.equalTo(titleLabel)
            }
        } else {
            titleLabel.snp.remakeConstraints { (m) in
                m.top.left.right.equalToSuperview()
            }
        }

        if let rightView = rightView {
            addSubview(rightView)
            textField.snp.makeConstraints { (m) in
                m.top.equalTo(titleLabel.snp.bottom).offset(11)
                m.left.equalToSuperview()
                m.bottom.equalToSuperview().offset(-11)
            }
            rightView.snp.makeConstraints { (m) in
                m.right.equalToSuperview()
                m.centerY.equalTo(textField)
                m.left.equalTo(textField.snp.right).offset(6)
            }
            textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
            textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            rightView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            rightView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        } else {
            textField.snp.makeConstraints { (m) in
                m.top.equalTo(titleLabel.snp.bottom).offset(11)
                m.left.right.equalToSuperview()
                m.bottom.equalToSuperview().offset(-11)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
