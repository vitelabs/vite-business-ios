//
//  BalanceInfoNavView.swift
//  Action
//
//  Created by Stone on 2019/2/27.
//

import UIKit

class BalanceInfoNavView: UIView {

    let symbolLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.numberOfLines = 1
    }

    let nameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.numberOfLines = 1
    }

    let tokenIconView = TokenIconView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(symbolLabel)
        addSubview(nameLabel)
        addSubview(tokenIconView)

        backgroundColor = UIColor.white
        layer.shadowColor = UIColor(netHex: 0x000000).cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowRadius = 20

        tokenIconView.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-22)
            m.bottom.equalToSuperview().offset(-72)
            m.size.equalTo(CGSize(width: 50, height: 50))
        }

        nameLabel.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(24)
            m.right.equalTo(tokenIconView.snp.left).offset(-10)
            m.bottom.equalToSuperview().offset(-72)
        }

        symbolLabel.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(24)
            m.right.equalTo(tokenIconView.snp.left).offset(-10)
            m.bottom.equalTo(nameLabel.snp.top).offset(-6)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(tokenInfo: TokenInfo) {
        symbolLabel.text = tokenInfo.symbol
        nameLabel.text = tokenInfo.name
        tokenIconView.tokenInfo = tokenInfo
    }
}
