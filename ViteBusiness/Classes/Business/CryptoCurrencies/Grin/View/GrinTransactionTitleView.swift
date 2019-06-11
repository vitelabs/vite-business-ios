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

        tokenIconView.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-22)
            m.top.equalToSuperview().offset(1)
            m.size.equalTo(CGSize(width: 49, height: 49))
        }

        symbolLabel.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(24)
            m.centerY.equalTo(tokenIconView)
        }

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpSubVeiws()
    }

}
