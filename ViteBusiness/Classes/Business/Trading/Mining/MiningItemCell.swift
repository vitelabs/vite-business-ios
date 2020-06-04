//
//  MiningItemCell.swift
//  ViteBusiness
//
//  Created by Stone on 2020/6/3.
//

import Foundation

struct MiningItemCellViewModel {
    let left: String
    let earnings: String
    let symbol: String
    let date: Int64

    init(left: String, earnings: String, symbol: String, date: Int64) {
        self.left = left
        self.earnings = earnings
        self.symbol = symbol
        self.date = date
    }
}

class MiningItemCell: BaseTableViewCell {
    static let cellHeight: CGFloat = 70

    let feeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
    }

    let earningsLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x24272B)
    }

    let symbolLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
    }

    let timeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)


        selectionStyle = .none

        contentView.addSubview(feeLabel)
        contentView.addSubview(earningsLabel)
        contentView.addSubview(symbolLabel)
        contentView.addSubview(timeLabel)

        let hLine = UIView().then {
            $0.backgroundColor = UIColor(netHex: 0xD3DFEF)
        }

        addSubview(hLine)

        feeLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(12)
            m.left.equalToSuperview().offset(12)
        }

        earningsLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(feeLabel)
        }

        symbolLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(feeLabel)
            m.left.equalTo(earningsLabel.snp.right).offset(6)
            m.right.equalToSuperview().offset(-12)
        }

        timeLabel.snp.makeConstraints { (m) in
            m.bottom.equalToSuperview().offset(-12)
            m.left.equalToSuperview().offset(12)
        }

        hLine.snp.makeConstraints { (m) in
            m.height.equalTo(CGFloat.singleLineWidth)
            m.bottom.equalToSuperview()
            m.left.right.equalToSuperview().inset(12)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(_ vm: MiningItemCellViewModel) {
        feeLabel.text = vm.left
        earningsLabel.text = vm.earnings
        symbolLabel.text = vm.symbol
        timeLabel.text = Date(timeIntervalSince1970: TimeInterval(vm.date)).format()

    }
}
