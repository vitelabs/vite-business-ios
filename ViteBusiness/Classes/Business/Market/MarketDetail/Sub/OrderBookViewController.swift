//
//  OrderBookViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/11.
//

import UIKit

class OrderBookViewController: BaseViewController {

    let leftLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59)
    }

    let midLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59)
    }

    let rightLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59)
    }

    let leftStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 0
    }

    let rightStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 0
    }

    let leftViews: [LeftItemView] = (0..<15).map { _ in LeftItemView() }
    let rightViews: [RightItemView] = (0..<15).map { _ in RightItemView() }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(leftLabel)
        view.addSubview(midLabel)
        view.addSubview(rightLabel)
        view.addSubview(leftStackView)
        view.addSubview(rightStackView)

        leftLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(19)
            m.left.equalToSuperview().offset(24)
        }

        midLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(19)
            m.centerX.equalToSuperview()
        }

        rightLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(19)
            m.right.equalToSuperview().offset(-24)
        }

        leftStackView.snp.makeConstraints { (m) in
            m.top.equalTo(leftLabel.snp.bottom).offset(10)
            m.left.equalToSuperview().offset(24)
//            m.bottom.equalToSuperview().offset(-10)
        }

        rightStackView.snp.makeConstraints { (m) in
            m.top.equalTo(leftLabel.snp.bottom).offset(10)
            m.left.equalTo(leftStackView.snp.right)
            m.width.equalTo(leftStackView)
            m.right.equalToSuperview().offset(-24)
//            m.bottom.equalToSuperview().offset(-10)
        }

        leftViews.forEach {
            leftStackView.addArrangedSubview($0)
        }

        rightViews.forEach {
            rightStackView.addArrangedSubview($0)
        }

    }

    func bind(info: MarketInfo, depthList: MarketDepthList?) {
        leftLabel.text = R.string.localizable.marketDetailPageDepthVolTitle(info.statistic.quoteTokenSymbol)
        midLabel.text = R.string.localizable.marketDetailPageDepthPriceTitle(info.statistic.tradeTokenSymbol)
        rightLabel.text = R.string.localizable.marketDetailPageDepthVolTitle(info.statistic.quoteTokenSymbol)

        for (index, view) in leftViews.enumerated() {
            let depth = (index < (depthList?.asks.count ?? 0)) ? depthList?.asks[index] : nil
            view.bind(depth: depth)
        }

        for (index, view) in rightViews.enumerated() {
            let depth = (index < (depthList?.bids.count ?? 0)) ? depthList?.bids[index] : nil
            view.bind(depth: depth)
        }
    }
}

extension OrderBookViewController {
    class LeftItemView: UIView {

        let quantityLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = UIColor(netHex: 0x24272B)
        }

        let priceLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = UIColor(netHex: 0x00D764)
        }

        let percentView = UIView().then {
            $0.backgroundColor = UIColor(netHex: 0x00D764, alpha: 0.08)
        }

        init() {
            super.init(frame: .zero)

            backgroundColor = UIColor(netHex: 0x4B74FF, alpha: 0.05)

            addSubview(percentView)
            addSubview(quantityLabel)
            addSubview(priceLabel)

            quantityLabel.snp.makeConstraints { (m) in
                m.left.centerY.equalToSuperview()
            }

            priceLabel.snp.makeConstraints { (m) in
                m.right.centerY.equalToSuperview()
            }

            percentView.snp.makeConstraints { (m) in
                m.top.bottom.right.equalToSuperview()
                m.height.equalTo(24)
                m.width.equalToSuperview().multipliedBy(0.5)
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

    class RightItemView: UIView {

        let quantityLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = UIColor(netHex: 0x24272B)
        }

        let priceLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = UIColor(netHex: 0xE5494D)
        }

        let percentView = UIView().then {
            $0.backgroundColor = UIColor(netHex: 0xED5158, alpha: 0.08)
        }

        init() {
            super.init(frame: .zero)

            backgroundColor = UIColor(netHex: 0x4B74FF, alpha: 0.05)

            addSubview(percentView)
            addSubview(quantityLabel)
            addSubview(priceLabel)

            quantityLabel.snp.makeConstraints { (m) in
                m.right.centerY.equalToSuperview()
            }

            priceLabel.snp.makeConstraints { (m) in
                m.left.centerY.equalToSuperview()
            }

            percentView.snp.makeConstraints { (m) in
                m.top.bottom.left.equalToSuperview()
                m.height.equalTo(24)
                m.width.equalToSuperview().multipliedBy(0.5)
            }
        }

        func bind(depth: MarketDepthList.Depth?) {
            if let depth = depth {
                quantityLabel.text = depth.quantity
                priceLabel.text = depth.price

                percentView.snp.remakeConstraints { (m) in
                    m.top.bottom.left.equalToSuperview()
                    m.height.equalTo(24)
                    m.width.equalToSuperview().multipliedBy(depth.percent)
                }
            } else {
                quantityLabel.text = ""
                priceLabel.text = ""

                percentView.snp.remakeConstraints { (m) in
                    m.top.bottom.left.equalToSuperview()
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
