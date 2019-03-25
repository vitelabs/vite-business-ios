//
//  WalletHomeBalanceInfoCell.swift
//  Vite
//
//  Created by Stone on 2018/9/7.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit

class WalletHomeBalanceInfoCell: BaseTableViewCell {

    static var cellHeight: CGFloat {
        return 86
    }

    fileprivate let colorView = UIImageView()
    fileprivate let iconImageView = TokenIconView()

    fileprivate let symbolLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.numberOfLines = 1
    }

    let coinFamilyLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.numberOfLines = 1
    }

    fileprivate let balanceLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x24272B)
        $0.numberOfLines = 1
        $0.textAlignment = .right
    }

    fileprivate let priceLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.numberOfLines = 1
        $0.textAlignment = .right
    }

    fileprivate let highlightedMaskView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 2
        $0.isUserInteractionEnabled = false
        $0.isHidden = true
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let whiteView = UIView().then {
            $0.backgroundColor = UIColor.white
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 2
        }

        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        let shadowView = UIView().then {
            $0.backgroundColor = nil
            $0.layer.shadowColor = UIColor(netHex: 0x000000, alpha: 0.1).cgColor
            $0.layer.shadowOpacity = 1
            $0.layer.shadowOffset = CGSize(width: 0, height: 5)
            $0.layer.shadowRadius = 20
        }

        shadowView.addSubview(whiteView)
        whiteView.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }

        contentView.addSubview(shadowView)

        whiteView.addSubview(iconImageView)
        whiteView.addSubview(symbolLabel)
        whiteView.addSubview(coinFamilyLabel)
        whiteView.addSubview(balanceLabel)
        whiteView.addSubview(priceLabel)
        whiteView.addSubview(colorView)
        whiteView.addSubview(highlightedMaskView)

        shadowView.snp.makeConstraints { (m) in
            m.top.equalTo(contentView)
            m.left.equalTo(contentView).offset(24)
            m.right.equalTo(contentView).offset(-24)
            m.height.equalTo(70)
            m.bottom.equalTo(contentView).offset(-16)
        }

        highlightedMaskView.snp.makeConstraints { (m) in
            m.edges.equalTo(shadowView)
        }

        colorView.snp.makeConstraints { (m) in
            m.top.left.bottom.equalTo(whiteView)
            m.width.equalTo(3)
        }

        iconImageView.setContentHuggingPriority(.required, for: .horizontal)
        iconImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        iconImageView.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.left.equalToSuperview().offset(16)
            m.size.equalTo(CGSize(width: 40, height: 40))
        }

        symbolLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(14)
            m.left.equalTo(iconImageView.snp.right).offset(13)
        }

        balanceLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(symbolLabel)
            m.right.equalToSuperview().offset(-14)
            m.left.equalTo(symbolLabel.snp.right).offset(10)
        }

        coinFamilyLabel.snp.makeConstraints { (m) in
            m.bottom.equalToSuperview().offset(-14)
            m.left.equalTo(symbolLabel)
        }

        priceLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(coinFamilyLabel)
            m.right.equalToSuperview().offset(-14)
            m.left.equalTo(coinFamilyLabel.snp.right).offset(10)
        }

        symbolLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        balanceLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        coinFamilyLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        priceLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        highlightedMaskView.isHidden = !highlighted
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        highlightedMaskView.isHidden = !selected
    }

    func bind(viewModel: WalletHomeBalanceInfoViewModel) {

        iconImageView.tokenInfo = viewModel.tokenInfo

        symbolLabel.text = viewModel.symbol
        coinFamilyLabel.textColor = viewModel.tokenInfo.mainColor
        coinFamilyLabel.text = viewModel.coinFamily
        balanceLabel.text = viewModel.balanceString
        priceLabel.text = viewModel.price
        colorView.backgroundColor = viewModel.tokenInfo.mainColor
    }
}
