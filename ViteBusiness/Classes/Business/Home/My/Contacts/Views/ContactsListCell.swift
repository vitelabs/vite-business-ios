//
//  ContactsListCell.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/12.
//

import UIKit
import SnapKit
import ViteWallet

class ContactsListCell: BaseTableViewCell {

    static func cellHeight() -> CGFloat {
        return 111
    }

    fileprivate let nameImageView = UIImageView(image: R.image.icon_contacts_contact())
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

    fileprivate let editButton = UIButton().then {
        $0.setImage(R.image.icon_edit_name(), for: .normal)
        $0.setImage(R.image.icon_edit_name()?.highlighted, for: .highlighted)
    }

    fileprivate let copyButton = UIButton().then {
        $0.setImage(R.image.icon_button_paste_light_gray(), for: .normal)
        $0.setImage(R.image.icon_button_paste_light_gray()?.highlighted, for: .highlighted)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        
        contentView.addSubview(nameImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(typeLabel)
        contentView.addSubview(addressLabel)
        contentView.addSubview(editButton)
        contentView.addSubview(copyButton)

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
            m.right.equalToSuperview().offset(-103)
        }

        typeLabel.snp.makeConstraints { (m) in
            m.top.equalTo(addressLabel).offset(-2)
            m.left.equalTo(addressLabel)
            m.size.equalTo(CGSize(width: 30, height: 17))
        }

        let vLine = UIView().then {
            $0.backgroundColor = UIColor(netHex: 0xe5e5ea)
        }

        contentView.addSubview(vLine)
        vLine.snp.makeConstraints { (m) in
            m.width.equalTo(CGFloat.singleLineWidth)
            m.right.equalTo(contentView).offset(-92)
            m.top.equalToSuperview().offset(56)
            m.bottom.equalToSuperview().offset(-10)
        }

        editButton.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(68)
            m.right.equalToSuperview().offset(-62)
        }

        copyButton.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(68)
            m.right.equalToSuperview().offset(-24)
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

    func bind(viewModel: ContactsViewModel) {
        nameLabel.text = viewModel.name
        typeLabel.text = viewModel.type
        typeLabel.textColor = viewModel.typeTextColor
        typeLabel.backgroundColor = viewModel.typeBgColor

        let style = NSMutableParagraphStyle()
        style.firstLineHeadIndent = 36
        let attributes = [NSAttributedString.Key.paragraphStyle: style]
        addressLabel.attributedText = NSAttributedString(string: viewModel.address, attributes: attributes)

        editButton.rx.tap.bind {
            let vc = ContactsEditViewController(contact: viewModel.contact)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)

        copyButton.rx.tap.bind {
            UIPasteboard.general.string = viewModel.contact.address
            Toast.show(R.string.localizable.walletHomeToastCopyAddress(), duration: 1.0)
            }.disposed(by: disposeBag)
    }
}
