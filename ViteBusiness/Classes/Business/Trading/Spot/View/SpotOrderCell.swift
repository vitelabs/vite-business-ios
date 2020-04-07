//
//  SpotOrderCell.swift
//  ViteBusiness
//
//  Created by Stone on 2020/4/6.
//

import Foundation

class SpotOrderCell: BaseTableViewCell {

    static let cellHeight: CGFloat = 85

    let typeButton = UIButton().then {
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        $0.isUserInteractionEnabled = false
    }

    let tradeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x24272B)
    }

    let quoteLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.3)
    }

    let timeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.3)
    }

    let cancelButton = UIButton().then {
        $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)
        $0.setBackgroundImage(R.image.icon_spot_order_cancel_button_frame()?.resizable, for: .normal)
        $0.setBackgroundImage(R.image.icon_spot_order_cancel_button_frame()?.highlighted.resizable, for: .highlighted)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.setTitle(R.string.localizable.spotPageCellButtonCancelTitle(), for: .normal)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    }

    let volLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
    }

    let priceLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
    }

    let dealLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
    }

    let averageLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
    }


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)


        selectionStyle = .none

        contentView.addSubview(typeButton)
        contentView.addSubview(tradeLabel)
        contentView.addSubview(quoteLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(cancelButton)
        contentView.addSubview(volLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(dealLabel)
        contentView.addSubview(averageLabel)

        let vLine = UIView().then {
            $0.backgroundColor = UIColor(netHex: 0xffffff, alpha: 0.15)
        }

        addSubview(vLine)

        let hLine = UIView().then {
            $0.backgroundColor = UIColor(netHex: 0xffffff, alpha: 0.15)
        }

        addSubview(hLine)
        
        typeButton.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(16)
            m.left.equalToSuperview().offset(24)
        }

        tradeLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(typeButton)
            m.left.equalTo(typeButton.snp.right).offset(4)
        }

        quoteLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(typeButton)
            m.left.equalTo(tradeLabel.snp.right).offset(2)
        }

        vLine.snp.makeConstraints { (m) in
            m.width.equalTo(CGFloat.singleLineWidth)
            m.centerY.equalTo(typeButton)
            m.height.equalTo(12)
            m.left.equalTo(quoteLabel.snp.right).offset(6)
        }

        timeLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(typeButton)
            m.left.equalTo(vLine.snp.right).offset(6)
        }

        cancelButton.snp.makeConstraints { (m) in
            m.centerY.equalTo(typeButton)
            m.right.equalToSuperview().offset(-24)
        }

        volLabel.snp.makeConstraints { (m) in
            m.top.equalTo(typeButton.snp.bottom).offset(7)
            m.left.equalToSuperview().offset(24)
        }

        priceLabel.snp.makeConstraints { (m) in
            m.top.equalTo(typeButton.snp.bottom).offset(7)
            m.left.equalTo(contentView.snp.centerX)
        }

        dealLabel.snp.makeConstraints { (m) in
            m.top.equalTo(volLabel.snp.bottom).offset(6)
            m.left.equalToSuperview().offset(24)
        }

        averageLabel.snp.makeConstraints { (m) in
            m.top.equalTo(priceLabel.snp.bottom).offset(6)
            m.left.equalTo(contentView.snp.centerX)
        }

        hLine.snp.makeConstraints { (m) in
            m.height.equalTo(CGFloat.singleLineWidth)
            m.bottom.equalToSuperview()
            m.left.right.equalToSuperview().inset(24)
        }

        bind()
    }

    func bind() {
        let isBuy = true

        if isBuy {
            typeButton.setTitle(R.string.localizable.spotPageCellTypeBuy(), for: .normal)
            typeButton.setTitleColor(UIColor(netHex: 0x01D764), for: .normal)
            typeButton.backgroundColor = UIColor(netHex: 0x01D764, alpha: 0.1)
        } else {
            typeButton.setTitle(R.string.localizable.spotPageCellTypeSell(), for: .normal)
            typeButton.setTitleColor(UIColor(netHex: 0xE5494D), for: .normal)
            typeButton.backgroundColor = UIColor(netHex: 0xE5494D, alpha: 0.1)
        }

        tradeLabel.text = "BTC"
        quoteLabel.text = "/\("VITE")"
        timeLabel.text = "2020-10-10 10:20:30"

        volLabel.text = R.string.localizable.spotPageCellVol("ffff")
        priceLabel.text = R.string.localizable.spotPageCellPrice("ffff")
        dealLabel.text = R.string.localizable.spotPageCellDeal("ffff")
        averageLabel.text = R.string.localizable.spotPageCellAverage("ffff")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SpotOrderCell: ListCellable {

    func bind(_ item: MarketOrder) {
        let isBuy = true

        if isBuy {
            typeButton.setTitle(R.string.localizable.spotPageCellTypeBuy(), for: .normal)
            typeButton.setTitleColor(UIColor(netHex: 0x01D764), for: .normal)
            typeButton.backgroundColor = UIColor(netHex: 0x01D764, alpha: 0.1)
        } else {
            typeButton.setTitle(R.string.localizable.spotPageCellTypeSell(), for: .normal)
            typeButton.setTitleColor(UIColor(netHex: 0xE5494D), for: .normal)
            typeButton.backgroundColor = UIColor(netHex: 0xE5494D, alpha: 0.1)
        }

        tradeLabel.text = "BTC"
        quoteLabel.text = "/\("VITE")"
        timeLabel.text = "2020-10-10 10:20:30"

        volLabel.text = R.string.localizable.spotPageCellVol("ffff")
        priceLabel.text = R.string.localizable.spotPageCellPrice("ffff")
        dealLabel.text = R.string.localizable.spotPageCellDeal("ffff")
        averageLabel.text = R.string.localizable.spotPageCellAverage("ffff")
    }
}
