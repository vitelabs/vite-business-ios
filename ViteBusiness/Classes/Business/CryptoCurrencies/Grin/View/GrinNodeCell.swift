//
//  SelectGrinNodeCell.swift
//  Action
//
//  Created by haoshenyang on 2019/5/16.
//

import UIKit

class SelectGrinNodeCell: UITableViewCell {

    let statusImageView = UIImageView()
    let addressLabel = UILabel()
    let seperator = UIView()
    let editButton = UIButton()

    var editNodeAction: (() -> ())?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.selectionStyle = .none

        self.contentView.addSubview(statusImageView)
        self.contentView.addSubview(addressLabel)
        self.contentView.addSubview(seperator)
        self.contentView.addSubview(editButton)

        addressLabel.numberOfLines = 2
        addressLabel.font = UIFont.systemFont(ofSize: 14)
        addressLabel.textColor = UIColor.init(netHex: 0x24272b)
        statusImageView.image = R.image.grin_node_unselected()

        editButton.setImage(R.image.grin_node_edit(), for: .normal)

        statusImageView.snp.makeConstraints { (m) in
            m.width.height.equalTo(20)
            m.centerY.equalToSuperview()
            m.left.equalToSuperview().offset(24)
        }

        addressLabel.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.left.equalToSuperview().offset(58)
            m.right.equalToSuperview().offset(-71)
        }

        seperator.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-58)
            m.width.equalTo(2)
            m.top.equalToSuperview().offset(19)
            m.bottom.equalToSuperview().offset(-14)
        }

        editButton.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-24)
            m.width.height.equalTo(16)
            m.centerY.equalToSuperview()
        }

        editButton.rx.tap.bind { [weak self] _ in
            self?.editNodeAction?()
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

class ViteGrinNodeCell: SelectGrinNodeCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.seperator.removeFromSuperview()
        self.editButton.removeFromSuperview()
        statusImageView.image = R.image.grin_node_selected()


        let tagBackgroundView = UIView()
        tagBackgroundView.backgroundColor = UIColor.init(netHex: 0xDFEEFF)
        contentView.addSubview(tagBackgroundView)
        tagBackgroundView.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.right.equalToSuperview().offset(-24)
            m.width.equalTo(36)
            m.height.equalTo(22)
        }

        let tagLabel = UILabel()
        tagLabel.font = UIFont.systemFont(ofSize: 12)
        tagLabel.textColor = UIColor.init(netHex: 0x007AFF)
        tagLabel.text = "VITE"
        tagBackgroundView.addSubview(tagLabel)
        tagLabel.snp.makeConstraints { (m) in
            m.center.equalToSuperview()
        }

        contentView.backgroundColor = UIColor.init(netHex: 0x007AFF, alpha: 0.06)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
