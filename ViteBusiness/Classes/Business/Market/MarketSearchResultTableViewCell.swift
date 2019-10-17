//
//  MarketSearchResultTableViewCell.swift
//  Action
//
//  Created by haoshenyang on 2019/10/16.
//

import UIKit

class MarketSearchResultTableViewCell: UITableViewCell {

    let tradeSymbolLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    let quoteSymbolLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(netHex: 0x3e4a59, alpha: 0.3)
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()

    let favouriteButton: UIButton = {
        let button = UIButton()
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
       super.init(style: style, reuseIdentifier: reuseIdentifier)

       contentView.addSubview(tradeSymbolLabel)
       contentView.addSubview(quoteSymbolLabel)
       contentView.addSubview(favouriteButton)

       tradeSymbolLabel.snp.makeConstraints { (make) -> Void in
           make.left.equalTo(contentView).offset(24)
           make.centerY.equalTo(contentView)
       }

       quoteSymbolLabel.snp.makeConstraints { (make) -> Void in
           make.left.equalTo(tradeSymbolLabel.snp.right).offset(2)
           make.centerY.equalTo(tradeSymbolLabel)
       }

        favouriteButton.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(contentView.snp.right).offset(-24)
            make.centerY.equalTo(tradeSymbolLabel)
            make.width.height.equalTo(24)
        }
    }

    func bind(_ metalInfo: (MarketInfo, Bool))  {
        let (info, favourite) = metalInfo
        tradeSymbolLabel.text = info.statistic.tradeTokenSymbol.components(separatedBy: "-").first
       let quoteTokenSymbol = (info.statistic.quoteTokenSymbol.components(separatedBy: "-").first ?? "")
       quoteSymbolLabel.text = "/" + quoteTokenSymbol

        if favourite {
            favouriteButton.setBackgroundImage(R.image.market_star_yellow(), for: .normal)
        } else {
            favouriteButton.setBackgroundImage(R.image.market_star_gray(), for: .normal)
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
