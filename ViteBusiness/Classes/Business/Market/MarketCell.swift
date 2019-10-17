//
//  MarketCell.swift
//  Action
//
//  Created by haoshenyang on 2019/10/15.
//

import UIKit

class MarketPageCell: UITableViewCell {

    let tradeSymbolLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()

    let quoteSymbolLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(netHex: 0x3e4a59, alpha: 0.3)
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()

    let miningImgView: UIImageView = {
        let miningImgView = UIImageView()
        miningImgView.backgroundColor = .clear
        miningImgView.image = R.image.market_mining()
        return miningImgView
    }()

    let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()

    let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(netHex: 0x3e4a59, alpha: 0.6)
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()

    let volumeLabel: UILabel = {
         let label = UILabel()
           label.textColor = UIColor.init(netHex: 0x3e4a59)
           label.font = UIFont.systemFont(ofSize: 12)
           return label
    }()

    let rateLabel: UILabel = {
         let label = UILabel()
          label.textColor = UIColor.init(netHex: 0x3e4a59)
          label.font = UIFont.systemFont(ofSize: 12)
          return label
    }()

    let persentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(tradeSymbolLabel)
        contentView.addSubview(quoteSymbolLabel)
        contentView.addSubview(miningImgView)
        contentView.addSubview(priceLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(volumeLabel)
        contentView.addSubview(rateLabel)
        contentView.addSubview(persentLabel)

        tradeSymbolLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(contentView).offset(24)
            make.top.equalTo(contentView).offset(11)
        }

        quoteSymbolLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(tradeSymbolLabel.snp.right).offset(2)
            make.centerY.equalTo(tradeSymbolLabel)
        }

        miningImgView.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(quoteSymbolLabel.snp.right).offset(5)
            make.centerY.equalTo(quoteSymbolLabel)
            make.width.height.equalTo(14)
        }

        priceLabel.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(contentView).offset(-(kScreenW - 48)*0.33)
            make.top.equalTo(contentView).offset(11)
        }

        timeLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(tradeSymbolLabel)
            make.top.equalTo(tradeSymbolLabel.snp.bottom).offset(10)
        }

        volumeLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(timeLabel.snp.right).offset(2)
            make.top.equalTo(timeLabel)
        }

        rateLabel.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(priceLabel)
            make.top.equalTo(timeLabel)
        }

        persentLabel.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(contentView).offset(-24)
            make.centerY.equalTo(contentView)
        }

    }

    func bind(info: MarketInfo)  {
        tradeSymbolLabel.text = info.statistic.tradeTokenSymbol.components(separatedBy: "-").first
        let quoteTokenSymbol = (info.statistic.quoteTokenSymbol.components(separatedBy: "-").first ?? "")
        quoteSymbolLabel.text = "/" + quoteTokenSymbol
        miningImgView.isHidden = !info.mining
        priceLabel.text = info.statistic.closePrice
        timeLabel.text = "24H"
        volumeLabel.text = String(format: "%.2f \(quoteTokenSymbol)", (Double(info.statistic.amount ?? "0") ?? 0))
        rateLabel.text = info.rate
        let priceChangePercent = Double(info.statistic.priceChangePercent)! * 100
        var persentString = priceChangePercent >= 0.0 ? "+" : "-"
        persentString = persentString + String(format: "%.2f", abs(priceChangePercent)) + "%"
        persentLabel.text = persentString
        persentLabel.textColor = priceChangePercent >= 0.0 ? UIColor.init(netHex: 0x01D764) : UIColor.init(netHex: 0xE5494D)
    }

    required init?(coder: NSCoder) {
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
