//
//  WalletHomeNavView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/5.
//

import UIKit
import SnapKit
import Then

class WalletHomeNavView: UIImageView {

    fileprivate let nameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = UIColor(netHex: 0x24272B)
        $0.numberOfLines = 1
    }

    fileprivate let priceLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.numberOfLines = 1
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

        backgroundColor = UIColor.white
        layer.shadowColor = UIColor(netHex: 0x000000).cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowRadius = 20

        contentMode = .scaleToFill
        image = R.image.icon_wallet_home_nav_bg()
        isUserInteractionEnabled = true

        addSubview(nameLabel)
        addSubview(priceLabel)
        addSubview(scanButton)
        addSubview(hideButton)

        priceLabel.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(24)
            m.bottom.equalToSuperview().offset(-28)
            m.right.equalToSuperview().offset(-76)
        }

        hideButton.snp.makeConstraints { (m) in
            m.left.equalTo(nameLabel.snp.right)
            m.top.bottom.equalTo(nameLabel)
            m.width.equalTo(28)
        }

        nameLabel.snp.makeConstraints { (m) in
            m.left.equalTo(priceLabel)
            m.right.lessThanOrEqualToSuperview().offset(-72)
            m.centerY.equalTo(scanButton)
        }

        scanButton.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-20)
            m.bottom.equalToSuperview().offset(-74)
            m.size.equalTo(CGSize(width: 28, height: 28))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(viewModel: WalletHomeNavViewModel) {
        viewModel.walletNameDriver.drive(nameLabel.rx.text).disposed(by: rx.disposeBag)
        viewModel.priceDriver.drive(priceLabel.rx.text).disposed(by: rx.disposeBag)

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
