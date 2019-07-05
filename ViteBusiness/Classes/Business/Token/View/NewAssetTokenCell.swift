//
//  NewAssetTokenCell.swift
//  ViteBusiness
//
//  Created by Water on 2019/6/19.
//

import UIKit
import RxSwift

protocol NewAssetTokenCellDelegate : class {
    func refreshList()
}

class NewAssetTokenCell: UITableViewCell {
    weak var delegate: NewAssetTokenCellDelegate?
    lazy var rightContentView = UIView().then{ (rightContentView) in
        rightContentView.backgroundColor = .white
    }

    lazy var symbolLabel = UILabel().then {(symbolLabel) in
        symbolLabel.font = UIFont.systemFont(ofSize: 14)
        symbolLabel.textAlignment = .left
        symbolLabel.textColor = UIColor.init(netHex: 0x3E4A59)
    }

    lazy var amountLabel = UILabel().then {(tokenNameLabel) in
        tokenNameLabel.font = UIFont.systemFont(ofSize: 12)
        tokenNameLabel.textAlignment = .right
        tokenNameLabel.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.6)
    }

    lazy var amountLegalLabel = UILabel().then {(tokenNameLabel) in
        tokenNameLabel.font = UIFont.systemFont(ofSize: 11)
        tokenNameLabel.textAlignment = .right
        tokenNameLabel.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.6)
    }

    lazy var tokenNameLabel = UILabel().then {(tokenNameLabel) in
        tokenNameLabel.font = UIFont.systemFont(ofSize: 11)
        tokenNameLabel.textAlignment = .left
        tokenNameLabel.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.6)
    }

    lazy var tokenAddressLabel = EthAddressView().then { (tokenAddressLabel) in
        tokenAddressLabel.font = UIFont.systemFont(ofSize: 11)
        tokenAddressLabel.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.3)
    }

    private lazy var switchControl = UIView.createSwitchControl().then{ (switchControl) in
        switchControl.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
    }

    private lazy var tokenLogoImg = TokenIconView().then { (tokenLogoImg) in
        tokenLogoImg.isUserInteractionEnabled = true
    }

    lazy var line = UIView().then { (line) in
        line.backgroundColor = UIColor.init(netHex: 0xD3DFEF)
    }

    lazy var centerline = UIView().then { (line) in
        line.backgroundColor = UIColor.init(netHex: 0xE5E5EA)
    }

    private var tokenInfo: TokenInfo?

    func reloadData(_ token:TokenInfo) {
        self.tokenInfo = token
        self.symbolLabel.text = token.uniqueSymbol
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

        self.tokenLogoImg.tokenInfo = token
        self.switchControl.setOn(token.isContains, animated: false)

        guard let price = NewAssetService.instance.fetchAmountByTokenCode(token.tokenCode) else {
            self.amountLabel.text = ""
            self.amountLegalLabel.text = ""
            return
        }
        self.amountLabel.text = price.0
        self.amountLegalLabel.text = price.1
    }

    @objc func switchChanged() {
        guard let token = self.tokenInfo else {
            return
        }
        if self.switchControl.isOn() {
            MyTokenInfosService.instance.append(tokenInfo: token)
            NewAssetService.instance.removeNewTip(token: token)
            self.delegate?.refreshList()
        }else{
            MyTokenInfosService.instance.removeToken(for: token.tokenCode)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none

        self.contentView.addSubview(switchControl)
        switchControl.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-24)
            m.centerY.equalToSuperview()
            m.width.equalTo(37)
            m.height.equalTo(20)
        }

        self.contentView.addSubview(tokenLogoImg)
        tokenLogoImg.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(18)
            m.centerY.equalToSuperview()
            m.width.equalTo(32)
            m.height.equalTo(32)
        }

        self.contentView.addSubview(line)
        line.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(24)
            m.right.equalToSuperview().offset(-24)
            m.bottom.equalToSuperview()
            m.height.equalTo(1)
        }

        self.contentView.addSubview(rightContentView)
        rightContentView.snp.makeConstraints { (m) in
            m.left.equalTo(self.tokenLogoImg.snp.right).offset(9)
            m.right.equalTo(self.contentView).offset(-130)
            m.centerY.equalTo(self.contentView)
        }

        rightContentView.addSubview(symbolLabel)
        symbolLabel.snp.makeConstraints { (m) in
            m.left.top.equalTo(rightContentView)
            m.width.equalTo(110)
            m.height.equalTo(17)
        }

        rightContentView.addSubview(tokenNameLabel)
        tokenNameLabel.snp.makeConstraints { (m) in
            m.left.equalTo(rightContentView)
            m.top.equalTo(self.symbolLabel.snp.bottom).offset(2)
            m.width.equalTo(150)
            m.height.equalTo(15)
        }

        rightContentView.addSubview(tokenAddressLabel)
        tokenAddressLabel.snp.makeConstraints { (m) in
            m.left.bottom.equalTo(rightContentView)
            m.top.equalTo(self.tokenNameLabel.snp.bottom).offset(2)
            m.width.equalTo(110)
            m.height.equalTo(15)
        }

        self.contentView.addSubview(centerline)
        centerline.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(18)
            m.bottom.equalToSuperview().offset(-18)
            m.right.equalToSuperview().offset(-73)
            m.width.equalTo(1)
        }

        self.contentView.addSubview(amountLabel)
        amountLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(22)
            m.right.equalTo(self.centerline.snp.left).offset(-12)
            m.height.equalTo(16)
        }

        self.contentView.addSubview(amountLegalLabel)
        amountLegalLabel.snp.makeConstraints { (m) in
            m.top.equalTo(self.amountLabel.snp.bottom).offset(3)
            m.right.equalTo(self.centerline.snp.left).offset(-12)
            m.height.equalTo(16)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


