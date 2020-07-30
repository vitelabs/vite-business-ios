//
//  ViteXTokenSelectorCell.swift
//  ViteBusiness
//
//  Created by Stone on 2020/7/30.
//

import Foundation

class ViteXTokenSelectorCell: BaseTableViewCell {

    static let cellHeight: CGFloat = 60

    fileprivate let iconImageView = TokenIconView()

    fileprivate let symbolLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.numberOfLines = 1
    }

    let coinFamilyLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        $0.numberOfLines = 1
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
    }

    fileprivate let balanceLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.numberOfLines = 1
        $0.textAlignment = .right
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(iconImageView)
        contentView.addSubview(symbolLabel)
        contentView.addSubview(coinFamilyLabel)
        contentView.addSubview(balanceLabel)

        iconImageView.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(24)
            m.centerY.equalToSuperview()
            m.size.equalTo(CGSize(width: 32, height: 32))
        }

        symbolLabel.snp.makeConstraints { (m) in
            m.left.equalTo(iconImageView.snp.right).offset(12)
            m.top.equalToSuperview().offset(12)
        }

        coinFamilyLabel.snp.makeConstraints { (m) in
            m.left.equalTo(symbolLabel)
            m.bottom.equalToSuperview().offset(-12)
        }

        balanceLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(symbolLabel)
            m.left.equalTo(symbolLabel.snp.right).offset(12)
            m.right.equalToSuperview().offset(-24)
        }

        iconImageView.setContentHuggingPriority(.required, for: .horizontal)
        iconImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        symbolLabel.setContentHuggingPriority(.required, for: .horizontal)
        symbolLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    func bind(vm: ViteXTokenSelectorViewModel) {
        iconImageView.tokenInfo = vm.tokenInfo
        symbolLabel.text = vm.tokenInfo.symbol
        coinFamilyLabel.text = vm.tokenInfo.coinFamily
        balanceLabel.text = vm.balanceString
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
