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

    let headerCell = HeaderCell()

    var depthList: MarketDepthList?
    func bind(info: MarketInfo, depthList: MarketDepthList?) {
        headerCell.leftLabel.text = R.string.localizable.marketDetailPageDepthVolTitle(info.statistic.quoteTokenSymbol)
        headerCell.midLabel.text = R.string.localizable.marketDetailPageDepthPriceTitle(info.statistic.tradeTokenSymbol)
        headerCell.rightLabel.text = R.string.localizable.marketDetailPageDepthVolTitle(info.statistic.quoteTokenSymbol)
        self.depthList = depthList
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
            cell.bind(list: depthList, index: indexPath.row)
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

        func bind(list: MarketDepthList?, index: Int) {
            if let list = list {
                let left = index < list.asks.count ? list.asks[index] : nil
                let right = index < list.bids.count ? list.bids[index] : nil
                leftView.bind(depth: left)
                rightView.bind(depth: right)
            } else {
                leftView.bind(depth: nil)
                rightView.bind(depth: nil)
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }


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
