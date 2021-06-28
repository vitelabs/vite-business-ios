//
//  BalanceInfoViteChainQuotaView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/31.
//

import UIKit
import NSObject_Rx
import RxSwift
import RxCocoa
import ViteWallet

class BalanceInfoViteChainQuotaView: UIView {

    let quotaLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.71)
        $0.numberOfLines = 1
        $0.text = R.string.localizable.balanceInfoDetailPledgeCountContent()
    }

    let quotaButton = UIButton().then {
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        $0.setImage(R.image.icon_balance_quota_arrows(), for: .normal)
        $0.setImage(R.image.icon_balance_quota_arrows()?.highlighted, for: .highlighted)
        $0.setTitle(R.string.localizable.balanceInfoDetailPledge(), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)
        $0.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.titleLabel?.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
    }

    let maxImageView = UIImageView().then {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 2
        $0.backgroundColor = UIColor.white
    }

    let currentImageView = UIImageView().then {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 2
        $0.backgroundColor = UIColor(netHex: 0x54B6FF)
    }


    let currentLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.numberOfLines = 1
    }

    let tipLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.numberOfLines = 1
        $0.text = R.string.localizable.balanceInfoDetailPledgeNoneTip()
    }


    override var intrinsicContentSize: CGSize {
        return CGSize(width: 0, height: 74)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.masksToBounds = true
        layer.cornerRadius = 2

        addSubview(quotaLabel)
        addSubview(quotaButton)
        addSubview(maxImageView)
        addSubview(currentImageView)
        addSubview(currentLabel)
        addSubview(tipLabel)

        quotaLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(12)
            m.left.equalToSuperview().offset(14)
        }

        quotaButton.snp.makeConstraints { (m) in
            m.centerY.equalTo(quotaLabel)
            m.right.equalToSuperview().offset(-14)
        }

        maxImageView.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(14)
            m.right.equalToSuperview().offset(-14)
            m.centerY.equalToSuperview()
            m.height.equalTo(4)
        }

        currentImageView.snp.makeConstraints { (m) in
            m.left.top.bottom.equalTo(maxImageView)
            m.width.equalTo(maxImageView).multipliedBy(0)
        }

        currentLabel.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(14)
            m.bottom.equalToSuperview().offset(-10)
        }

        tipLabel.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(14)
            m.bottom.equalToSuperview().offset(-19)
        }

        quotaButton.rx.tap.bind {
            Statistics.log(eventId: Statistics.Page.WalletHome.quotaClicked.rawValue)
            let sendViewController = QuotaManageViewController()
            UIViewController.current?.navigationController?.pushViewController(sendViewController, animated: true)
            }.disposed(by: rx.disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func bind(tokenInfo: TokenInfo) {
        guard let token = tokenInfo.toViteToken() else { return }



    }

    func updateQuota(currect: Double, max: Double) {

        DispatchQueue.main.async {
            self.backgroundColor = UIColor.gradientColor(style: .left2right,
                                                         frame: self.frame,
                                                         colors: [UIColor(netHex: 0xE3F0FF),
                                                                  UIColor(netHex: 0xF2F8FF)])
        }

        if max.isZero {
            currentImageView.isHidden = true
            maxImageView.isHidden = true
            currentLabel.isHidden = true
            tipLabel.isHidden = false
        } else {
            currentImageView.isHidden = false
            maxImageView.isHidden = false
            currentLabel.isHidden = false
            tipLabel.isHidden = true

            currentLabel.text = currect.utToString() + " Quota/" + max.utToString() + " Quota"

            let mu = currect / max

            currentImageView.snp.remakeConstraints { (m) in
                m.left.top.bottom.equalTo(maxImageView)
                m.width.equalTo(maxImageView).multipliedBy(mu)
            }

            GCD.delay(0.01) {
                self.currentImageView.backgroundColor = UIColor.gradientColor(style: .left2right,
                                                                              frame: self.frame,
                                                                              colors: [UIColor(netHex: 0x2A7FFF),
                                                                                       UIColor(netHex: 0x54B6FF)])
            }
        }
    }

    
}
