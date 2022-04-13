//
//  MiningStakingWithdrawalListCell.swift
//  ViteBusiness
//
//  Created by stone on 2022/2/15.
//

import Foundation
import UIKit

struct MiningStakingWithdrawalListCellViewModel {
    let height: String
    let time: String
    let amount: String
    let date: Date

    init(height: String, time: String, amount: String, date: Date) {
        self.height = height
        self.time = time
        self.amount = amount
        self.date = date
    }
}

class MiningStakingWithdrawalListCell: BaseTableViewCell {
    static let cellHeight: CGFloat = 68

    let heightdLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
        $0.text = R.string.localizable.miningTradingPageHeaderTitle()
    }
    
    let timeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
    }

    let amountLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x24272B)
    }

    let cancelButton = UIButton().then {
        $0.setBackgroundImage(UIImage.image(withColor: UIColor(netHex: 0x007AFF), cornerRadius: 11).resizable, for: .normal)
        $0.setBackgroundImage(UIImage.image(withColor: UIColor(netHex: 0x007AFF), cornerRadius: 11).highlighted.resizable, for: .highlighted)
        $0.setBackgroundImage(UIImage.image(withColor: UIColor(netHex: 0xBCC0CA), cornerRadius: 11).resizable, for: .disabled)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

    }
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)


        selectionStyle = .none

        contentView.addSubview(heightdLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(cancelButton)

        let hLine = UIView().then {
            $0.backgroundColor = UIColor(netHex: 0xD3DFEF)
        }

        addSubview(hLine)

        heightdLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(12)
            m.left.equalToSuperview().offset(12)
        }
        
        timeLabel.snp.makeConstraints { (m) in
            m.bottom.equalToSuperview().offset(-15)
            m.left.equalToSuperview().offset(12)
        }

        amountLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(heightdLabel)
            m.right.equalToSuperview().offset(-12)
        }

        cancelButton.snp.makeConstraints { (m) in
            m.centerY.equalTo(timeLabel)
            m.right.equalToSuperview().offset(-12)
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

    func bind(_ vm: MiningStakingWithdrawalListCellViewModel) {
        heightdLabel.text = R.string.localizable.miningStakingPageWithdrawPageHeight(vm.height)
        amountLabel.text = vm.amount
        timeLabel.text = R.string.localizable.miningStakingPageWithdrawPageWithdrawTime(vm.time)
    }
}

