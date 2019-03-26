//
//  AddressListCell.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/12.
//

import UIKit
import SnapKit
import ViteWallet

class AddressListCell: BaseTableViewCell {

    static func cellHeight() -> CGFloat {
        return 111
    }

    fileprivate let nameImageView = UIImageView()
    fileprivate let nameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x24272B)
        $0.numberOfLines = 1
    }

    fileprivate let typeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        $0.numberOfLines = 1
        $0.textAlignment = .center
    }

    fileprivate let addressLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.numberOfLines = 2
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(nameImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(typeLabel)
        contentView.addSubview(addressLabel)

        nameImageView.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(24)
            m.left.equalToSuperview().offset(24)
            m.size.equalTo(CGSize(width: 14, height: 14))
        }

        nameLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(nameImageView)
            m.left.equalTo(nameImageView.snp.right).offset(4)
            m.right.equalToSuperview().offset(-24)
        }

        addressLabel.snp.makeConstraints { (m) in
            m.top.equalTo(nameImageView.snp.bottom).offset(18)
            m.left.equalToSuperview().offset(24)
            m.right.equalToSuperview().offset(-24)
        }

        typeLabel.snp.makeConstraints { (m) in
            m.top.equalTo(addressLabel).offset(-2)
            m.left.equalTo(addressLabel)
            m.size.equalTo(CGSize(width: 30, height: 17))
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

    func bind(viewModel: AddressViewModel) {
        nameLabel.text = viewModel.name
        nameImageView.image = viewModel.nameImage
        typeLabel.text = viewModel.type
        typeLabel.textColor = viewModel.typeTextColor
        typeLabel.backgroundColor = viewModel.typeBgColor

        let style = NSMutableParagraphStyle()
        style.firstLineHeadIndent = 36
        let attributes = [NSAttributedString.Key.paragraphStyle: style]
        addressLabel.attributedText = NSAttributedString(string: viewModel.address, attributes: attributes)
    }
}
