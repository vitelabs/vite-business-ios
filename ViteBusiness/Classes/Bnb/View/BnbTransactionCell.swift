//
//  BnbTransactionCell.swift
//  ViteBusiness
//
//  Created by Water on 2019/7/4.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import BinanceChain

class BnbTransactionCell: BaseTableViewCell {

    static var cellHeight: CGFloat {
        return 94
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

    fileprivate let feeLabel = UILabel().then {
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
        contentView.addSubview(feeLabel)

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
            m.top.equalTo(addressBackView.snp.bottom).offset(12)
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
            m.left.equalTo(typeImageView)
            m.bottom.equalTo(contentView).offset(-8)
        }

        feeLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(timeLabel)
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

    func bind(viewModel: Tx, index: Int) {
        guard let selfAddress = BnbWallet.shared.fromAddress else {
            return
        }
        var balanceTempStr = ""
        if viewModel.txType == .transfer {
            typeImageView.image = R.image.bnb_transaction_icon()
            if selfAddress == viewModel.fromAddr {
                balanceLabel.textColor = UIColor(netHex: 0xFF0008)
                addressLabel.text = viewModel.toAddr
                balanceTempStr = "-"
            }else {
                balanceLabel.textColor = UIColor(netHex: 0x01D764)
                addressLabel.text = viewModel.fromAddr
                balanceTempStr = "+"
            }
        }else {
            typeImageView.image = R.image.bnb_transaction_other_icon()
            addressLabel.text = viewModel.toAddr
        }
        balanceLabel.text = String.init(format: "%@%@", balanceTempStr,viewModel.value)

        typeNameLabel.text = viewModel.txType.viteWords()
        timeLabel.text = viewModel.timestamp.format("yyyy.MM.dd HH:mm:ss")
        symbolLabel.text = viewModel.txAsset

        feeLabel.text = "\(R.string.localizable.bnbSendPageFeeViewTitleLabelTitle()) \(viewModel.txFee) BNB"
    }

}

