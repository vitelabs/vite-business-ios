//
//  DexAssetsHomeHeaderViewCell.swift
//  ViteBusiness
//
//  Created by Stone on 2020/8/26.
//

import Foundation

class DexAssetsHomeHeaderViewCell: BaseTableViewCell {

    let valuationTitleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
        $0.text = R.string.localizable.dexHomePageHeaderBtcValuationTitle()
    }

    let btcLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x24272B)
        $0.text = "dfsafdsaffdsafdsafdsaf"
    }

    let legalLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor(netHex: 0x3E4A59, alpha: 0.7)
        $0.text = "≈¥496,947,904,51fdsfsdfs"
    }

    let addressButton = UIButton().then {
        $0.setTitleColor(UIColor(netHex: 0x3E4A59, alpha: 0.45), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x3E4A59, alpha: 0.3), for: .highlighted)
        $0.setImage(R.image.icon_dex_home_address_arrows(), for: .normal)
        $0.setImage(R.image.icon_dex_home_address_arrows()?.highlighted, for: .highlighted)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        $0.titleLabel?.lineBreakMode = .byTruncatingMiddle
        $0.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.titleLabel?.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: -20)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 26)
        $0.backgroundColor = UIColor(netHex: 0xF1F8FF)
        $0.layer.cornerRadius = 2
        $0.layer.masksToBounds = true
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(netHex: 0x007AFF, alpha: 0.06).cgColor
        $0.setTitle("dsfsdafsdafsdfjsafkdhsafjkdsafdjskadfsalfk", for: .normal)
    }

    let transferButton = UIButton().then {
        $0.setTitle(R.string.localizable.dexHomePageHeaderButtonTransferTitle(), for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)
        $0.setBackgroundImage(R.image.icon_trading_segment_selected_fram()?.resizable, for: .normal)
        $0.setBackgroundImage(R.image.icon_trading_segment_selected_fram()?.highlighted.resizable, for: .highlighted)
    }

    let depositButton = UIButton().then {
        $0.setTitle(R.string.localizable.dexHomePageHeaderButtonDepositTitle(), for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)
        $0.setBackgroundImage(R.image.icon_trading_segment_selected_fram()?.resizable, for: .normal)
        $0.setBackgroundImage(R.image.icon_trading_segment_selected_fram()?.highlighted.resizable, for: .highlighted)
    }

    let withdrawButton = UIButton().then {
        $0.setTitle(R.string.localizable.dexHomePageHeaderButtonWithdrawTitle(), for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)
        $0.setBackgroundImage(R.image.icon_trading_segment_selected_fram()?.resizable, for: .normal)
        $0.setBackgroundImage(R.image.icon_trading_segment_selected_fram()?.highlighted.resizable, for: .highlighted)
    }

    let hideButton = UIButton().then {
        $0.setTitleColor(UIColor(netHex: 0x3E4A59, alpha: 0.45), for: .normal)
        $0.setImage(R.image.icon_dex_home_hide(), for: .normal)
        $0.setImage(R.image.icon_dex_home_hide_selected()?.highlighted, for: .selected)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
        $0.setTitle(R.string.localizable.dexHomePageHeaderButtonHideSmallTitle(), for: .normal)
    }

    let sortButton = UIButton().then {
        $0.setImage(R.image.icon_dex_home_sort(), for: .normal)
        $0.setImage(R.image.icon_dex_home_sort_selected()?.highlighted, for: .selected)
    }

    let type: DexAssetsHomeViewController.PType
    init(type: DexAssetsHomeViewController.PType) {
        self.type = type
        super.init(style: .default, reuseIdentifier: nil)


        contentView.addSubview(valuationTitleLabel)
        contentView.addSubview(btcLabel)
        contentView.addSubview(legalLabel)
        contentView.addSubview(addressButton)

        valuationTitleLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(16)
            m.left.right.equalToSuperview().inset(24)
        }

        btcLabel.snp.makeConstraints { (m) in
            m.top.equalTo(valuationTitleLabel.snp.bottom).offset(8)
            m.left.equalToSuperview().offset(24)
        }

        legalLabel.snp.makeConstraints { (m) in
            m.bottom.equalTo(btcLabel)
            m.left.equalTo(btcLabel.snp.right).offset(6)
            m.right.equalToSuperview().offset(-24)
        }

        btcLabel.setContentHuggingPriority(.required, for: .horizontal)
        btcLabel.setContentCompressionResistancePriority(.required, for: .horizontal)


        addressButton.snp.makeConstraints { (m) in
            m.top.equalTo(btcLabel.snp.bottom).offset(8)
            m.left.right.equalToSuperview().inset(24)
            m.height.equalTo(30)
        }

        contentView.addSubview(transferButton)
        contentView.addSubview(depositButton)
        contentView.addSubview(withdrawButton)

        transferButton.snp.makeConstraints { (m) in
            m.top.equalTo(addressButton.snp.bottom).offset(14)
            m.left.equalToSuperview().inset(24)
            m.height.equalTo(26)
        }

        depositButton.snp.makeConstraints { (m) in
            m.top.bottom.width.equalTo(transferButton)
            m.left.equalTo(transferButton.snp.right).offset(29)
            m.right.equalTo(withdrawButton.snp.left).offset(-29)
        }

        withdrawButton.snp.makeConstraints { (m) in
            m.top.bottom.width.equalTo(transferButton)
            m.right.equalToSuperview().offset(-24)
        }

        let separator = UIView()
        separator.backgroundColor = UIColor(netHex: 0xF3F5F9)
        contentView.addSubview(separator)

        separator.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview()
            m.bottom.equalToSuperview().offset(-35)
            m.height.equalTo(10)
        }

        contentView.addSubview(hideButton)
        contentView.addSubview(sortButton)

        hideButton.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(24)
            m.centerY.equalTo(sortButton)
        }

        sortButton.snp.makeConstraints { (m) in
            m.right.equalToSuperview().offset(-24)
            m.bottom.equalToSuperview()
        }

        if type == .vitex {
            depositButton.isHidden = true
            withdrawButton.isHidden = true
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
