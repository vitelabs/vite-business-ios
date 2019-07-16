//
//  WalletHomeHeaderView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/5.
//

import UIKit
import PPBadgeViewSwift

class WalletHomeHeaderView: UIView {

    let bifrostStatusView = BifrostStatusView()

    lazy var addButton = UIButton().then {
        $0.setImage(R.image.icon_token_info_add_button(), for: .normal)
        $0.setImage(R.image.icon_token_info_add_button()?.highlighted, for: .highlighted)
    }

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 56))

        bifrostStatusView.isHidden = true

        let titleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            $0.textColor = UIColor(netHex: 0x3E4A59)
            $0.text = R.string.localizable.walletHomeHeaderTitle()
        }

        backgroundColor = UIColor.clear

        let layoutGuide = UILayoutGuide()
        addLayoutGuide(layoutGuide)
        addSubview(bifrostStatusView)
        addSubview(titleLabel)
        addSubview(addButton)
        
        bifrostStatusView.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview()
            m.bottom.equalTo(layoutGuide.snp.top)
            m.height.equalTo(32)
        }

        layoutGuide.snp.makeConstraints { (m) in
            m.left.right.bottom.equalTo(self)
            m.height.equalTo(56)
        }

        titleLabel.snp.makeConstraints { (m) in
            m.left.equalTo(layoutGuide).offset(24)
            m.centerY.equalTo(layoutGuide)
        }

        addButton.snp.makeConstraints { (m) in
            m.right.equalTo(layoutGuide)
            m.top.bottom.equalTo(layoutGuide)
            m.width.equalTo(76)
        }

        #if DAPP
        addButton.isHidden = true
        #endif

        self.bindView()
    }

    func bindView() {
        self.addButton.rx.tap.bind { [weak self] in
            let vc = TokenListManageController()
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: self.rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showBifrostStatusView() {
        bifrostStatusView.isHidden = false
//        UIView.animate(withDuration: 0.25) {
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y,
                                width: self.frame.width, height: 88)
//        }

    }

    func hideBifrostStatusView() {
        bifrostStatusView.isHidden = true
//        UIView.animate(withDuration: 0.25) {
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y,
                                width: self.frame.width, height: 56)
//        }
    }

}
