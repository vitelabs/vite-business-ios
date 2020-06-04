//
//  CoreTipItemView.swift
//  ViteBusiness
//
//  Created by Stone on 2020/6/4.
//

import Foundation

class CoreTipItemView: UIView {

    let label = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        $0.numberOfLines = 0
    }

    init(text: String, hasPoint: Bool = true) {
        super.init(frame: CGRect.zero)

        let horizontal: CGFloat = 24

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
                m.left.equalToSuperview().offset(horizontal)
                m.size.equalTo(CGSize(width: 6, height: 6))
            }

            label.snp.makeConstraints { (m) in
                m.top.bottom.equalToSuperview()
                m.left.equalTo(pointView.snp.right).offset(6)
                m.right.equalToSuperview().inset(horizontal)
            }
        } else {
            label.snp.makeConstraints { (m) in
                m.top.bottom.equalToSuperview()
                m.left.right.equalToSuperview().inset(horizontal)
            }
        }


    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
