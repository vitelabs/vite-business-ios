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

    lazy var addButton = UIButton().then {
        $0.setImage(R.image.icon_token_info_add_button(), for: .normal)
        $0.setImage(R.image.icon_token_info_add_button()?.highlighted, for: .highlighted)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let titleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            $0.textColor = UIColor(netHex: 0x3E4A59)
            $0.text = R.string.localizable.walletHomeHeaderTitle()
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

        #if DAPP
        addButton.isHidden = true
        #endif

        self.bindView()
    }

    func bindView() {
        self.addButton.rx.tap.bind { [weak self] in
            var tokens = NewAssetService.instance.isNewTipTokenInfos
            let vc = TokenListManageController(tokens)
            UIViewController.current?.navigationController?.pushViewController(vc, animated: true)
            }.disposed(by: self.rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
