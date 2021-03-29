//
//  NodeSettingsListCell.swift
//  ViteBusiness
//
//  Created by stone on 2021/3/26.
//

import UIKit

class NodeSettingsListCell: BaseTableViewCell {

    static func cellHeight() -> CGFloat {
        return 44
    }

    let titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = UIColor(netHex: 0x24272B)
        $0.numberOfLines = 1
    }
    
    let valueLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = UIColor(netHex: 0x24272B, alpha: 0.8)
        $0.numberOfLines = 1
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(24)
            m.centerY.equalToSuperview()
        }
        
        contentView.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { (m) in
            m.left.equalTo(titleLabel.snp.right).offset(15)
            m.centerY.equalToSuperview()
        }
        
        let imageView = UIImageView(image: R.image.icon_right_white()?.tintColor(Colors.titleGray).resizable)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (m) in
            m.left.equalTo(valueLabel.snp.right).offset(10)
            m.centerY.equalToSuperview()
            m.right.equalToSuperview().offset(-24)
            m.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        valueLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
