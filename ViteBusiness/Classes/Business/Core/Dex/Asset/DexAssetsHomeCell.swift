//
//  DexAssetsHomeCell.swift
//  ViteBusiness
//
//  Created by Stone on 2020/8/26.
//

import Foundation

class DexAssetsHomeCell: BaseTableViewCell {

    fileprivate let iconImageView = TokenIconView()

    fileprivate let symbolLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x24272B)
        $0.numberOfLines = 1
    }

    fileprivate let balanceLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x24272B)
        $0.numberOfLines = 1
        $0.textAlignment = .right
    }

    let valuationLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.8)
        $0.numberOfLines = 1
        $0.textAlignment = .right
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)


        contentView.addSubview(iconImageView)
        contentView.addSubview(symbolLabel)
        contentView.addSubview(balanceLabel)
        contentView.addSubview(valuationLabel)

        iconImageView.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(24)
            m.centerY.equalToSuperview()
            m.size.equalTo(CGSize(width: 32, height: 32))
        }

        symbolLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        symbolLabel.setContentHuggingPriority(.required, for: .horizontal)
        symbolLabel.snp.makeConstraints { (m) in
            m.left.equalTo(iconImageView.snp.right).offset(12)
            m.centerY.equalToSuperview()
        }

        balanceLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(16)
            m.right.equalToSuperview().offset(-24)
            m.left.greaterThanOrEqualTo(symbolLabel.snp.right).offset(10)
        }

        valuationLabel.snp.makeConstraints { (m) in
            m.top.equalTo(balanceLabel.snp.bottom).offset(2)
            m.right.equalToSuperview().offset(-24)
            m.left.greaterThanOrEqualTo(symbolLabel.snp.right).offset(10)
        }

        
        let line = UIView().then {
            $0.backgroundColor = Colors.lineGray
        }

        contentView.addSubview(line)
        line.snp.makeConstraints { (m) in
            m.height.equalTo(CGFloat.singleLineWidth)
            m.left.equalTo(contentView).offset(24)
            m.right.equalTo(contentView).offset(-24)
            m.bottom.equalTo(contentView)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
