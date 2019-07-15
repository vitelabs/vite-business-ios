//
//  EthViteExchangeAmountView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/5/9.
//

import UIKit

class EthViteExchangeAmountView: UIView {

    let titleLabel = UILabel().then {
        $0.textColor = Colors.titleGray
        $0.font = AppStyle.formHeader.font
    }

    let button = UIButton().then {
        $0.setTitle(R.string.localizable.ethViteExchangePageExchangeAllButtonTitle(), for: .normal)
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

    let symbolLabel = UILabel().then {
        $0.textColor = Colors.titleGray
        $0.font = AppStyle.descWord.font
        $0.textAlignment = .right
    }

    let separatorLine = UIView().then {
        $0.backgroundColor = Colors.lineGray
    }

    init() {
        super.init(frame: CGRect.zero)

        titleLabel.text = R.string.localizable.ethViteExchangePageAmountTitle()

        addSubview(titleLabel)
        addSubview(button)
        addSubview(textField)
        addSubview(symbolLabel)
        addSubview(separatorLine)

        separatorLine.snp.makeConstraints { (m) in
            m.height.equalTo(CGFloat.singleLineWidth)
            m.left.equalTo(self)
            m.right.equalTo(self)
            m.bottom.equalTo(self)
        }

        titleLabel.snp.makeConstraints { (m) in
            m.top.equalTo(self).offset(20)
            m.left.equalTo(self)
        }

        button.snp.makeConstraints { (m) in
            m.centerY.equalTo(titleLabel)
            m.right.equalTo(self)
        }

        textField.textColor = Colors.cellTitleGray
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.snp.makeConstraints { (m) in
            m.left.equalTo(titleLabel)
            m.top.equalTo(titleLabel.snp.bottom).offset(10)
            m.bottom.equalTo(self).offset(-10)
        }

        symbolLabel.snp.makeConstraints { (m) in
            m.left.equalTo(textField.snp.right).offset(10)
            m.right.equalTo(self)
            m.centerY.equalTo(textField)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
