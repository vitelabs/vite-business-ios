//
//  MyAddressManageAddressCell.swift
//  Vite
//
//  Created by Stone on 2018/9/13.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import SnapKit
import ViteWallet

class MyAddressManageAddressCell: BaseTableViewCell {

    static func cellHeight() -> CGFloat {
        return 111
    }

    fileprivate let flagImageView = UIImageView()

    fileprivate let nameButton = UIButton().then {
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)
        $0.titleLabel?.lineBreakMode = .byTruncatingTail
    }

    fileprivate let addressLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x24272B, alpha: 0.7)
        $0.numberOfLines = 2
    }

    fileprivate let numberButton = UIButton().then {
        $0.isUserInteractionEnabled = false
        $0.setBackgroundImage(UIImage.image(withColor: UIColor(netHex: 0xEFF0F4), cornerRadius: 2).resizable, for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x3E4A59, alpha: 0.45), for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
    }

    fileprivate let copyButton = UIButton().then {
        $0.setImage(R.image.icon_button_paste_light_gray(), for: .normal)
        $0.setImage(R.image.icon_button_paste_light_gray()?.highlighted, for: .highlighted)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)




        contentView.addSubview(flagImageView)
        contentView.addSubview(nameButton)
        contentView.addSubview(addressLabel)
        contentView.addSubview(numberButton)
        contentView.addSubview(copyButton)

        flagImageView.setContentHuggingPriority(.required, for: .horizontal)
        flagImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        flagImageView.snp.makeConstraints { (m) in
            m.centerY.equalTo(contentView)
            m.left.equalTo(contentView).offset(24)
        }

        nameButton.snp.makeConstraints { (m) in
            m.top.equalTo(contentView).offset(20)
            m.left.equalTo(flagImageView.snp.right).offset(14)
        }

        addressLabel.snp.makeConstraints { (m) in
            m.bottom.equalTo(contentView).offset(-20)
            m.left.equalTo(flagImageView.snp.right).offset(14)
        }

        numberButton.snp.makeConstraints { (m) in
            m.left.equalTo(addressLabel)
            m.top.equalTo(addressLabel).offset(2)
            m.size.equalTo(CGSize(width: 28, height: 14))
        }

        let vLine = UIView().then {
            $0.backgroundColor = UIColor(netHex: 0xe5e5ea)
        }

        contentView.addSubview(vLine)
        vLine.snp.makeConstraints { (m) in
            m.width.equalTo(CGFloat.singleLineWidth)
            m.left.greaterThanOrEqualTo(nameButton.snp.right).offset(13)
            m.left.equalTo(addressLabel.snp.right).offset(13)
            m.right.equalTo(contentView).offset(-57)
            m.top.equalToSuperview().offset(20)
            m.bottom.equalToSuperview().offset(-20)
        }

        copyButton.snp.makeConstraints { (m) in
            m.top.bottom.right.equalTo(contentView)
            m.width.equalTo(66)
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

    func bind(viewModel: MyAddressManageAddressViewModelType) {
        var name = viewModel.name
        if name.count < 5 {
            name = name.appending("     ")
        }
        nameButton.setTitle(name, for: .normal)
        numberButton.setTitle("#\(viewModel.number)", for: .normal)
        let style = NSMutableParagraphStyle()
        style.firstLineHeadIndent = 30
        let attributes = [NSAttributedString.Key.paragraphStyle: style]
        addressLabel.attributedText = NSAttributedString(string: viewModel.address, attributes: attributes)

        flagImageView.image = viewModel.isSelected ? R.image.icon_cell_select() : R.image.icon_cell_unselect()
        copyButton.rx.tap.bind { viewModel.copy() }.disposed(by: disposeBag)

        nameButton.rx.tap.bind { [weak self] in
            Alert.show(title: R.string.localizable.addressManageChangeNameAlertTitle(), message: viewModel.address, actions: [
                (.cancel, nil),
                (.default(title: R.string.localizable.confirm()), { [weak self] alert in
                    guard let `self` = self else { return }
                    let text = alert.textFields?.first?.text ?? ""
                    AddressManageService.instance.updateName(for: viewModel.address, name: text)
                }),
                ], config: { alert in
                    alert.addTextField(configurationHandler: { (textField) in
                        textField.clearButtonMode = .always
                        textField.text = AddressManageService.instance.name(for: viewModel.address, placeholder: "")
                        textField.placeholder = R.string.localizable.addressManageChangeNameAlertPlaceholder()
                    })
            })
        }.disposed(by: disposeBag)
    }

}
