//
//  GrinTxInfoTitleCell.swift
//  Pods
//
//  Created by haoshenyang on 2019/5/8.
//

import UIKit
import RxSwift
import RxCocoa

class GrinTxInfoTitleCell: UITableViewCell {

    let statusImageView = UIImageView()
    let lineImageView = UIImageView()
    let statusLabel = UILabel()
    let slateContainerView = UIView()
    let slateLabel = UILabel()
    let copyButton = UIButton()

    var copyAction: (() -> ())?


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.selectionStyle = .none

        contentView.addSubview(statusImageView)
        contentView.addSubview(lineImageView)
        contentView.addSubview(statusLabel)
        contentView.addSubview(slateContainerView)
        contentView.addSubview(slateLabel)
        contentView.addSubview(copyButton)


        statusLabel.font = UIFont.boldSystemFont(ofSize: 14)
        statusLabel.textColor = UIColor.init(netHex: 0x3e4a59)

        slateLabel.font = UIFont.systemFont(ofSize: 12)
        statusLabel.textColor = UIColor.init(netHex: 0x3e4a59)


        statusImageView.snp.makeConstraints { m in
            m.top.equalToSuperview()
            m.width.height.equalTo(20)
            m.left.equalToSuperview().offset(24)
        }

        statusLabel.snp.makeConstraints { (m) in
            m.left.equalTo(statusImageView.snp.right).offset(6)
            m.centerY.equalTo(statusImageView)
        }

        statusLabel.text = "已签收"

        slateContainerView.snp.makeConstraints { (m) in
            m.top.equalTo(statusLabel.snp.bottom).offset(8)
            m.left.equalTo(statusLabel)
            m.right.equalToSuperview().offset(-24)
            m.height.equalTo(24)
        }
        slateContainerView.backgroundColor = UIColor.init(netHex: 0xF3F5F9)
        slateContainerView.layer.cornerRadius = 2
        slateContainerView.layer.masksToBounds = true

        slateLabel.snp.makeConstraints { (m) in
            m.left.equalTo(slateContainerView).offset(4)
            m.right.equalTo(slateContainerView).offset(-35)
            m.centerY.equalTo(slateContainerView)
        }

        slateLabel.text = "2019/4/22 12:30:23"

        lineImageView.snp.makeConstraints { (m) in
            m.bottom.equalToSuperview()
            m.top.equalTo(statusImageView.snp.bottom)
            m.width.equalTo(1)
            m.centerX.equalTo(statusImageView)
        }

        statusImageView.image = R.image.grin_detail_gateway()
        lineImageView.image = R.image.grin_detail_line_blue()?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .tile)

        copyButton.snp.makeConstraints { (m) in
            m.centerY.equalTo(slateContainerView)
            m.width.height.equalTo(16)
            m.right.equalTo(slateContainerView).offset(-4)
        }

        copyButton.setImage(R.image.icon_button_paste_gray(), for: .normal)

        copyButton.rx.tap.bind { [weak self] _ in
            self?.copyAction?()
        }.disposed(by: rx.disposeBag)
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
