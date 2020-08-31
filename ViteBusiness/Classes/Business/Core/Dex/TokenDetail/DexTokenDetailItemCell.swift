//
//  DexTokenDetailItemCell.swift
//  ViteBusiness
//
//  Created by Stone on 2020/8/28.
//

import Foundation
import ViteWallet

class DexTokenDetailItemCell: BaseTableViewCell {

    static let cellHeight: CGFloat = 68

    fileprivate let typeImageView = UIImageView()

    fileprivate let typeNameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x77808A)
    }

    fileprivate let timeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
    }

    fileprivate let balanceLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x77808A)
        $0.textAlignment = .right
    }

    fileprivate let symbolLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)


        contentView.addSubview(typeImageView)
        contentView.addSubview(typeNameLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(balanceLabel)
        contentView.addSubview(symbolLabel)

        typeImageView.setContentHuggingPriority(.required, for: .horizontal)
        typeImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        typeImageView.snp.makeConstraints { (m) in
            m.top.equalTo(contentView).offset(17)
            m.left.equalTo(contentView).offset(24)
            m.size.equalTo(CGSize(width: 14, height: 14))
        }

        typeNameLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(typeImageView)
            m.left.equalTo(typeImageView.snp.right).offset(8)
        }

        symbolLabel.setContentHuggingPriority(.required, for: .horizontal)
        symbolLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        symbolLabel.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.right.equalToSuperview().offset(-24)
        }

        balanceLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(symbolLabel)
            m.right.equalTo(symbolLabel.snp.left).offset(-8)
            m.left.equalTo(typeNameLabel.snp.right).offset(10)
        }

        timeLabel.snp.makeConstraints { (m) in
            m.bottom.equalToSuperview().offset(-8)
            m.left.equalToSuperview().offset(24)
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

    func bind(dexDepositWithdraw: DexDepositWithdraw) {
        switch dexDepositWithdraw.type {
        case .deposit:
            typeImageView.image = R.image.icon_dex_transfer_in()
            typeNameLabel.text = R.string.localizable.dexTokenDetailPageCellIn()
            balanceLabel.text = "+" + dexDepositWithdraw.amountString
        case .withdraw:
            typeImageView.image = R.image.icon_dex_transfer_out()
            typeNameLabel.text = R.string.localizable.dexTokenDetailPageCellOut()
            balanceLabel.text = "-" + dexDepositWithdraw.amountString
        }

        timeLabel.text = Date(timeIntervalSince1970: TimeInterval(dexDepositWithdraw.time)).format()
        symbolLabel.text = dexDepositWithdraw.symbol
    }

    func bind(accountBlock: AccountBlock) {
        if accountBlock.transactionType == .receive {
            typeImageView.image = R.image.icon_dex_transfer_in()
            typeNameLabel.text = R.string.localizable.dexTokenDetailPageCellIn()
            balanceLabel.text = "+" + (accountBlock.amount ?? Amount(0)).amountFullWithGroupSeparator(decimals: accountBlock.token!.decimals)
        } else {
            typeImageView.image = R.image.icon_dex_transfer_out()
            typeNameLabel.text = R.string.localizable.dexTokenDetailPageCellOut()
            balanceLabel.text = "-" + (accountBlock.amount ?? Amount(0)).amountFullWithGroupSeparator(decimals: accountBlock.token!.decimals)
        }
        timeLabel.text = accountBlock.timeString
        symbolLabel.text = accountBlock.token?.uniqueSymbol
    }
}
