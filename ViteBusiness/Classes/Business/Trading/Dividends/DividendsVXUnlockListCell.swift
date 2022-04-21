//
//  DividendsVXUnlockListCell.swift
//  ViteBusiness
//
//  Created by stone on 2022/2/15.
//

import Foundation
import UIKit

struct DividendsVXUnlockListCellViewModel {
    let time: String
    let amount: String

    init(time: String, amount: String) {
        self.time = time
        self.amount = amount
    }
}

class DividendsVXUnlockListCell: BaseTableViewCell {
    static let cellHeight: CGFloat = 40
    
    let timeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
    }

    let amountLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x3E4A59)
    }
    
    var vm: DividendsVXUnlockListCellViewModel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)


        selectionStyle = .none

        contentView.addSubview(timeLabel)
        contentView.addSubview(amountLabel)

        let hLine = UIView().then {
            $0.backgroundColor = UIColor(netHex: 0xD3DFEF)
        }

        addSubview(hLine)
        
        timeLabel.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.left.equalToSuperview().offset(12)
        }

        amountLabel.snp.makeConstraints { (m) in
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

    func bind(_ vm: DividendsVXUnlockListCellViewModel) {
        self.vm = vm;
        amountLabel.text = vm.amount + " VX"
        timeLabel.text = vm.time
    }
}

