//
//  TokenListInfoSectionView.swift
//  ViteBusiness
//
//  Created by Water on 2019/6/19.
//

import Foundation

class TokenListInfoSectionView: UIView {

    lazy var titleLab = UILabel().then {(titleLab) in
        titleLab.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        titleLab.textColor = UIColor.init(netHex: 0x3E4A59)
        titleLab.backgroundColor = .white
        self.addSubview(titleLab)
        titleLab.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(10)
            m.left.equalToSuperview().offset(18)
            m.right.equalToSuperview().offset(-18)
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

