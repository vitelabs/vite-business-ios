//
//  CurrencyCell.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/12.
//

import UIKit

class CurrencyCell: BaseTableViewCell {

    static func cellHeight() -> CGFloat {
        return 60
    }

    let nameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = UIColor(netHex: 0x24272B)
        $0.numberOfLines = 1
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(24)
            m.centerY.equalToSuperview()
        }

        let hLine = UIView().then {
            $0.backgroundColor = Colors.lineGray
        }

        contentView.addSubview(hLine)
        hLine.snp.makeConstraints { (m) in
            m.height.equalTo(CGFloat.singleLineWidth)
            m.left.equalTo(contentView).offset(24)
            m.right.equalTo(contentView).offset(-24)
            m.bottom.equalTo(contentView)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
