//
//  DeFiLoanDurationItemView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/12/26.
//

import Foundation

class DeFiLoanDurationItemView: UIView {

    let titleLabel = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.text = R.string.localizable.defiItemLoanDurationTitle()
    }

    let preLabel = UILabel().then {
        $0.textColor = UIColor(netHex: 0x9AAABE)
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.text = R.string.localizable.defiItemDurationPre()
    }

    let sufLabel = UILabel().then {
        $0.textColor = UIColor(netHex: 0x9AAABE)
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.text = R.string.localizable.defiItemDurationSuf()
    }

    let textField = UITextField().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = Colors.cellTitleGray
        $0.autocorrectionType = .no
        $0.autocapitalizationType = .none
    }

    let rightLabel = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
    }

    let separatorLine = UIView().then {
        $0.backgroundColor = Colors.lineGray
    }

    let button = UIButton().then {
        $0.backgroundColor = .clear
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)
        addSubview(separatorLine)
        addSubview(rightLabel)
        addSubview(preLabel)
        addSubview(sufLabel)
        addSubview(button)
        addSubview(textField)

        titleLabel.snp.makeConstraints { (m) in
            m.top.left.right.equalToSuperview()
        }

        preLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(textField)
            m.left.equalToSuperview()
        }

        textField.snp.makeConstraints { (m) in
            m.top.equalTo(titleLabel.snp.bottom).offset(11)
            m.bottom.equalToSuperview().offset(-11)
            m.left.equalTo(preLabel.snp.right).offset(6)
            m.width.greaterThanOrEqualTo(40)
        }

        sufLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(textField)
            m.left.equalTo(textField.snp.right).offset(6)
        }

        rightLabel.snp.makeConstraints { (m) in
            m.right.equalToSuperview()
            m.centerY.equalTo(textField)
            m.left.greaterThanOrEqualTo(sufLabel.snp.right).offset(6)
        }
        textField.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        rightLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        rightLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        separatorLine.snp.makeConstraints { (m) in
            m.height.equalTo(CGFloat.singleLineWidth)
            m.bottom.left.right.equalToSuperview()
        }

        button.snp.makeConstraints { (m) in
            m.left.equalToSuperview()
            m.right.equalTo(rightLabel.snp.left)
            m.top.bottom.equalTo(textField)
        }

        button.rx.tap.bind { [weak self] in
            self?.textField.becomeFirstResponder()
        }.disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
