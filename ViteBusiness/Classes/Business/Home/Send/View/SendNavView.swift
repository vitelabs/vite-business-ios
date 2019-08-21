//
//  SendNavView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/7.
//

import UIKit

class SendNavView: UIView {

    let symbolLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        $0.textColor = UIColor(netHex: 0x24272B)
        $0.numberOfLines = 1
    }

    let tokenIconView = TokenIconView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(symbolLabel)
        addSubview(tokenIconView)

        backgroundColor = UIColor.white

        tokenIconView.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-24)
            m.bottom.equalToSuperview()
            m.size.equalTo(CGSize(width: 50, height: 50))
        }

        symbolLabel.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(24)
            m.right.equalTo(tokenIconView.snp.left).offset(-10)
            m.bottom.equalToSuperview().offset(-9)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(tokenInfo: TokenInfo) {
        symbolLabel.text = "\(R.string.localizable.sendPageTitle()) \(tokenInfo.uniqueSymbol)"
        tokenIconView.tokenInfo = tokenInfo
    }
}
