//
//  ExchangeHHistoryCell.swift
//  Action
//
//  Created by haoshenyang on 2019/8/6.
//

import UIKit
import SnapKit

class ExchangeHistoryCell: UITableViewCell {

    let leftView = UIImageView()

    let viteSymbleLabel = UILabel()
    let ethSymbleLabel = UILabel()

    let dateLabel = UILabel()
    let priceLabel = UILabel()
    let viteAmountLabel = UILabel()
    let ethAmountLabel = UILabel()


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(leftView)
        contentView.addSubview(viteSymbleLabel)
        contentView.addSubview(ethSymbleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(viteAmountLabel)
        contentView.addSubview(ethAmountLabel)


        ethSymbleLabel.text = "ETH-000"
        ethSymbleLabel.font = UIFont.systemFont(ofSize: 14)
        ethSymbleLabel.textColor = UIColor.init(netHex: 0x77808A)

        viteSymbleLabel.text = "VITE"
        viteSymbleLabel.font = UIFont.systemFont(ofSize: 14)
        viteSymbleLabel.textColor = UIColor.init(netHex: 0x77808A)

        priceLabel.font = UIFont.systemFont(ofSize: 14)
        priceLabel.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.7)

        viteAmountLabel.font = UIFont.boldSystemFont(ofSize: 14)
        viteAmountLabel.textColor = UIColor.init(netHex: 0x3E4A59)

        ethAmountLabel.font = UIFont.boldSystemFont(ofSize: 14)
        ethAmountLabel.textColor = UIColor.init(netHex: 0x3E4A59)

        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.6)

        leftView.image = R.image.exchange_txs()


        leftView.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(24)
            m.width.equalTo(16)
            m.height.equalTo(16)
            m.top.equalToSuperview().offset(25)
        }

        ethSymbleLabel.snp.makeConstraints { (m) in
            m.left.equalTo(leftView.snp.right).offset(8)
            m.bottom.equalTo(leftView.snp.top).offset(2)
        }

        viteSymbleLabel.snp.makeConstraints { (m) in
            m.left.equalTo(leftView.snp.right).offset(8)
            m.top.equalTo(leftView.snp.bottom).offset(-2)
        }

        ethAmountLabel.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-24)
            m.centerY.equalTo(ethSymbleLabel)
        }

        viteAmountLabel.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-24)
            m.centerY.equalTo(viteSymbleLabel)
        }

        dateLabel.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-24)
            m.bottom.equalToSuperview().offset(-9)
        }

        priceLabel.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(24)
            m.bottom.equalToSuperview().offset(-9)
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
