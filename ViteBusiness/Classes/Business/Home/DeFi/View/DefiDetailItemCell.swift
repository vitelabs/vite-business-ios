//
//  DefiDetailItemCell.swift
//  Action
//
//  Created by haoshenyang on 2019/12/2.
//

import UIKit

class DefiProductItemCell: UITableViewCell {

    let titleLabel = UILabel().then {
           $0.font = UIFont.systemFont(ofSize: 14)
           $0.textColor = UIColor.init(netHex: 0x3E4A59)
       }

    let contentLabel = UILabel().then {
           $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.7)
       }


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(titleLabel)
        contentView.addSubview(contentLabel)

        titleLabel.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.left.equalToSuperview().offset(24)
        }
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        contentLabel.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.right.equalToSuperview().offset(-24)
            m.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(10)
        }

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class DefiProductItemWithUnitCell: UITableViewCell {

    let titleLabel = UILabel().then {
           $0.font = UIFont.systemFont(ofSize: 14)
           $0.textColor = UIColor.init(netHex: 0x3E4A59)
       }

    let contentLabel = UILabel().then {
           $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.7)
       }

    let unitLabel = UILabel().then {
           $0.font = UIFont.systemFont(ofSize: 14)
           $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
       }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none

        contentView.addSubview(titleLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(unitLabel)

        titleLabel.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.left.equalToSuperview().offset(24)
        }
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        unitLabel.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.right.equalToSuperview().offset(-24)
        }

        contentLabel.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.right.equalTo(unitLabel.snp.left).offset(-6)
            m.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(10)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class DefiProductItemWithSubContentCell: UITableViewCell {

    let titleLabel = UILabel().then {
           $0.font = UIFont.systemFont(ofSize: 14)
           $0.textColor = UIColor.init(netHex: 0x3E4A59)
       }

    let contentLabel = UILabel().then {
           $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.7)
       }

    let unitLabel = UILabel().then {
           $0.font = UIFont.systemFont(ofSize: 14)
           $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
       }

    let subContentLabel = UILabel().then {
           $0.font = UIFont.systemFont(ofSize: 14)
           $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
       }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none

        contentView.addSubview(titleLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(unitLabel)
        contentView.addSubview(subContentLabel)

        titleLabel.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.left.equalToSuperview().offset(24)
        }

        unitLabel.snp.makeConstraints { (m) in
            m.bottom.equalTo(contentView.snp.centerY).offset(-2)
            m.right.equalToSuperview().offset(-24)
        }

        contentLabel.snp.makeConstraints { (m) in
            m.bottom.equalTo(contentView.snp.centerY).offset(-2)
            m.right.equalTo(unitLabel.snp.left).offset(-6)
        }

        subContentLabel.snp.makeConstraints { (m) in
            m.top.equalTo(contentView.snp.centerY).offset(2)
            m.right.equalToSuperview().offset(-24)
        }

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class DefiProductItemWithMultiLineCell: UITableViewCell {

    let titleLabel = UILabel().then {
           $0.font = UIFont.systemFont(ofSize: 14)
           $0.textColor = UIColor.init(netHex: 0x3E4A59)
       }

    let contentLabel = UILabel().then {
           $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.7)
       }

    let unitLabel = UILabel().then {
           $0.font = UIFont.systemFont(ofSize: 14)
           $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.45)
       }



    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(titleLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(unitLabel)

        titleLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(19)
            m.left.equalToSuperview().offset(24)
        }

        unitLabel.snp.makeConstraints { (m) in
            m.bottom.equalToSuperview().offset(-11)
            m.right.equalToSuperview().offset(-24)
        }

        contentLabel.snp.makeConstraints { (m) in
            m.bottom.equalToSuperview().offset(-11)
            m.left.equalToSuperview().offset(24)
            m.right.equalTo(unitLabel.snp.left).offset(-6)
        }

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

