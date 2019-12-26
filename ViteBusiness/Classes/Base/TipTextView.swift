//
//  TipTextView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/9/11.
//

import UIKit

class TipTextView: UIView {

    let label = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.8)
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.numberOfLines = 0
    }

    init(text: String, hasPoint: Bool = true) {
        super.init(frame: CGRect.zero)

        label.text = text
        addSubview(label)

        if hasPoint {
            let pointView = UIView().then {
                $0.backgroundColor = UIColor(netHex: 0x007AFF)
                $0.layer.masksToBounds = true
                $0.layer.cornerRadius = 3
            }
            addSubview(pointView)
            pointView.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(6)
                m.left.equalToSuperview()
                m.size.equalTo(CGSize(width: 6, height: 6))
            }

            label.snp.makeConstraints { (m) in
                m.top.bottom.right.equalToSuperview()
                m.left.equalTo(pointView.snp.right).offset(6)
            }
        } else {
            label.snp.makeConstraints { (m) in
                m.top.bottom.left.right.equalToSuperview()
            }
        }


    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
