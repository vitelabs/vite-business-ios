//
//  WalletAbstractView.swift
//  Action
//
//  Created by haoshenyang on 2019/6/17.
//

import UIKit

class WalletAbstractView: UIView {

    let tl0 = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
    }

    let cl0 = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        $0.numberOfLines = 2
    }

    let tl1 = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
    }

    let cl1 = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
    }

    let tl2 = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
    }

    let cl2 = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
    }


    override init(frame: CGRect) {
        super.init(frame: frame)

        let contentView = createContentViewAndSetShadow(width: 0, height: 5, radius: 9)
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 2

        let line = UIView().then { $0.backgroundColor = UIColor(netHex: 0x759BFA) }

        contentView.addSubview(line)
        contentView.addSubview(tl0)
        contentView.addSubview(cl0)
        contentView.addSubview(tl1)
        contentView.addSubview(cl1)
        contentView.addSubview(tl2)
        contentView.addSubview(cl2)

        line.snp.makeConstraints({ (m) in
            m.top.bottom.left.equalTo(contentView)
            m.width.equalTo(3)
        })

        tl0.snp.makeConstraints({ (m) in
            m.top.equalTo(contentView).offset(16)
            m.left.equalTo(contentView).offset(19)
            m.right.equalTo(contentView).offset(-16)
        })

        cl0.snp.makeConstraints({ (m) in
            m.top.equalTo(tl0.snp.bottom).offset(8)
            m.left.right.equalTo(tl0)
        })

        tl1.snp.makeConstraints({ (m) in
            m.top.equalTo(cl0.snp.bottom).offset(16)
            m.left.right.equalTo(tl0)
        })

        cl1.snp.makeConstraints({ (m) in
            m.top.equalTo(tl1.snp.bottom).offset(8)
            m.left.right.equalTo(tl0)
        })

        tl2.snp.makeConstraints { (m) in
            m.top.equalTo(cl1.snp.bottom).offset(16)
            m.left.right.equalTo(tl0)
        }

        cl2.snp.makeConstraints { (m) in
            m.top.equalTo(tl2.snp.bottom).offset(8)
            m.left.right.equalTo(tl0)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

