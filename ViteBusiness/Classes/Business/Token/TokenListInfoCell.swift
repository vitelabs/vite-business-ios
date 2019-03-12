//
//  TokenListInfoCell.swift
//  ViteBusiness
//
//  Created by Water on 2019/2/22.
//

import UIKit
import RxSwift
import ViteUtils

class TokenListInfoCell: UITableViewCell {
    lazy var rightContentView = UIView().then{ (rightContentView) in
        rightContentView.backgroundColor = .white

        self.contentView.addSubview(rightContentView)
        rightContentView.snp.makeConstraints { (m) in
            m.left.equalTo(self.tokenLogoImg.snp.right).offset(9)
            m.right.equalTo(self.contentView).offset(-130)
            m.centerY.equalTo(self.contentView)
        }
    }

    lazy var symbolLabel = UILabel().then {(symbolLabel) in
        symbolLabel.font = UIFont.systemFont(ofSize: 14)
        symbolLabel.textAlignment = .left
        symbolLabel.textColor = UIColor.init(netHex: 0x3E4A59)

        rightContentView.addSubview(symbolLabel)
        symbolLabel.snp.makeConstraints { (m) in
            m.left.top.equalTo(rightContentView)
            m.width.equalTo(110)
            m.height.equalTo(17)
        }
    }

    lazy var tokenNameLabel = UILabel().then {(tokenNameLabel) in
        tokenNameLabel.font = UIFont.systemFont(ofSize: 11)
        tokenNameLabel.textAlignment = .left
        tokenNameLabel.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.6)

        rightContentView.addSubview(tokenNameLabel)
        tokenNameLabel.snp.makeConstraints { (m) in
            m.left.equalTo(rightContentView)
            m.top.equalTo(self.symbolLabel.snp.bottom).offset(2)
            m.width.equalTo(150)
            m.height.equalTo(15)
        }
    }

    lazy var tokenAddressLabel = EthAddressView().then { (tokenAddressLabel) in
        tokenAddressLabel.font = UIFont.systemFont(ofSize: 11)
        tokenAddressLabel.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.6)

        rightContentView.addSubview(tokenAddressLabel)
        tokenAddressLabel.snp.makeConstraints { (m) in
            m.left.bottom.equalTo(rightContentView)
            m.top.equalTo(self.tokenNameLabel.snp.bottom).offset(2)
            m.width.equalTo(110)
            m.height.equalTo(15)
        }
    }

    private lazy var switchControl = UIView.createSwitchControl().then{ (switchControl) in
        switchControl.addTarget(self, action: #selector(switchChanged), for: .valueChanged)

        self.contentView.addSubview(switchControl)
        switchControl.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-24)
            m.centerY.equalToSuperview()
            m.width.equalTo(37)
            m.height.equalTo(20)
        }
    }

    private lazy var tokenLogoImg = TokenIconView().then { (tokenLogoImg) in
        tokenLogoImg.isUserInteractionEnabled = true

        self.contentView.addSubview(tokenLogoImg)
        tokenLogoImg.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(18)
            m.centerY.equalToSuperview()
            m.width.equalTo(32)
            m.height.equalTo(32)
        }
    }

     lazy var line = UIView().then { (line) in
        line.backgroundColor = UIColor.init(netHex: 0xD3DFEF)
    }

    private var tokenInfo: TokenInfo?

    func reloadData(_ token:TokenInfo) {
        self.tokenInfo = token

            self.symbolLabel.text = token.symbol
            self.tokenNameLabel.text = token.name

            if token.name != "" {
                self.tokenNameLabel.text = token.name
                self.tokenNameLabel.snp.updateConstraints { (m) in
                    m.height.equalTo(15)
                }
            }else {
                self.tokenNameLabel.text = ""
                self.tokenNameLabel.snp.updateConstraints { (m) in
                    m.height.equalTo(0)
                }
            }

            if token.ethContractAddress != "" {
                self.tokenAddressLabel.text = token.ethContractAddress
                self.tokenAddressLabel.snp.updateConstraints { (m) in
                    m.height.equalTo(15)
                }
            }else {
                self.tokenAddressLabel.text = ""
                self.tokenAddressLabel.snp.updateConstraints { (m) in
                    m.height.equalTo(0)
                }
            }
            self.tokenLogoImg.reset()
            self.tokenLogoImg.tokenInfo = token
            self.switchControl.isHidden = token.isDefault
            self.switchControl.setOn(token.isContains, animated: false)

    }

    @objc func switchChanged() {
        guard let token = self.tokenInfo else {
            return
        }
        if self.switchControl.isOn() {
            MyTokenInfosService.instance.append(tokenInfo: token)
        }else{
            MyTokenInfosService.instance.removeToken(for: token.tokenCode)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none

        self.contentView.addSubview(line)
        line.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(24)
            m.right.equalToSuperview().offset(-24)
            m.bottom.equalToSuperview()
            m.height.equalTo(1)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

