//
//  ExchangeHHistoryCell.swift
//  Action
//
//  Created by haoshenyang on 2019/8/6.
//

import UIKit
import SnapKit

class ExchangeHistoryCell: UITableViewCell {

    let leftView = UIView()
    let pairLabel = UILabel()
    let dateLabel = UILabel()
    let priceLabel = UILabel()
    let amountLabel = UILabel()
    let countLabel = UILabel()
    let symbleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(leftView)
        contentView.addSubview(pairLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(countLabel)
        contentView.addSubview(symbleLabel)


        leftView.backgroundColor = UIColor.init(netHex: 0x007AFF, alpha: 0.7)

        pairLabel.text = "ETH-000/VITE"
        pairLabel.font = UIFont.systemFont(ofSize: 14)
        pairLabel.textColor = UIColor.init(netHex: 0x77808A)

        priceLabel.font = UIFont.systemFont(ofSize: 14)
        priceLabel.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.7)

        countLabel.font = UIFont.systemFont(ofSize: 14)
        countLabel.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.7)

        amountLabel.font = UIFont.boldSystemFont(ofSize: 16)
        amountLabel.textColor = UIColor.init(netHex: 0x3E4A59)

        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.6)

        symbleLabel.font = UIFont.systemFont(ofSize: 14)
        symbleLabel.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.7)

        symbleLabel.text = "ETH"

        leftView.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(24)
            m.width.equalTo(2)
            m.height.equalTo(11)
            m.top.equalToSuperview().offset(18)
        }

        pairLabel.snp.makeConstraints { (m) in
            m.left.equalTo(leftView.snp.right).offset(5)
            m.centerY.equalTo(leftView)
        }

        dateLabel.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-24)
            m.centerY.equalTo(leftView)
        }

        priceLabel.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(24)
            m.top.equalTo(leftView.snp.bottom).offset(10)
        }

        countLabel.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(24)
            m.top.equalTo(priceLabel.snp.bottom).offset(10)
        }

        symbleLabel.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-24)
            m.centerY.equalTo(countLabel)
        }

        amountLabel.snp.makeConstraints { (m) in
            m.right.equalTo(symbleLabel.snp.left).offset(-5)
            m.centerY.equalTo(countLabel)
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
