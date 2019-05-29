//
//  GrinTxInfoCell.swift
//  Pods
//
//  Created by haoshenyang on 2019/5/8.
//

import UIKit

class GrinTxInfoCell: UITableViewCell {

    let statusImageView = UIImageView()
    let lineImageView = UIImageView()
    let statusLabel = UILabel()
    let timeLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.selectionStyle = .none
        
        contentView.addSubview(statusImageView)
        contentView.addSubview(lineImageView)
        contentView.addSubview(statusLabel)
        contentView.addSubview(timeLabel)

        statusLabel.font = UIFont.boldSystemFont(ofSize: 12)
        statusLabel.textColor = UIColor.init(netHex: 0x3e4a59,alpha: 0.7)

        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = UIColor.init(netHex: 0x3e4a59,alpha: 0.5)


        statusImageView.snp.makeConstraints { m in
            m.top.equalToSuperview()
            m.width.height.equalTo(14)
            m.left.equalToSuperview().offset(27)
        }

        statusLabel.snp.makeConstraints { (m) in
            m.left.equalTo(statusImageView.snp.right).offset(9)
            m.centerY.equalTo(statusImageView)
        }


        timeLabel.snp.makeConstraints { (m) in
            m.left.equalTo(statusLabel)
            m.top.equalTo(statusLabel.snp.bottom).offset(3)
        }


        lineImageView.snp.makeConstraints { (m) in
            m.bottom.equalToSuperview()
            m.top.equalTo(statusImageView.snp.bottom)
            m.width.equalTo(2)
            m.centerX.equalTo(statusImageView)
        }

        statusImageView.image = R.image.grin_detail_confirmed()

        lineImageView.image = R.image.grin_detail_line_blue()?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .tile)


    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
