//
//  TokenSelectorView.swift
//  ViteBusiness
//
//  Created by Stone on 2020/7/29.
//

import Foundation

class TokenSelectorView: UIView {

    let titleLabel = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.text = R.string.localizable.transferToken()
    }

    let iconView = TokenIconView()
    let symbolLabel = UILabel().then {
        $0.textColor = UIColor(netHex: 0x24272B)
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
    }

    let changeButton = UIButton().then {
        $0.setImage(R.image.icon_vitex_transfer_down_arrows(), for: .normal)
        $0.setImage(R.image.icon_vitex_transfer_down_arrows()?.highlighted, for: .highlighted)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let separatorLine = UIView().then {
            $0.backgroundColor = Colors.lineGray
        }

        addSubview(titleLabel)
        addSubview(iconView)
        addSubview(symbolLabel)
        addSubview(changeButton)
        addSubview(separatorLine)

        titleLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.left.equalToSuperview().offset(24)
        }

        iconView.snp.makeConstraints { (m) in
            m.top.equalTo(titleLabel.snp.bottom).offset(11)
            m.left.equalToSuperview().offset(24)
            m.size.equalTo(CGSize(width: 20, height: 20))
            m.bottom.equalToSuperview().offset(-11)
        }

        symbolLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(iconView)
            m.left.equalTo(iconView.snp.right).offset(6)
        }

        changeButton.snp.makeConstraints { (m) in
            m.centerY.equalTo(iconView)
            m.right.equalToSuperview()
            m.size.equalTo(CGSize(width: 64, height: 40))
        }

        separatorLine.snp.makeConstraints { (m) in
            m.height.equalTo(CGFloat.singleLineWidth)
            m.left.equalTo(self).offset(24)
            m.right.equalTo(self).offset(-24)
            m.bottom.equalTo(self)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(tokenInfo: TokenInfo) {
        iconView.tokenInfo = tokenInfo
        symbolLabel.text = tokenInfo.uniqueSymbol
    }
}
