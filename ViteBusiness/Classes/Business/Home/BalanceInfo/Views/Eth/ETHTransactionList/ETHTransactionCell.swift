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
        return 74
    }

    fileprivate let typeImageView = UIImageView()

    fileprivate let typeNameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
    }

    fileprivate let addressLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.45)
        $0.lineBreakMode = .byTruncatingMiddle
    }

    fileprivate let confirmationsLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.3)
    }

    fileprivate let timeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
    }

    fileprivate let balanceLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        $0.textAlignment = .right
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
        contentView.addSubview(confirmationsLabel)
        contentView.addSubview(addressLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(balanceLabel)

        typeImageView.setContentHuggingPriority(.required, for: .horizontal)
        typeImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        typeImageView.snp.makeConstraints { (m) in
            m.top.equalTo(contentView).offset(17)
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
            m.left.equalTo(typeNameLabel.snp.right).offset(6)
        }

        addressLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(addressBackView)
            m.left.equalTo(addressBackView).offset(10)
            m.right.equalTo(addressBackView).offset(-10)
        }

        confirmationsLabel.setContentHuggingPriority(.required, for: .horizontal)
        confirmationsLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        confirmationsLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(typeImageView)
            m.right.equalToSuperview().offset(-24)
            m.left.equalTo(addressBackView.snp.right).offset(44)
        }

        timeLabel.setContentHuggingPriority(.required, for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        timeLabel.snp.makeConstraints { (m) in
            m.top.equalTo(typeImageView.snp.bottom).offset(14)
            m.left.equalToSuperview().offset(24)
        }

        balanceLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(timeLabel)
            m.left.equalTo(timeLabel.snp.right).offset(8)
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

    func bind(viewModel: ETHTransactionViewModel, index: Int) {
        typeImageView.image = viewModel.typeImage
        typeNameLabel.text = viewModel.typeName
        addressLabel.text = viewModel.address
        timeLabel.text = viewModel.timeString
        balanceLabel.text = viewModel.balanceString
        balanceLabel.textColor = viewModel.balanceColor

        if let state = viewModel.stateString {
            confirmationsLabel.text = state
            confirmationsLabel.textColor = UIColor(netHex: 0xFF0008)
        } else {
            if let num = Int(viewModel.confirmations), num <= 12 {
                confirmationsLabel.text = R.string.localizable.transactionListTransactionConfirmations(viewModel.confirmations)
                if num > 0 {
                    confirmationsLabel.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.3)
                } else {
                    confirmationsLabel.textColor = UIColor(netHex: 0xB5C4FF)
                }
            } else {
                confirmationsLabel.text = R.string.localizable.transactionListTransactionConfirmationsFinished()
                confirmationsLabel.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.3)
            }
        }
    }
}
