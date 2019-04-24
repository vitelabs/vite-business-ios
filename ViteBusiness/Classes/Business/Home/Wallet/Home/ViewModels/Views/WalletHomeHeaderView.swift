//
//  WalletHomeHeaderView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/5.
//

import UIKit

class WalletHomeHeaderView: UIView {

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 0, height: 56)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let titleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            $0.textColor = UIColor(netHex: 0x3E4A59)
            $0.text = R.string.localizable.walletHomeHeaderTitle()
        }

        let addButton = UIButton().then {
            $0.setImage(R.image.icon_token_info_add_button(), for: .normal)
            $0.setImage(R.image.icon_token_info_add_button()?.highlighted, for: .highlighted)
        }

        backgroundColor = UIColor.clear
        addSubview(titleLabel)
        addSubview(addButton)

        titleLabel.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(24)
            m.centerY.equalToSuperview()
        }

        addButton.snp.makeConstraints { (m) in
            m.right.equalToSuperview()
            m.top.bottom.equalToSuperview()
            m.width.equalTo(76)
        }

        addButton.rx.tap.bind { [weak self] in
            let sendViewController = TokenListManageController()
            UIViewController.current?.navigationController?.pushViewController(sendViewController, animated: true)
            }.disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
