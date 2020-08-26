//
//  WalletHomeNavView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/5.
//

import UIKit
import SnapKit
import Then
import PPBadgeViewSwift

class WalletHomeNavView: UIImageView {

    fileprivate let nameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.numberOfLines = 1
        $0.textAlignment = .center
    }

    fileprivate let btcLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.numberOfLines = 1
    }

    fileprivate let priceLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
        $0.numberOfLines = 1
    }

    let myButton = UIButton().then {
        $0.setImage(R.image.icon_nav_mine(), for: .normal)
        $0.setImage(R.image.icon_nav_mine()?.highlighted, for: .highlighted)
        $0.pp.addBadge(text: nil)
        $0.pp.moveBadge(x: -5, y: 5)
        $0.pp.setBadge(height: 4.0)
        $0.pp.base.badgeView.backgroundColor = UIColor(netHex: 0xFF0008)
    }

    let scanButton = UIButton().then {
        $0.setImage(R.image.icon_nav_scan_black(), for: .normal)
        $0.setImage(R.image.icon_nav_scan_black()?.highlighted, for: .highlighted)
    }

    let hideButton = UIButton().then {
        $0.setImage(R.image.icon_price_show_button(), for: .normal)
        $0.setImage(R.image.icon_price_show_button()?.highlighted, for: .highlighted)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let titleLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
            $0.numberOfLines = 1
            $0.text = R.string.localizable.walletHomeBtcTitle()
        }

        contentMode = .scaleToFill
        image = R.image.icon_wallet_home_nav_bg()
        isUserInteractionEnabled = true

        addSubview(titleLabel)
        addSubview(hideButton)
        addSubview(btcLabel)
        addSubview(priceLabel)

        addSubview(nameLabel)
        addSubview(myButton)
        addSubview(scanButton)


        titleLabel.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(24)
            m.top.equalTo(myButton.snp.bottom).offset(16)
        }

        hideButton.snp.makeConstraints { (m) in
            m.left.equalTo(titleLabel.snp.right)
            m.centerY.equalTo(titleLabel)
            m.width.equalTo(28)
        }

        btcLabel.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview().inset(24)
            m.top.equalTo(titleLabel.snp.bottom).offset(10)
        }

        priceLabel.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview().inset(24)
            m.top.equalTo(btcLabel.snp.bottom).offset(4)
        }

        nameLabel.snp.makeConstraints { (m) in
            m.left.equalTo(myButton.snp.right).offset(10)
            m.right.equalTo(scanButton.snp.left).offset(-10)
            m.centerY.equalTo(scanButton)
        }

        myButton.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(20)
            m.bottom.equalToSuperview().offset(-108)
            m.size.equalTo(CGSize(width: 28, height: 28))
        }

        scanButton.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-20)
            m.bottom.equalToSuperview().offset(-108)
            m.size.equalTo(CGSize(width: 28, height: 28))
        }

        DispatchQueue.main.async {
            AppSettingsService.instance.appSettingsDriver.map{ $0.guide.vitexInvite}.distinctUntilChanged().drive(onNext: { [weak self] (ret) in
                if ret {
                    self?.myButton.pp.showBadge()
                } else {
                    self?.myButton.pp.hiddenBadge()
                }
            }).disposed(by: self.rx.disposeBag)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(viewModel: WalletHomeNavViewModel) {
        viewModel.walletNameDriver.drive(nameLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.priceDriver.map{ $0.0 }.drive(btcLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.priceDriver.map{ $0.1 }.drive(priceLabel.rx.text).disposed(by: rx.disposeBag)

        btcLabel.text = "dfsadfsdaf"

        viewModel.isHidePriceDriver.drive(onNext: { [weak self] (isHide) in
            if isHide {
                self?.hideButton.setImage(R.image.icon_price_hide_button(), for: .normal)
                self?.hideButton.setImage(R.image.icon_price_hide_button()?.highlighted, for: .highlighted)
            } else {
                self?.hideButton.setImage(R.image.icon_price_show_button(), for: .normal)
                self?.hideButton.setImage(R.image.icon_price_show_button()?.highlighted, for: .highlighted)
            }
        }).disposed(by: rx.disposeBag)
    }
}
