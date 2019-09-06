//
//  WalletHomeHeaderView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/5.
//

import UIKit
import PPBadgeViewSwift

class WalletHomeHeaderView: UIView {

    lazy var addButton = UIButton().then {
        $0.setImage(R.image.icon_token_info_add_button(), for: .normal)
        $0.setImage(R.image.icon_token_info_add_button()?.highlighted, for: .highlighted)
    }

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 56))

        backgroundColor = UIColor.clear

        let layoutGuide = UILayoutGuide()
        addLayoutGuide(layoutGuide)
        addSubview(addButton)

        layoutGuide.snp.makeConstraints { (m) in
            m.left.right.bottom.equalTo(self)
            m.height.equalTo(56)
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
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
