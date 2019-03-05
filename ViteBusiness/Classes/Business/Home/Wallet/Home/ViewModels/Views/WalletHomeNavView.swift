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
        $0.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.numberOfLines = 1
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

        image = R.image.icon_wallet_home_nav_bg()
        isUserInteractionEnabled = true
        contentMode = .scaleAspectFill

        addSubview(nameLabel)
        addSubview(priceLabel)
        addSubview(hideButton)

        priceLabel.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(24)
            m.bottom.equalToSuperview().offset(-28)
            m.right.lessThanOrEqualToSuperview().offset(-62)
        }

        hideButton.snp.makeConstraints { (m) in
            m.left.equalTo(priceLabel.snp.right)
            m.top.bottom.equalTo(priceLabel)
            m.width.equalTo(28)
        }

        nameLabel.snp.makeConstraints { (m) in
            m.top.equalTo(self.safeAreaLayoutGuideSnpTop).offset(-32)
            m.left.equalTo(priceLabel)
            m.right.equalToSuperview().offset(-76)
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
