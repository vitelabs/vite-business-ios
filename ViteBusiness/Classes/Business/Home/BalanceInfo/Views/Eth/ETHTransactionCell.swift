//
//  ETHTransactionCell.swift
//  ViteBusiness
//
//  Created by Stone on 2020/2/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ETHTransactionCell: BaseTableViewCell {

    static var cellHeight: CGFloat {
        return 103
    }

    fileprivate let typeImageView = UIImageView()

    fileprivate let typeNameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x77808A)
    }

    fileprivate let addressLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
        $0.lineBreakMode = .byTruncatingMiddle
    }

    fileprivate let timeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
    }

    fileprivate let balanceLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        $0.textAlignment = .right
    }

    fileprivate let symbolLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
    }

    fileprivate let gasLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.3)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let addressBackView = UIImageView().then {
            $0.image = UIImage.image(withColor: UIColor(netHex: 0xF3F5F9), cornerRadius: 2).resizable
            $0.highlightedImage = UIImage.color(UIColor(netHex: 0xd9d9d9))
        }

        contentView.addSubview(typeImageView)
        contentView.addSubview(typeNameLabel)
        contentView.addSubview(addressBackView)
        contentView.addSubview(addressLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(balanceLabel)
        contentView.addSubview(symbolLabel)
        contentView.addSubview(gasLabel)

        typeImageView.setContentHuggingPriority(.required, for: .horizontal)
        typeImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        typeImageView.snp.makeConstraints { (m) in
            m.top.equalTo(contentView).offset(19)
            m.left.equalTo(contentView).offset(24)
            m.size.equalTo(CGSize(width: 14, height: 14))
        }

        typeNameLabel.setContentHuggingPriority(.required, for: .horizontal)
        typeNameLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        typeNameLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(typeImageView)
            m.left.equalTo(typeImageView.snp.right).offset(4)
        }

        addressBackView.snp.makeConstraints { (m) in
            m.centerY.equalTo(typeImageView)
            m.height.equalTo(20)
            m.left.equalTo(typeNameLabel.snp.right).offset(11)
            m.right.equalTo(contentView).offset(-24)
        }

        addressLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(addressBackView)
            m.left.equalTo(addressBackView).offset(6)
            m.right.equalTo(addressBackView).offset(-6)
        }

        balanceLabel.snp.makeConstraints { (m) in
            m.top.equalTo(typeNameLabel.snp.bottom).offset(10)
            m.left.equalToSuperview().offset(24)
        }

        symbolLabel.setContentHuggingPriority(.required, for: .horizontal)
        symbolLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        symbolLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(balanceLabel)
            m.left.equalTo(balanceLabel.snp.right).offset(8)
            m.right.equalTo(addressBackView)
        }

        timeLabel.setContentHuggingPriority(.required, for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        timeLabel.snp.makeConstraints { (m) in
            m.top.equalTo(balanceLabel.snp.bottom).offset(9)
            m.left.equalTo(balanceLabel)
            m.bottom.equalTo(contentView).offset(-13)
        }

        gasLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(timeLabel)
            m.left.greaterThanOrEqualTo(timeLabel.snp.right).offset(8)
            m.right.equalTo(addressBackView)
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

    func bind(viewModel: ETHTransactionViewModel, index: Int) {
        typeImageView.image = viewModel.typeImage
        typeNameLabel.text = viewModel.typeName
        addressLabel.text = viewModel.address
        timeLabel.text = viewModel.timeString
        balanceLabel.text = viewModel.balanceString
        balanceLabel.textColor = viewModel.balanceColor
        symbolLabel.text = viewModel.symbolString
        gasLabel.text = viewModel.gasString
    }
}
