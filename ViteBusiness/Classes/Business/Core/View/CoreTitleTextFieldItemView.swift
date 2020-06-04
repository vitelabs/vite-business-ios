//
//  CoreTitleTextFieldItemView.swift
//  ViteBusiness
//
//  Created by Stone on 2020/6/4.
//

import Foundation

class CoreTitleTextFieldItemView: UIView {
    
    let titleLabel = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.numberOfLines = 1
    }

    let allButton = UIButton().then {
        $0.setTitle(R.string.localizable.sendPageAllButtonTitle(), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)

        let lineImageView = UIImageView(image: R.image.blue_dotted_line()?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .tile))

        $0.addSubview(lineImageView)
        let titleLabel = $0.titleLabel!
        lineImageView.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview()
            m.bottom.equalTo(titleLabel).offset(2)
        }
    }

    let textField = UITextField().then {
        $0.font = AppStyle.descWord.font
    }

    let separatorLine = UIView().then {
        $0.backgroundColor = UIColor(netHex: 0xD3DFEF)
    }

    init(title: String, placeholder: String? = nil, text: String? = nil, allButtonTitle: String? = nil, allButtonClicked: (() -> Void)? = nil) {
        super.init(frame: .zero)

        let horizontal: CGFloat = 24

        titleLabel.text = title
        textField.placeholder = placeholder
        textField.text = text

        addSubview(titleLabel)
        addSubview(textField)
        addSubview(separatorLine)

        if let block = allButtonClicked {
            addSubview(allButton)
            allButton.snp.makeConstraints { (m) in
                m.top.equalToSuperview()
                m.right.equalToSuperview().offset(-horizontal)
            }

            if let title = allButtonTitle {
                allButton.setTitle(title, for: .normal)
            }
        }

        titleLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.equalToSuperview().offset(horizontal)
        }

        textField.snp.makeConstraints { (m) in
            m.top.equalTo(titleLabel.snp.bottom).offset(6)
            m.left.right.equalToSuperview().inset(horizontal)
        }

        separatorLine.snp.makeConstraints { (m) in
            m.bottom.equalToSuperview()
            m.left.right.equalToSuperview().inset(horizontal)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
