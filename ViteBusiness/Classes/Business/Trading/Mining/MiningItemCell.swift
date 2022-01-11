//
//  MiningItemCell.swift
//  ViteBusiness
//
//  Created by Stone on 2020/6/3.
//

import Foundation
import UIKit

struct MiningItemCellViewModel {
    let left: String
    let earnings: String
    let symbol: String
    let date: Int64

    init(left: String, earnings: String, symbol: String, date: Int64) {
        self.left = left
        self.earnings = earnings
        self.symbol = symbol
        self.date = date
    }
}

class MiningItemCell: BaseTableViewCell {
    static let cellHeight: CGFloat = 62
    
    let iconImageView = UIImageView(image: R.image.icon_mining_trading_item())

    let earningsTitleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
        $0.text = R.string.localizable.miningTradingPageHeaderTitle()
    }

    let earningsLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x24272B)
    }

    let feeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
    }

    let timeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)


        selectionStyle = .none

        contentView.addSubview(iconImageView)
        contentView.addSubview(earningsTitleLabel)
        contentView.addSubview(earningsLabel)
        contentView.addSubview(feeLabel)
        contentView.addSubview(timeLabel)

        let hLine = UIView().then {
            $0.backgroundColor = UIColor(netHex: 0xD3DFEF)
        }

        addSubview(hLine)

        iconImageView.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.left.equalToSuperview().offset(12)
        }
        
        earningsTitleLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(12)
            m.left.equalTo(iconImageView.snp.right).offset(6)
        }

        earningsLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(earningsTitleLabel)
            m.left.equalTo(earningsTitleLabel.snp.right).offset(5)
        }

        feeLabel.snp.makeConstraints { (m) in
            m.bottom.equalToSuperview().offset(-12)
            m.left.equalTo(iconImageView.snp.right).offset(6)
        }

        timeLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(feeLabel)
            m.right.equalToSuperview().offset(-12)
        }

        hLine.snp.makeConstraints { (m) in
            m.height.equalTo(CGFloat.singleLineWidth)
            m.bottom.equalToSuperview()
            m.left.right.equalToSuperview().inset(12)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(_ vm: MiningItemCellViewModel) {
        earningsLabel.text = "\(vm.earnings) \(vm.symbol)"
        feeLabel.text = vm.left
        timeLabel.text = Date(timeIntervalSince1970: TimeInterval(vm.date)).format()

    }
}
