//
//  EthInfoCardView.swift
//  Action
//
//  Created by Water on 2019/2/27.
//

import UIKit
import SnapKit
import ViteUtils

class EthInfoCardView: UIView {
    let bgImgView = UIImageView().then {
        $0.isUserInteractionEnabled = true
        $0.image = R.image.eth_cardBg()
        $0.contentMode = .scaleAspectFill
    }

    let addressIcon = UIImageView().then {
        $0.isUserInteractionEnabled = true
        $0.image = R.image.icon_button_paste_white()
        $0.contentMode = .scaleAspectFill
    }

    let addressLab = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        $0.text = R.string.localizable.sendPageMyAddressTitle()
    }

    let copyAddressBtn = UIButton().then {
        $0.setImage(R.image.icon_button_paste_white(), for: .normal)
        $0.setImage(R.image.icon_button_paste_white(), for: .highlighted)
    }

    let balanceLab = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        $0.text = R.string.localizable.sendPageMyAddressTitle()
    }
    let balanceLegalTenderLab = UILabel().then {
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        $0.text = R.string.localizable.sendPageMyAddressTitle()
    }

    let receiveButton = UIButton().then {
    $0.setTitle(R.string.localizable.balanceInfoDetailReveiceButtonTitle(), for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.setTitleColor(.white, for: .highlighted)
    }

    let sendButton = UIButton().then {
        $0.setTitle(R.string.localizable.balanceInfoDetailSendButtonTitle(), for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.setTitleColor(.white, for: .highlighted)
    }

    init(_ token: ETHToken) {
        super.init(frame: CGRect.zero)

        self.addSubview(bgImgView)
        bgImgView.snp.makeConstraints({ (m) in
            m.edges.equalTo(self)
        })

        self.addSubview(addressIcon)
        addressIcon.snp.makeConstraints({ (m) in
            m.top.equalToSuperview().offset(14)
            m.left.equalToSuperview().offset(14)
            m.width.height.equalTo(12)
        })
        self.addSubview(addressLab)
        addressLab.snp.makeConstraints({ (m) in
            m.centerY.equalTo(self.addressIcon)
            m.left.equalTo(self.addressIcon.snp.right).offset(5)
            m.height.equalTo(16)
        })

        self.addSubview(copyAddressBtn)
        copyAddressBtn.snp.makeConstraints({ (m) in
            m.centerY.equalTo(self.addressIcon)
            m.right.equalToSuperview().offset(-14)
            m.width.height.equalTo(12)
        })

        self.addSubview(balanceLab)
        balanceLab.snp.makeConstraints({ (m) in
            m.top.equalToSuperview().offset(60)
            m.left.equalToSuperview().offset(14)
            m.height.equalTo(20)
        })

        self.addSubview(balanceLegalTenderLab)
        balanceLegalTenderLab.snp.makeConstraints({ (m) in
            m.top.equalTo(self.balanceLab.snp.bottom).offset(14)
            m.left.equalToSuperview().offset(14)
            m.height.equalTo(16)
        })

        self.addSubview(receiveButton)
        receiveButton.snp.makeConstraints({ (m) in
            m.left.equalToSuperview()
            m.bottom.equalToSuperview()
            m.height.equalTo(44)
            m.width.equalToSuperview().dividedBy(2)
        })

        self.addSubview(sendButton)
        sendButton.snp.makeConstraints({ (m) in
            m.right.equalToSuperview()
            m.bottom.equalToSuperview()
            m.height.equalTo(44)
            m.width.equalToSuperview().dividedBy(2)
        })

        let lineView = UIView()
        lineView.backgroundColor = .white
        self.addSubview(lineView)
        lineView.snp.makeConstraints({ (m) in
            m.bottom.equalToSuperview().offset(-7)
            m.left.centerY.equalTo(self.sendButton)
            m.width.equalTo(1)
            m.height.equalTo(30)
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

