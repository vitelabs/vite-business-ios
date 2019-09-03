//
//  BifrostTaskCell.swift
//  ViteBusiness
//
//  Created by Stone on 2019/8/20.
//

import UIKit

class BifrostTaskCell: BaseTableViewCell {

    static var cellHeight: CGFloat {
        return 60
    }

    fileprivate let nameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x77808A)
    }

    fileprivate let timeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
    }

    fileprivate let statusLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)


        contentView.addSubview(nameLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(statusLabel)

        nameLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(11)
            m.left.equalToSuperview().offset(24)
        }

        timeLabel.snp.makeConstraints { (m) in
            m.bottom.equalToSuperview().offset(-9)
            m.left.equalToSuperview().offset(24)
        }

        statusLabel.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.right.equalToSuperview().offset(-24)
        }

        let line = UIView().then {
            $0.backgroundColor = Colors.lineGray
        }

        contentView.addSubview(line)
        line.snp.makeConstraints { (m) in
            m.height.equalTo(CGFloat.singleLineWidth)
            m.left.equalTo(contentView).offset(24)
            m.right.equalTo(contentView).offset(-24)
            m.bottom.equalTo(contentView)
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(task: BifrostViteSendTxTask) {
        nameLabel.text = task.info.title
        timeLabel.text = task.timestamp.format("yyyy.MM.dd HH:mm:ss")
        statusLabel.text = task.statusDescription
    }
}
