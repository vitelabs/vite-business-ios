//
//  GrinTransactionTitleView.swift
//  Action
//
//  Created by haoshenyang on 2019/3/11.
//

import UIKit

class GrinTransactionTitleView: UIView {

    let symbolLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.numberOfLines = 1
    }

    let tokenIconView = TokenIconView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSubVeiws()
    }

    func setUpSubVeiws()  {
        addSubview(symbolLabel)
        addSubview(tokenIconView)

//        backgroundColor = UIColor.white
//        layer.shadowColor = UIColor(netHex: 0x000000).cgColor
//        layer.shadowOpacity = 0.1
//        layer.shadowOffset = CGSize(width: 0, height: 5)
//        layer.shadowRadius = 20

        tokenIconView.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-22)
            m.bottom.equalToSuperview()
            m.size.equalTo(CGSize(width: 49, height: 49))
        }

        symbolLabel.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(24)
            m.right.equalTo(tokenIconView.snp.left).offset(-10)
            m.centerY.equalTo(tokenIconView)
        }

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpSubVeiws()
    }

}
