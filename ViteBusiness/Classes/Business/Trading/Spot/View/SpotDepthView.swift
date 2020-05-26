//
//  SpotDepthView.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/30.
//

import Foundation

class SpotDepthView: UIView {

    static let height: CGFloat = 322

    var priceClicked: (((price: String, vol: Double?, isBuy: Bool)) -> Void)?

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

    lazy var sellItemViews = (0..<5).map { _ in
        ItemView(isBuy: false) { [weak self] in
            if let _ = Double($0) {
                self?.priceClicked?((price: $0, vol: $1, isBuy: false))
            }
        }
    }

    let closeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = UIColor(netHex: 0x24272B)
        $0.text = "--"
    }

    let priceLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
        $0.text = "≈--"
    }

    lazy var buyItemViews = (0..<5).map { _ in
        ItemView(isBuy: true) { [weak self] in
            if let _ = Double($0) {
                self?.priceClicked?((price: $0, vol: $1, isBuy: true))
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)


        addSubview(leftLabel)
        addSubview(rightLabel)

        sellItemViews.forEach {
            addSubview($0)
        }

        addSubview(closeLabel)
        addSubview(priceLabel)

        buyItemViews.forEach {
            addSubview($0)
        }

        leftLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.equalToSuperview().offset(10)
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

        closeLabel.snp.makeConstraints { (m) in
            m.top.equalTo(sellItemViews.last!.snp.bottom).offset(12)
            m.right.equalToSuperview()
        }

        priceLabel.snp.makeConstraints { (m) in
            m.top.equalTo(closeLabel.snp.bottom).offset(4)
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

    func bind(marketInfo: MarketInfo?) {
        if let info = marketInfo {
            closeLabel.text = info.statistic.closePrice
            closeLabel.textColor = info.persentColor
            priceLabel.text = "≈" + MarketInfoService.shared.legalPrice(quoteTokenSymbol: info.statistic.quoteTokenSymbol, price: info.statistic.closePrice)
        } else {
            closeLabel.text = "--"
            priceLabel.text = "≈--"
        }
    }

    func bind(depthList: MarketDepthList?, myOrders: [MarketOrder]) {

        let asks = depthList?.asks
        let bids = depthList?.bids
        let (buyPriceList, sellPriceList) = myOrders.toPriceList()

        var sellDepth: [MarketDepthList.Depth?] = []
        var buyDepth: [MarketDepthList.Depth?] = []

        var sellVol: [Double?] = []
        var buyVol: [Double?] = []

        for (index, _) in sellItemViews.enumerated() {
            var depth: MarketDepthList.Depth? = nil
            if let asks = asks, sellItemViews.count - 1 - index < asks.count {
                depth = asks[sellItemViews.count - 1 - index]
            }
            sellDepth.append(depth)
        }

        for (index, _) in buyItemViews.enumerated() {
            var depth: MarketDepthList.Depth? = nil
            if let bids = bids, index < bids.count {
                depth = bids[index]
            }
            buyDepth.append(depth)
        }

        var buyVolSum: Double = 0
        buyDepth.forEach {
            if let depth = $0, let vol = Double(depth.quantity) {
                buyVolSum += vol
                buyVol.append(buyVolSum)
            } else {
                buyVol.append(nil)
            }
        }

        var sellVolSum: Double = 0
        sellDepth.reversed().forEach {
            if let depth = $0, let vol = Double(depth.quantity) {
                sellVolSum += vol
                sellVol.insert(sellVolSum, at: 0)
            } else {
                sellVol.insert(nil, at: 0)
            }
        }

        for (index, view) in sellItemViews.enumerated() {
            let isSelf = sellDepth[index] == nil ? false : sellPriceList.contains(sellDepth[index]!.price)
            view.bind(depth: sellDepth[index], vol: sellVol[index], isSelf: isSelf)
        }

        for (index, view) in buyItemViews.enumerated() {
            let isSelf = buyDepth[index] == nil ? false : buyPriceList.contains(buyDepth[index]!.price)
            view.bind(depth: buyDepth[index], vol: buyVol[index], isSelf: isSelf)
        }

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SpotDepthView {

    class ItemView: UIView {

        let flagImageView = UIImageView(image: R.image.icon_market_orderbook_self())

        let priceLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)

        }

        let quantityLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = UIColor(netHex: 0x5E6875)
        }

        let percentView = UIView()

        let button = UIButton().then {
            $0.backgroundColor = .clear
        }

        let guide = UILayoutGuide()

        init(isBuy: Bool, clicked: @escaping (String, Double?) -> Void) {
            super.init(frame: .zero)

            addSubview(flagImageView)
            addSubview(percentView)
            addSubview(priceLabel)
            addSubview(quantityLabel)
            addSubview(button)
            addLayoutGuide(guide)

            flagImageView.snp.makeConstraints { (m) in
                m.centerY.equalToSuperview()
                m.left.equalToSuperview()
            }

            guide.snp.makeConstraints { (m) in
                m.top.bottom.right.equalToSuperview()
                m.left.equalTo(flagImageView.snp.right).offset(2)
            }

            quantityLabel.snp.makeConstraints { (m) in
                m.right.centerY.equalToSuperview()
            }

            priceLabel.snp.makeConstraints { (m) in
                m.centerY.equalToSuperview()
                m.left.equalTo(guide)
            }

            percentView.snp.makeConstraints { (m) in
                m.top.bottom.right.equalTo(guide)
                m.height.equalTo(24)
                m.width.equalTo(guide).multipliedBy(0.5)
            }

            button.snp.makeConstraints { (m) in
                m.edges.equalToSuperview()
            }

            if isBuy {
                priceLabel.textColor = UIColor(netHex: 0x00D764)
                percentView.backgroundColor = UIColor(netHex: 0x01D764, alpha: 0.1)
            } else {
                priceLabel.textColor = UIColor(netHex: 0xE5494D)
                percentView.backgroundColor = UIColor(netHex: 0xE5494D, alpha: 0.1)
            }

            button.rx.tap.bind { [weak self] in
                guard let `self` = self else { return }
                clicked(self.priceLabel.text ?? "", self.vol)
            }.disposed(by: rx.disposeBag)
        }

        var vol: Double?
        func bind(depth: MarketDepthList.Depth?, vol: Double?, isSelf: Bool) {
            self.vol = vol
            if let depth = depth {
                flagImageView.isHidden = !isSelf
                quantityLabel.text = depth.quantity
                priceLabel.text = depth.price

                percentView.snp.remakeConstraints { (m) in
                    m.top.bottom.right.equalTo(guide)
                    m.height.equalTo(24)
                    m.width.equalTo(guide).multipliedBy(depth.percent)
                }
            } else {
                flagImageView.isHidden = true
                quantityLabel.text = ""
                priceLabel.text = ""

                percentView.snp.remakeConstraints { (m) in
                    m.top.bottom.right.equalTo(guide)
                    m.height.equalTo(24)
                    m.width.equalTo(guide).multipliedBy(0)
                }
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
