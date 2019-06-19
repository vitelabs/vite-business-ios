//
//  TipView.swift
//  ViteBusiness
//
//  Created by Water on 2019/6/19.
//

import UIKit
import Then
import SnapKit
import RxSwift
import NSObject_Rx

class TipView: UIView {
    lazy var img = UIImageView().then {(bgImg) in
        bgImg.image = R.image.point()
        bgImg.isUserInteractionEnabled = false
    }
    lazy var lab = UILabel().then {(lab) in
        lab.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        lab.numberOfLines = 0
        lab.textAlignment = .left
        lab.textColor = UIColor.init(netHex: 0x3E4A59)
    }

    init(_ tip : String) {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.clear

        lab.text = tip
        addSubview(img)
        addSubview(lab)

        img.snp.makeConstraints { (m) in
            m.height.equalTo(4)
            m.width.equalTo(4)
            m.left.equalToSuperview()
            m.top.equalToSuperview().offset(6)
        }

        lab.snp.makeConstraints { (m) in
            m.top.bottom.right.equalToSuperview()
            m.left.equalTo(img.snp.right).offset(4)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
