//
//  EthInfoCardView.swift
//  Action
//
//  Created by Water on 2019/2/27.
//

import UIKit
import SnapKit
import ViteUtils
import ViteEthereum

class EthInfoCardView: UIView {
    let bgImgView = UIImageView().then {
        $0.isUserInteractionEnabled = true
    }

    let lineImageView = UIImageView(image: R.image.dotted_line()?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .tile))

    let addressIcon = UIImageView().then {
        $0.isUserInteractionEnabled = true
        $0.image = R.image.icon_address_name()
        $0.contentMode = .scaleToFill
    }

    let addressLab = EthAddressView()

    let copyAddressBtn = UIButton().then {
        $0.setImage(R.image.icon_button_paste_white(), for: .normal)
        $0.setImage(R.image.icon_button_paste_white(), for: .highlighted)
        $0.addTarget(self, action: #selector(copyAction), for: .touchUpInside)
    }

    let balanceLab = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        $0.adjustsFontSizeToFitWidth = true
        $0.text = ""
    }
    let balanceLegalTenderLab = UILabel().then {
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.adjustsFontSizeToFitWidth = true
        $0.text = ""
    }

    let receiveButton = UIButton().then {
    $0.setTitle(R.string.localizable.balanceInfoDetailReveiceButtonTitle(), for: .normal)
        $0.titleLabel?.font = Fonts.Font14_b
        $0.setTitleColor(.white, for: .normal)
        $0.setTitleColor(.white, for: .highlighted)
    }

    let sendButton = UIButton().then {
        $0.setTitle(R.string.localizable.balanceInfoDetailSendButtonTitle(), for: .normal)
        $0.titleLabel?.font = Fonts.Font14_b
        $0.setTitleColor(.white, for: .normal)
        $0.setTitleColor(.white, for: .highlighted)
    }

    init(_ token: TokenInfo) {
        super.init(frame: CGRect.zero)

        DispatchQueue.main.async {
            self.bgImgView.backgroundColor = UIColor.gradientColor(style: .leftTop2rightBottom, frame: self.frame, colors: token.coinBackgroundGradientColors)
        }

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
            m.width.equalTo(135)
        })

        self.addSubview(copyAddressBtn)
        copyAddressBtn.snp.makeConstraints({ (m) in
            m.centerY.equalTo(self.addressIcon)
            m.right.equalToSuperview().offset(-14)
            m.width.height.equalTo(12)
        })

        self.addSubview(lineImageView)
        lineImageView.snp.makeConstraints({ (m) in
            m.left.right.equalToSuperview()
            m.top.equalToSuperview().offset(44)
            m.height.equalTo(1)
        })

        self.addSubview(balanceLab)
        balanceLab.snp.makeConstraints({ (m) in
            m.top.equalToSuperview().offset(60)
            m.left.equalToSuperview().offset(14)
            m.right.equalToSuperview()
            m.height.equalTo(20)
        })

        self.addSubview(balanceLegalTenderLab)
        balanceLegalTenderLab.snp.makeConstraints({ (m) in
            m.top.equalTo(self.balanceLab.snp.bottom).offset(14)
            m.left.equalToSuperview().offset(14)
            m.right.equalToSuperview()
            m.height.equalTo(16)
        })

        let buttonBgView = UIView().then {
            $0.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            $0.layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
            $0.layer.shadowOpacity = 1
            $0.layer.shadowOffset = CGSize(width: 0, height: -2)
            $0.layer.shadowRadius = 2
        }
        self.addSubview(buttonBgView)
        buttonBgView.snp.makeConstraints({ (m) in
            m.left.right.bottom.equalToSuperview()
            m.height.equalTo(44)
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

        let vLine = UIView().then {
            $0.backgroundColor = UIColor(netHex: 0xffffff, alpha: 0.15)
        }
        self.addSubview(vLine)
        vLine.snp.makeConstraints { (m) in
            m.width.equalTo(CGFloat.singleLineWidth)
            m.left.centerY.equalTo(self.sendButton)
            m.height.equalTo(30)
            m.bottom.equalToSuperview().offset(-7)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func copyAction() {
        UIPasteboard.general.string = EtherWallet.account.address
        Toast.show(R.string.localizable.walletHomeToastCopyAddress(), duration: 1.0)
    }
}
