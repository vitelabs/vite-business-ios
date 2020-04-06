//
//  SpotOrdersHeaderView.swift
//  ViteBusiness
//
//  Created by Stone on 2020/4/6.
//

import Foundation

class SpotOrdersHeaderView: UIView {

    static let height: CGFloat = 33

    let titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x3E4A59)
        $0.text = R.string.localizable.spotPageCurrentOrderTitle()
    }

    let historyButton = UIButton().then {
        $0.setTitleColor(UIColor(netHex: 0x3E4A59, alpha: 0.7), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x3E4A59, alpha: 0.7).highlighted, for: .highlighted)
        $0.setImage(R.image.icon_spot_history_arrows(), for: .normal)
        $0.setImage(R.image.icon_spot_history_arrows()?.highlighted, for: .highlighted)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.titleLabel?.adjustsFontSizeToFitWidth = true
        $0.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.titleLabel?.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
        $0.setTitle(R.string.localizable.spotPageOrdersButtonTitle(), for: .normal)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)
        addSubview(historyButton)

        titleLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(16)
            m.left.equalToSuperview().offset(24)
            m.bottom.equalToSuperview()
        }

        historyButton.snp.makeConstraints { (m) in
            m.centerY.equalTo(titleLabel)
            m.right.equalToSuperview().offset(-24)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
