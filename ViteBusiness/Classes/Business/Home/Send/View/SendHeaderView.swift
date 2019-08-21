//
//  SendHeaderView.swift
//  Vite
//
//  Created by Stone on 2018/9/25.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import SnapKit
import ViteWallet

extension SendHeaderView {
    class ItemView: UIView {
        let titleLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x3E4A59)
            $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        }

        let textLabel = UILabel().then {
            $0.textColor = UIColor(netHex: 0x3E4A59)
            $0.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            $0.numberOfLines = 0
        }

        init(title: String? = nil, text: String? = nil) {
            super.init(frame: CGRect.zero)

            addSubview(titleLabel)
            addSubview(textLabel)

            titleLabel.text = title
            textLabel.text = text

            titleLabel.snp.makeConstraints({ (m) in
                m.top.left.right.equalToSuperview()
            })

            textLabel.snp.makeConstraints({ (m) in
                m.top.equalTo(titleLabel.snp.bottom).offset(8)
                m.left.right.bottom.equalToSuperview()
            })
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    enum ViewType {
        case send
        case pledge
    }
}

class SendHeaderView: UIView {

    let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 16
    }

    let addressView = ItemView()
    let balanceView = ItemView(title: R.string.localizable.sendPageMyBalanceTitle())
    let pledgeView = ItemView(title: R.string.localizable.sendPageMyPledgeTitle())
    let quotaView = ItemView(title: R.string.localizable.sendPageMyQuotaTitle())

    init(address: String, name: String, type: ViewType) {
        super.init(frame: CGRect.zero)

        addressView.titleLabel.text = name
        addressView.textLabel.text = address

        let contentView = self.createContentViewAndSetShadow(width: 0, height: 5, radius: 9)
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 2

        let line = UIView().then { $0.backgroundColor = UIColor(netHex: 0x759BFA) }

        contentView.addSubview(stackView)
        contentView.addSubview(line)

        stackView.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(16)
            m.left.equalToSuperview().offset(19)
            m.right.equalToSuperview().offset(-16)
            m.bottom.equalToSuperview().offset(-16)
        }

        stackView.addArrangedSubview(addressView)
        stackView.addArrangedSubview(balanceView)
        switch type {
        case .send:
            break
        case .pledge:
            stackView.addArrangedSubview(pledgeView)
        }
        stackView.addArrangedSubview(quotaView)

        line.snp.makeConstraints({ (m) in
            m.top.bottom.left.equalTo(contentView)
            m.width.equalTo(3)
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(token: Token) {

        ViteBalanceInfoManager.instance.balanceInfoDriver(forViteTokenId: token.id)
            .drive(onNext: { [weak self] balanceInfo in
                guard let `self` = self else { return }
                self.balance = balanceInfo?.balance ?? Amount(0)
                self.balanceView.textLabel.text = self.balance.amountFullWithGroupSeparator(decimals: token.decimals)
            }).disposed(by: rx.disposeBag)

        FetchQuotaManager.instance.quotaDriver
            .drive(onNext: { [weak self] (quota) in
                guard let `self` = self else { return }
                self.pledgeView.textLabel.text = quota.pledgeAmount.amountFullWithGroupSeparator(decimals: ViteWalletConst.viteToken.decimals)
                self.quotaView.textLabel.text = "\(quota.currentUt.utToString())/\(quota.utpe.utToString()) UT"
            }).disposed(by: rx.disposeBag)
    }

    fileprivate(set) var balance = Amount(0)
}
