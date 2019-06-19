//
//  NewAssetTableSectionView.swift
//  ViteBusiness
//
//  Created by Water on 2019/6/19.
//

import Foundation

class NewAssetTableSectionView: UIView {

    lazy var titleLab = TipView("").then {(titleLab) in
        titleLab.backgroundColor = .clear
        self.addSubview(titleLab)
        titleLab.snp.makeConstraints { (m) in
            m.centerY.equalToSuperview()
            m.left.equalToSuperview().offset(18)
            m.width.equalTo(100)
            m.height.equalTo(20)
        }
    }

    lazy var ignoreBtn = UIButton(type: .custom).then {(ignoreBtn) in
        ignoreBtn.setTitle(R.string.localizable.tokenListPageIgnoreBtnTitle(), for: .normal)
        ignoreBtn.setTitleColor(UIColor(netHex: 0x3E4A59, alpha: 0.6), for: .normal)
        ignoreBtn.contentHorizontalAlignment = .right
        ignoreBtn.titleLabel?.font = Fonts.Font12_r
        ignoreBtn.backgroundColor = .clear
        self.addSubview(ignoreBtn)
        ignoreBtn.snp.makeConstraints { (m) in
            m.centerY.top.bottom.equalToSuperview()
            m.width.equalTo(100)
            m.right.equalToSuperview().offset(-24)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

