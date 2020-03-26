//
//  LastTradesViewController.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/11.
//

import UIKit

class LastTradesViewController: BaseTableViewController {

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

    var trades: [MarketTrade] = []
    func bind(info: MarketInfo, trades: [MarketTrade]) {
        self.trades = trades
        tableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return trades.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return headerCell
        } else {
            let cell: ItemCell = tableView.dequeueReusableCell(for: indexPath)
            cell.bind(trade: self.trades[indexPath.row])
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 49 : 32
    }
}

extension LastTradesViewController {

    class HeaderCell: BaseTableViewCell {
        let leftLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.3)
            $0.text = R.string.localizable.marketDetailPageTradeTimeTitle()
        }

        let midLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.3)
            $0.text = R.string.localizable.marketDetailPageTradePriceTitle()
        }

        let rightLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.3)
            $0.text = R.string.localizable.marketDetailPageTradeVolTitle()
        }

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            selectionStyle = .none
            contentView.addSubview(leftLabel)
            contentView.addSubview(midLabel)
            contentView.addSubview(rightLabel)

            let guide = UILayoutGuide()
            contentView.addLayoutGuide(guide)
            guide.snp.makeConstraints { (m) in
                m.edges.equalToSuperview().inset(24)
            }

            leftLabel.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(19)
                m.left.equalToSuperview().offset(24)
                m.width.equalTo(guide).multipliedBy(1.0 / 3.0)
            }

            midLabel.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(19)
                m.left.equalTo(leftLabel.snp.right)
                m.width.equalTo(guide).multipliedBy(1.0 / 3.0)
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

        let timeLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = UIColor(netHex: 0x24272B)
        }

        let priceLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        }

        let quantityLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = UIColor(netHex: 0x24272B)
        }

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            selectionStyle = .none
            contentView.addSubview(timeLabel)
            contentView.addSubview(priceLabel)
            contentView.addSubview(quantityLabel)

            let guide = UILayoutGuide()
            contentView.addLayoutGuide(guide)
            guide.snp.makeConstraints { (m) in
                m.edges.equalToSuperview().inset(24)
            }

            timeLabel.snp.makeConstraints { (m) in
                m.left.equalToSuperview().offset(24)
                m.top.bottom.equalToSuperview()
                m.height.equalTo(32)
                m.width.equalTo(guide).multipliedBy(1.0 / 3.0)
            }

            priceLabel.snp.makeConstraints { (m) in
                m.left.equalTo(timeLabel.snp.right)
                m.centerY.equalToSuperview()
                m.width.equalTo(guide).multipliedBy(1.0 / 3.0)
            }

            quantityLabel.snp.makeConstraints { (m) in
                m.right.equalToSuperview().offset(-24)
                m.centerY.equalToSuperview()
            }
        }

        func bind(trade: MarketTrade) {
            timeLabel.text = trade.date.format("HH:mm")
            priceLabel.text = trade.price
            quantityLabel.text = trade.quantity
            priceLabel.textColor = UIColor(netHex: trade.isBuy ? 0x00D764: 0xE5494D)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
