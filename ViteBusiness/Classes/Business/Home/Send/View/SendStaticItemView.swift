//
//  SendStaticItemView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/8/1.
//

import UIKit

class SendStaticItemView: SendItemView {

    override init(title: String, rightViewStyle: RightViewStyle = .none, titleTipButtonStyle: TitleTipButtonStyle = .none) {
        super.init(title: title, rightViewStyle: rightViewStyle, titleTipButtonStyle: titleTipButtonStyle)

        rightView = rightViewStyle.createRightView()

        switch titleTipButtonStyle {
        case .none:
            tipButton = nil
        case .button(let style):
            tipButton = style.createButton()
        }
        
        guard rightView != nil || tipButton != nil else {
            return
        }

        titleLabel.snp.remakeConstraints { (m) in
            m.top.left.equalToSuperview()
            m.bottom.equalToSuperview().offset(-22)
        }

        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        let leftView: UIView
        if let tipButton = tipButton {
            addSubview(tipButton)
            tipButton.snp.makeConstraints { (m) in
                m.left.equalTo(titleLabel.snp.right).offset(6)
                m.centerY.equalTo(titleLabel)
            }
            tipButton.setContentHuggingPriority(.required, for: .horizontal)
            tipButton.setContentCompressionResistancePriority(.required, for: .horizontal)
            leftView = tipButton
        } else {
            leftView = titleLabel
        }

        if let rightView = rightView {
            addSubview(rightView)
            rightView.snp.makeConstraints { (m) in
                m.right.equalToSuperview()
                m.centerY.equalTo(leftView)
                m.left.greaterThanOrEqualTo(leftView.snp.right).offset(6)
            }
            rightView.setContentHuggingPriority(.defaultLow, for: .horizontal)
            rightView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
