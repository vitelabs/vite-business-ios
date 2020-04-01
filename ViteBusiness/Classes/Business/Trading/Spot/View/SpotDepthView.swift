//
//  SpotDepthView.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/30.
//

import Foundation

class SpotDepthView: UIView {

    static let height: CGFloat = 322

    let leftLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.3)
        $0.text = R.string.localizable.spotPageDepthPrice()
    }

    let rightLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.3)
        $0.text = R.string.localizable.spotPageDepthVol()
    }

    let sellItemViews = (0..<5).map { _ in ItemView(isBuy: false) }

    let openLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = UIColor(netHex: 0x24272B)
        $0.text = "--"
    }

    let priceLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "≈--"
    }

    let buyItemViews = (0..<5).map { _ in ItemView(isBuy: true) }

    override init(frame: CGRect) {
        super.init(frame: frame)


        addSubview(leftLabel)
        addSubview(rightLabel)

        sellItemViews.forEach {
            addSubview($0)
        }

        addSubview(openLabel)
        addSubview(priceLabel)

        buyItemViews.forEach {
            addSubview($0)
        }

        leftLabel.snp.makeConstraints { (m) in
            m.top.left.equalToSuperview()
        }

        rightLabel.snp.makeConstraints { (m) in
            m.top.right.equalToSuperview()
        }

        for (index, view) in sellItemViews.enumerated() {
            view.snp.makeConstraints { (m) in
                m.left.right.equalToSuperview()
                if index == 0 {
                    m.top.equalToSuperview().offset(20)
                } else {
                    m.top.equalTo(sellItemViews[index - 1].snp.bottom)
                }
            }
        }

        openLabel.snp.makeConstraints { (m) in
            m.top.equalTo(sellItemViews.last!.snp.bottom).offset(12)
            m.right.equalToSuperview()
        }

        priceLabel.snp.makeConstraints { (m) in
            m.top.equalTo(openLabel.snp.bottom).offset(4)
            m.right.equalToSuperview()
        }

        for (index, view) in buyItemViews.enumerated() {
            view.snp.makeConstraints { (m) in
                m.left.right.equalToSuperview()
                if index == 0 {
                    m.top.equalTo(sellItemViews.last!.snp.bottom).offset(62)
                } else {
                    m.top.equalTo(buyItemViews[index - 1].snp.bottom)
                }

                if index == buyItemViews.count - 1 {
                    m.bottom.equalToSuperview()
                }
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SpotDepthView {

    class ItemView: UIView {

        let priceLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)

        }

        let quantityLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = UIColor(netHex: 0x5E6875)
        }

        let percentView = UIView()

        init(isBuy: Bool) {
            super.init(frame: .zero)

            addSubview(percentView)
            addSubview(priceLabel)
            addSubview(quantityLabel)

            quantityLabel.snp.makeConstraints { (m) in
                m.right.centerY.equalToSuperview()
            }

            priceLabel.snp.makeConstraints { (m) in
                m.left.centerY.equalToSuperview()
            }

            percentView.snp.makeConstraints { (m) in
                m.top.bottom.right.equalToSuperview()
                m.height.equalTo(24)
                m.width.equalToSuperview().multipliedBy(0.5)
            }

            if isBuy {
                priceLabel.textColor = UIColor(netHex: 0x00D764)
                percentView.backgroundColor = UIColor(netHex: 0x01D764, alpha: 0.1)
            } else {
                priceLabel.textColor = UIColor(netHex: 0xE5494D)
                percentView.backgroundColor = UIColor(netHex: 0xE5494D, alpha: 0.1)
            }

        }

        func bind(depth: MarketDepthList.Depth?) {
            if let depth = depth {
                quantityLabel.text = depth.quantity
                priceLabel.text = depth.price

                percentView.snp.remakeConstraints { (m) in
                    m.top.bottom.right.equalToSuperview()
                    m.height.equalTo(24)
                    m.width.equalToSuperview().multipliedBy(depth.percent)
                }
            } else {
                quantityLabel.text = ""
                priceLabel.text = ""

                percentView.snp.remakeConstraints { (m) in
                    m.top.bottom.right.equalToSuperview()
                    m.height.equalTo(24)
                    m.width.equalToSuperview().multipliedBy(0)
                }
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
