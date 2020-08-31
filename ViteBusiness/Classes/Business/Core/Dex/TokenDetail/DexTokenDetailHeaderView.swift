//
//  DexTokenDetailHeaderView.swift
//  ViteBusiness
//
//  Created by Stone on 2020/8/31.
//

import Foundation
import ViteWallet

class DexTokenDetailHeaderView: UIView {

    let tokenIconView = TokenIconView()

    let symbolLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.6)
    }

    let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 12
    }

    init(tokenInfo: TokenInfo, type: DexAssetsHomeViewController.PType) {
        super.init(frame: CGRect.zero)

        let line = UIView().then {
            $0.backgroundColor = Colors.lineGray
        }

        let view = UIView().then {
            $0.backgroundColor = UIColor(netHex: 0xF3F5F9)
        }

        let listTitleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            $0.textColor = UIColor(netHex: 0x3E4A59)
            $0.text = type == .wallet ? R.string.localizable.dexTokenDetailPageListWalletHeaterTitle() : R.string.localizable.dexTokenDetailPageListDexHeaterTitle()
        }

        addSubview(line)
        addSubview(tokenIconView)
        addSubview(symbolLabel)
        addSubview(stackView)
        addSubview(view)
        addSubview(listTitleLabel)

        tokenIconView.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(12)
            m.left.equalToSuperview().offset(24)
            m.size.equalTo(CGSize(width: 40, height: 40))
        }

        symbolLabel.snp.makeConstraints { (m) in
            m.left.equalTo(tokenIconView.snp.right).offset(12)
            m.centerY.equalTo(tokenIconView)
        }

        line.snp.makeConstraints { (m) in
            m.height.equalTo(CGFloat.singleLineWidth)
            m.left.equalToSuperview().offset(24)
            m.right.equalToSuperview().offset(-24)
            m.top.equalTo(tokenIconView.snp.bottom).offset(16)
        }

        stackView.snp.makeConstraints { (m) in
            m.top.equalTo(tokenIconView.snp.bottom).offset(32)
            m.left.right.equalToSuperview().inset(24)
        }

        view.snp.makeConstraints { (m) in
            m.top.equalTo(stackView.snp.bottom).offset(14)
            m.left.right.equalToSuperview()
            m.bottom.equalToSuperview().offset(-36)
        }

        listTitleLabel.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(24)
            m.bottom.equalToSuperview()
        }


        tokenIconView.tokenInfo = tokenInfo
        symbolLabel.text = tokenInfo.uniqueSymbol

        let total = TotalView(title: R.string.localizable.dexTokenDetailPageHeaderTotal())
        stackView.addArrangedSubview(total)

        switch type {
        case .wallet:
            ViteBalanceInfoManager.instance.balanceInfoDriver(forViteTokenId: tokenInfo.viteTokenId)
                .map { $0?.balance ?? Amount(0) }.drive(onNext: { amount in
                    total.valueLabel.text = tokenInfo.amountString(amount: amount, precision: .long)
                    total.bottomLabel.text = "≈" + tokenInfo.legalString(amount: amount)
                }).disposed(by: rx.disposeBag)
        case .vitex:
            let available = ItemView(title: R.string.localizable.dexTokenDetailPageHeaderAvailable())
            let lockPlaceOrder = ItemView(title: R.string.localizable.dexTokenDetailPageHeaderLockPlaceOrder())

            let viteVip = ItemView(title: R.string.localizable.dexTokenDetailPageHeaderLockViteVip())
            let viteMining = ItemView(title: R.string.localizable.dexTokenDetailPageHeaderLockViteMining())
            let viteMiningCancel = ItemView(title: R.string.localizable.dexTokenDetailPageHeaderLockViteMiningCancel())

            let vx = ItemView(title: R.string.localizable.dexTokenDetailPageHeaderLockVx())
            let vxCancel = ItemView(title: R.string.localizable.dexTokenDetailPageHeaderLockVxCancel())

            ViteBalanceInfoManager.instance.dexBalanceInfoDriver(forViteTokenId: tokenInfo.viteTokenId).drive(onNext: { (balance) in
                if let balance = balance {
                    total.valueLabel.text = tokenInfo.amountString(amount: balance.total, precision: .long)
                    total.bottomLabel.text = "≈" + tokenInfo.legalString(amount: balance.total)
                    available.valueLabel.text = tokenInfo.amountString(amount: balance.available, precision: .long)
                    lockPlaceOrder.valueLabel.text = tokenInfo.amountString(amount: balance.locked, precision: .long)

                    if tokenInfo.isViteCoin {
                        viteVip.valueLabel.text = tokenInfo.amountString(amount: balance.viteStakeForVip, precision: .long)
                        viteMining.valueLabel.text = tokenInfo.amountString(amount: balance.viteStakeForMining, precision: .long)
                        viteMiningCancel.valueLabel.text = tokenInfo.amountString(amount: balance.viteCancellingStakeForMining, precision: .long)
                    } else if tokenInfo.isVxToken {
                        vx.valueLabel.text = tokenInfo.amountString(amount: balance.vxLocked, precision: .long)
                        vxCancel.valueLabel.text = tokenInfo.amountString(amount: balance.vxUnlocking, precision: .long)
                    }

                } else {
                    total.valueLabel.text = tokenInfo.amountString(amount: Amount(0), precision: .long)
                    total.bottomLabel.text = "≈" + tokenInfo.legalString(amount: Amount(0))
                    available.valueLabel.text = tokenInfo.amountString(amount: Amount(0), precision: .long)
                    lockPlaceOrder.valueLabel.text = tokenInfo.amountString(amount: Amount(0), precision: .long)
                }
            })

            stackView.addArrangedSubview(available)
            stackView.addArrangedSubview(lockPlaceOrder)

            if tokenInfo.isViteCoin {
                stackView.addArrangedSubview(viteVip)
                stackView.addArrangedSubview(viteMining)
                stackView.addArrangedSubview(viteMiningCancel)
            } else if tokenInfo.isVxToken {
                stackView.addArrangedSubview(vx)
                stackView.addArrangedSubview(vxCancel)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var height: CGFloat {
        let count = CGFloat(stackView.arrangedSubviews.count) - 1
        return 84 + 37 + ((21 + 12) * count) + 14 + 10 + 36
    }
}

extension DexTokenDetailHeaderView {
    class TotalView: UIView {

        let titleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
        }

        let valueLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            $0.textColor = UIColor(netHex: 0x24272B)
        }

        let bottomLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.8)
        }

        init(title: String) {
            super.init(frame: CGRect.zero)

            titleLabel.text = title

            addSubview(titleLabel)
            addSubview(valueLabel)
            addSubview(bottomLabel)

            titleLabel.setContentHuggingPriority(.required, for: .horizontal)
            titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
            titleLabel.snp.makeConstraints { (m) in
                m.left.equalToSuperview()
                m.centerY.equalTo(valueLabel)
            }

            valueLabel.snp.makeConstraints { (m) in
                m.top.right.equalToSuperview()
                m.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(10)
            }

            bottomLabel.snp.makeConstraints { (m) in
                m.right.bottom.equalToSuperview()
            }

            self.snp.makeConstraints { (m) in
                m.height.equalTo(37)
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class ItemView: UIView {

        let titleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
        }

        let valueLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            $0.textColor = UIColor(netHex: 0x24272B)
        }

        init(title: String) {
            super.init(frame: CGRect.zero)

            titleLabel.text = title

            addSubview(titleLabel)
            addSubview(valueLabel)

            titleLabel.setContentHuggingPriority(.required, for: .horizontal)
            titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
            titleLabel.snp.makeConstraints { (m) in
                m.left.top.bottom.equalToSuperview()
            }

            valueLabel.snp.makeConstraints { (m) in
                m.top.bottom.right.equalToSuperview()
                m.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(10)
            }

            self.snp.makeConstraints { (m) in
                m.height.equalTo(21)
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
