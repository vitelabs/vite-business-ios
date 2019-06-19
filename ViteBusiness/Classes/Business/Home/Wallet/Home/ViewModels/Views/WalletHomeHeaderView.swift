//
//  WalletHomeHeaderView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/5.
//

import UIKit
import PPBadgeViewSwift

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

        addButton.pp.addBadge(number: 1)
        addButton.pp.badgeView.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        addButton.pp.badgeView.layer.borderColor = UIColor.white.cgColor
        addButton.pp.badgeView.layer.borderWidth = 1.0
        addButton.pp.setBadge(flexMode: .middle)
        addButton.pp.setBadge(height: 14)
        addButton.pp.moveBadge(x: 10, y: 15)
        addButton.rx.tap.bind { [weak self] in
            let vc = TokenListManageController(MyTokenInfosService.instance.tokenInfos)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: rx.disposeBag)

        #if DAPP
        addButton.isHidden = true
        #endif
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
