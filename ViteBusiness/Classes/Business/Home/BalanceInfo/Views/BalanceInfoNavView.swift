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

    let gatewayInfoBtn = GateWayNameButton()

    let helpButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.grin_help(), for: .normal)
        button.isHidden = true
        return button
    }()

    let tokenIconView = TokenIconView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSubVeiws()
    }

    func setUpSubVeiws()  {
        addSubview(symbolLabel)
        addSubview(nameLabel)
        addSubview(tokenIconView)
        addSubview(gatewayInfoBtn)
        addSubview(helpButton)

        backgroundColor = UIColor.white
//        layer.shadowColor = UIColor(netHex: 0x000000).cgColor
//        layer.shadowOpacity = 0.1
//        layer.shadowOffset = CGSize(width: 0, height: 5)
//        layer.shadowRadius = 20

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

        gatewayInfoBtn.snp.makeConstraints { (m) in
            m.left.equalTo(symbolLabel.snp.right).offset(5)
            m.centerY.equalTo(symbolLabel)
            m.height.equalTo(16)
            m.width.equalTo(200)
        }

        helpButton.snp.makeConstraints { (m) in
            m.width.height.equalTo(16)
            m.centerY.equalTo(symbolLabel)
            m.left.equalToSuperview().offset(86)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpSubVeiws()
    }

    func bind(tokenInfo: TokenInfo) {
        gatewayInfoBtn.isHidden = true

        symbolLabel.text = tokenInfo.uniqueSymbol
        nameLabel.text = tokenInfo.name
        tokenIconView.tokenInfo = tokenInfo
        if let gatewayName = tokenInfo.gatewayName {
            gatewayInfoBtn.setText(gatewayName)
            gatewayInfoBtn.isHidden = false
            gatewayInfoBtn.layoutIfNeeded()
        } else {
            gatewayInfoBtn.isHidden = true
        }
        helpButton.isHidden = true
        helpButton.setImage(nil, for: .normal)
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
        case .bnb:
            if isEtherCoin {
                return nil
            } else {
                return URL(string: "\(ViteConst.instance.eth.explorer)/address/\(ethContractAddress)")
            }
        case .unsupport:
            return nil
        }
    }
}

class GateWayNameButton: UIView {
    
    let gatewayIconImageView = UIImageView(image: R.image.gateway())
    let bgImageView = UIImageView.init(image: R.image.gateway_label_layer()?.resizableImage(withCapInsets: UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 30), resizingMode: .stretch))
    let label = UILabel().then {
        $0.text = "Gateway"
        $0.font = UIFont.systemFont(ofSize: 11)
        $0.textColor = UIColor.init(netHex: 0x007AFF)
    }

    let button  = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(gatewayIconImageView)
        addSubview(bgImageView)
        addSubview(label)
        addSubview(button)

        gatewayIconImageView.snp.makeConstraints { (m) in
            m.left.equalToSuperview()
            m.centerY.equalToSuperview()
            m.width.height.equalTo(19)
        }

        label.snp.makeConstraints { (m) in
            m.top.bottom.equalToSuperview()
            m.left.equalTo(gatewayIconImageView.snp.right).offset(2)
        }
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        bgImageView.snp.makeConstraints { (m) in
            m.top.bottom.equalTo(gatewayIconImageView)
            m.left.equalTo(gatewayIconImageView.snp.centerX)
            m.right.equalTo(label.snp.right).offset(8)
        }

        button.snp.makeConstraints { (m) in
            m.top.bottom.equalToSuperview()
            m.left.equalTo(gatewayIconImageView)
            m.right.equalTo(bgImageView)
        }


    }

    func setText(_ text: String) {
        label.text = text
        label.snp.remakeConstraints { (m) in
            m.top.bottom.equalToSuperview()
            m.left.equalTo(gatewayIconImageView.snp.right).offset(2)
            m.width.equalTo(label.sizeThatFits(CGSize(width: 100, height: 100)).width)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
