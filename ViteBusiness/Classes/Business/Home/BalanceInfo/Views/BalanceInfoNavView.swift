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

    let gatewayNamelabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        $0.textColor = UIColor(netHex: 0x007AFF)
        $0.numberOfLines = 1
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.init(netHex: 0xCCE5FF).cgColor
    }

    let tokenIconView = TokenIconView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSubVeiws()
    }

    func setUpSubVeiws()  {
        addSubview(symbolLabel)
        addSubview(nameLabel)
        addSubview(tokenIconView)
        addSubview(gatewayNamelabel)

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
            m.bottom.equalTo(nameLabel.snp.top).offset(-6)
        }

        gatewayNamelabel.snp.makeConstraints { (m) in
            m.left.equalTo(symbolLabel.snp.right).offset(6)
            m.centerY.equalTo(symbolLabel)
            m.height.equalTo(16)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpSubVeiws()
    }

    func bind(tokenInfo: TokenInfo) {
        symbolLabel.text = tokenInfo.uniqueSymbol
        nameLabel.text = tokenInfo.name
        tokenIconView.tokenInfo = tokenInfo
        if let gatewayName = tokenInfo.gatewayName {
            gatewayNamelabel.text = " \(gatewayName) "
            gatewayNamelabel.isHidden = false
        } else {
            gatewayNamelabel.isHidden = true
        }
    }
}

extension TokenInfo {
    var infoURL: URL? {
        switch coinType {
        case .vite:
            return URL(string: "\(ViteConst.instance.vite.explorer)/token/\(viteTokenId)")
        case .eth:
            if isEtherCoin {
                return nil
            } else {
                return URL(string: "\(ViteConst.instance.eth.explorer)/address/\(ethContractAddress)")
            }
        case .grin:
            return nil
        case .btc:
            return nil
        }
    }
}
