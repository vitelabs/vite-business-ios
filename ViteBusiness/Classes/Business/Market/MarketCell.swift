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
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()

    let quoteSymbolLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(netHex: 0x3e4a59, alpha: 0.3)
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    let miningImgView = MarketPairFlagView(feeType: .large)

    let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
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

    let persentBgView = UIView().then {
        $0.layer.cornerRadius = 2
    }

    let persentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .white
        label.textAlignment = .center
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
        contentView.addSubview(persentBgView)
        contentView.addSubview(persentLabel)

        tradeSymbolLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(contentView).offset(12)
            make.top.equalTo(contentView).offset(11)
        }

        quoteSymbolLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(tradeSymbolLabel.snp.right)
            make.centerY.equalTo(tradeSymbolLabel)
        }

        miningImgView.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(quoteSymbolLabel.snp.right).offset(4)
            make.centerY.equalTo(quoteSymbolLabel).offset(-3)
        }

        priceLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp.centerX).offset(LocalizationService.sharedInstance.currentLanguage == .chinese ? -23 : -33)
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
            make.left.equalTo(priceLabel)
            make.top.equalTo(timeLabel)
        }

        persentBgView.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-12)
            m.height.equalTo(26)
            m.width.equalTo(70)
            m.centerY.equalToSuperview()
        }

        persentLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(persentBgView).offset(5)
            make.right.equalTo(persentBgView).offset(-5)
            make.centerY.equalToSuperview()
        }

    }

    func bind(info: MarketInfo)  {
        tradeSymbolLabel.text = info.statistic.tradeTokenSymbol.components(separatedBy: "-").first
        let quoteTokenSymbol = (info.statistic.quoteTokenSymbol.components(separatedBy: "-").first ?? "")
        quoteSymbolLabel.text = "/" + quoteTokenSymbol
        miningImgView.bind(info)
        priceLabel.text = info.statistic.closePrice
        timeLabel.text = "24H"
        volumeLabel.text = String(format: "%.2f \(quoteTokenSymbol)", (Double(info.statistic.amount) ?? 0))
        rateLabel.text = info.rate

        persentLabel.text = info.persentString
        persentBgView.backgroundColor = info.persentColor
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


class SelectMarketPairCell: UITableViewCell {

    let tradeSymbolLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(netHex: 0x3e4a59)
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    let quoteSymbolLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(netHex: 0x3e4a59, alpha: 0.3)
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    let miningImgView = MarketPairFlagView(feeType: .small)

    let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()

    let persentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()

    let operatorNameLabel: UILabel = {
         let label = UILabel()
          label.textColor = UIColor.init(netHex: 0x3e4a59, alpha: 0.3)
          label.font = UIFont.systemFont(ofSize: 13)
          return label
    }()


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        
        contentView.addSubview(tradeSymbolLabel)
        contentView.addSubview(quoteSymbolLabel)
        contentView.addSubview(miningImgView)
        contentView.addSubview(priceLabel)
        contentView.addSubview(persentLabel)
        contentView.addSubview(operatorNameLabel)

        tradeSymbolLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(contentView).offset(12)
            make.centerY.equalTo(contentView)
        }

        quoteSymbolLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(tradeSymbolLabel.snp.right)
            make.centerY.equalTo(tradeSymbolLabel)
        }
        
        miningImgView.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(quoteSymbolLabel.snp.right).offset(1)
            make.bottom.equalTo(quoteSymbolLabel).offset(-2)
        }

        priceLabel.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(contentView).offset(-165.0 * (kScreenW )/(375.0 ))
            make.centerY.equalTo(tradeSymbolLabel)
        }

        operatorNameLabel.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(contentView).offset(-12)
            make.centerY.equalTo(contentView)
            make.left.greaterThanOrEqualTo(persentLabel.snp.right).offset(2)
        }

        persentLabel.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(contentView).offset(-83.0 * (kScreenW )/(375.0 ))
            make.centerY.equalTo(contentView)
            make.left.greaterThanOrEqualTo(priceLabel.snp.right)
        }

    }

    func bind(info: MarketInfo)  {
        tradeSymbolLabel.text = info.statistic.tradeTokenSymbol.components(separatedBy: "-").first
        let quoteTokenSymbol = (info.statistic.quoteTokenSymbol.components(separatedBy: "-").first ?? "")
        quoteSymbolLabel.text = "/" + quoteTokenSymbol
        priceLabel.text = info.statistic.closePrice
        operatorNameLabel.text = info.operatorName
        let priceChangePercent = Double(info.statistic.priceChangePercent)! * 100
        var persentString = priceChangePercent >= 0.0 ? "+" : "-"
        persentString = persentString + String(format: "%.2f", abs(priceChangePercent)) + "%"
        persentLabel.text = persentString
        persentLabel.textColor = priceChangePercent >= 0.0 ? UIColor.init(netHex: 0x01D764) : UIColor.init(netHex: 0xE5494D)
        
        miningImgView.bind(info)
        
        if info.miningMultiples.isEmpty {
            miningImgView.snp.remakeConstraints { (make) -> Void in
                make.left.equalTo(quoteSymbolLabel.snp.right).offset(4)
                make.bottom.equalTo(quoteSymbolLabel).offset(-2)
            }
        } else {
            miningImgView.snp.remakeConstraints { (make) -> Void in
                make.left.equalTo(quoteSymbolLabel.snp.right).offset(1)
                make.bottom.equalTo(quoteSymbolLabel).offset(-2)
            }
        }
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
