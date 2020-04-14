//
//  OrderBookViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/11.
//

import UIKit

class OrderBookViewController: BaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.snp.remakeConstraints { (m) in
            m.top.equalTo(view).offset(38)
            m.left.right.bottom.equalToSuperview()
        }

        glt_scrollView = tableView
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.contentInsetAdjustmentBehavior = .never
    }

    private func calcIsMining(max: Double?, peerPriceString: String?, currectString: String?) -> Bool {
        guard let max = max,
            let peerPriceString = peerPriceString,
            let peerPrice = Double(peerPriceString),
            let currectString = currectString,
            let currect = Double(currectString) else {
                return false
        }
        return abs(currect - peerPrice) / peerPrice < max
    }

    let headerCell = HeaderCell()

    var info: MarketInfo?
    var depthList: MarketDepthList?
    var buyIsMiningArray: [Bool] = []
    var sellIsMiningArray: [Bool] = []

    var buyIsLastMiningArray: [Bool] = []
    var sellIsLastMiningArray: [Bool] = []


    func bind(info: MarketInfo, depthList: MarketDepthList?) {
        self.info = info
        self.depthList = depthList

        buyIsMiningArray = depthList?.bids.map {
            calcIsMining(max: self.info?.buyRangeMax, peerPriceString: depthList?.asks.first?.price, currectString: $0.price)
        } ?? []

        sellIsMiningArray = depthList?.asks.map {
            calcIsMining(max: self.info?.sellRangeMax, peerPriceString: depthList?.bids.first?.price, currectString: $0.price)
        } ?? []

        let count = max(depthList?.bids.count ?? 0, depthList?.asks.count ?? 0)

        Array(0..<(count - buyIsMiningArray.count)).forEach { _ in
            buyIsMiningArray.append(false)
        }

        Array(0..<(count - sellIsMiningArray.count)).forEach { _ in
            sellIsMiningArray.append(false)
        }

        buyIsLastMiningArray = []
        sellIsLastMiningArray = []

        for (index, isMining) in buyIsMiningArray.enumerated() {
            if index == buyIsMiningArray.count - 1 {
                buyIsLastMiningArray.append(false)
            } else {
                if isMining && !buyIsMiningArray[index + 1] {
                    buyIsLastMiningArray.append(true)
                } else {
                    buyIsLastMiningArray.append(false)
                }
            }
        }

        for (index, isMining) in sellIsMiningArray.enumerated() {
            if index == sellIsMiningArray.count - 1 {
                sellIsLastMiningArray.append(false)
            } else {
                if isMining && !sellIsMiningArray[index + 1] {
                    sellIsLastMiningArray.append(true)
                } else {
                    sellIsLastMiningArray.append(false)
                }
            }
        }

        headerCell.leftLabel.text = R.string.localizable.marketDetailPageDepthVolTitle(info.statistic.quoteTokenSymbol)
        headerCell.midLabel.text = R.string.localizable.marketDetailPageDepthPriceTitle(info.statistic.tradeTokenSymbol)
        headerCell.rightLabel.text = R.string.localizable.marketDetailPageDepthVolTitle(info.statistic.quoteTokenSymbol)

        tableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            if let depthList = depthList {
                return max(depthList.asks.count, depthList.bids.count)
            } else {
                return 0
            }
        }
    }






    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {




        if indexPath.section == 0 {
            return headerCell
        } else {
            let cell: ItemCell = tableView.dequeueReusableCell(for: indexPath)

            let index = indexPath.row
            let bids = depthList?.bids ?? []
            let asks = depthList?.asks ?? []

            let buy = index < bids.count ? bids[index] : nil
            let sell = index < asks.count ? asks[index] : nil


            cell.bind(buy: (depth: buy, isMining: buyIsMiningArray[index], isLastMining: buyIsLastMiningArray[index]),
                      sell: (depth: sell, isMining: sellIsMiningArray[index], isLastMining: sellIsLastMiningArray[index]))

            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 45 : 24
    }
}

extension OrderBookViewController {

    class HeaderCell: BaseTableViewCell {

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

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            selectionStyle = .none
            contentView.addSubview(leftLabel)
            contentView.addSubview(midLabel)
            contentView.addSubview(rightLabel)

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
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class ItemCell: BaseTableViewCell {

        let leftView = LeftItemView()
        let rightView = RightItemView()


        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            selectionStyle = .none
            contentView.addSubview(leftView)
            contentView.addSubview(rightView)

            leftView.snp.makeConstraints { (m) in
                m.top.bottom.equalToSuperview()
                m.left.equalToSuperview().offset(24)
            }

            rightView.snp.makeConstraints { (m) in
                m.top.bottom.equalToSuperview()
                m.left.equalTo(leftView.snp.right)
                m.width.equalTo(leftView)
                m.right.equalToSuperview().offset(-24)
            }
        }

        func bind(buy: (depth: MarketDepthList.Depth?, isMining: Bool, isLastMining: Bool),
                  sell:  (depth: MarketDepthList.Depth?, isMining: Bool, isLastMining: Bool)) {
            leftView.bind(depth: buy.depth, isMining: buy.isMining, isLastMining: buy.isLastMining)
            rightView.bind(depth: sell.depth, isMining: sell.isMining, isLastMining: sell.isLastMining)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }


    class LeftItemView: UIView {

        let lineImg = UIImageView(image: R.image.dotted_line()?.tintColor(UIColor(netHex: 0x3E4A59, alpha: 0.3)).resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .tile))

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
            addSubview(lineImg)

            lineImg.snp.makeConstraints { (m) in
                m.bottom.left.right.equalToSuperview()
            }

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

        func bind(depth: MarketDepthList.Depth?, isMining: Bool, isLastMining: Bool) {

            backgroundColor = isMining ? UIColor(netHex: 0x4B74FF, alpha: 0.05) : UIColor.white
            lineImg.isHidden = !isLastMining

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

        let lineImg = UIImageView(image: R.image.dotted_line()?.tintColor(UIColor(netHex: 0x3E4A59, alpha: 0.3)).resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .tile))

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
            addSubview(lineImg)

            lineImg.snp.makeConstraints { (m) in
                m.bottom.left.right.equalToSuperview()
            }

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

        func bind(depth: MarketDepthList.Depth?, isMining: Bool, isLastMining: Bool) {

            backgroundColor = isMining ? UIColor(netHex: 0x4B74FF, alpha: 0.05) : UIColor.white
            lineImg.isHidden = !isLastMining

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
