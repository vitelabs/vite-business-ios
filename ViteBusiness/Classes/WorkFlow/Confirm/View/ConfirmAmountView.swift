//
//  ConfirmAmountView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/13.
//

import UIKit

class ConfirmAmountView: UIView {

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 0, height: 50)
    }

    enum ViewType {
        case amount
        case fee
        case quota
        case custom(title: String, hasBackgroundColor: Bool)
    }

    let titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.7)
    }

    private let textLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textAlignment = .right
        $0.adjustsFontSizeToFitWidth = true
    }

    private let type: ViewType

    init(type: ViewType) {
        self.type = type
        super.init(frame: CGRect.zero)

        addSubview(titleLabel)
        addSubview(textLabel)

        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        textLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        textLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        switch type {
        case .amount:
            backgroundColor = UIColor(netHex: 0xF9FCFF)
            titleLabel.text = R.string.localizable.confirmTransactionAmountTitle()
            textLabel.textColor = UIColor(netHex: 0x007AFF, alpha: 0.7)
        case .fee:
            backgroundColor = UIColor(netHex: 0xffffff)
            titleLabel.text = R.string.localizable.confirmTransactionFeeTitle()
            textLabel.textColor = UIColor(netHex: 0x24272B, alpha: 0.7)
        case .quota:
            backgroundColor = UIColor(netHex: 0xffffff)
            titleLabel.text = R.string.localizable.confirmTransactionQuotaTitle()
            textLabel.textColor = UIColor(netHex: 0x007AFF, alpha: 0.7)
        case .custom(let title, let hasBackgroundColor):
            backgroundColor = hasBackgroundColor ? UIColor(netHex: 0xF9FCFF) : UIColor(netHex: 0xffffff)
            titleLabel.text = title
            textLabel.textColor = UIColor(netHex: 0x007AFF, alpha: 0.7)
        }

        titleLabel.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.leading.equalToSuperview().offset(24)
        }

        textLabel.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.trailing.equalToSuperview().offset(-24)
            m.leading.equalTo(titleLabel.snp.trailing).offset(10)
        }
    }

    func set(text: String) {
        switch type {
        case .amount:
            textLabel.text = text
        case .fee:
            textLabel.text = text
        case .quota:
            textLabel.text = text + " UT"
        case .custom:
            textLabel.text = text
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
