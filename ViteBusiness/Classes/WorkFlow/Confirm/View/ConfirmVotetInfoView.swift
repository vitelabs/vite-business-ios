//
//  ConfirmVotetInfoView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/13.
//

import UIKit

class ConfirmVotetInfoView: UIView {

    fileprivate let titleLabel = UILabel().then {
        $0.text = R.string.localizable.confirmTransactionAddressTitle()
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = UIColor.init(netHex: 0x3E4A59, alpha: 0.7)
    }

    fileprivate let detailLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = UIColor.init(netHex: 0x24272B, alpha: 0.7)
        $0.numberOfLines = 2
        $0.adjustsFontSizeToFitWidth = true
    }

    fileprivate let tokenIconView = TokenIconView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(detailLabel)
        addSubview(tokenIconView)


        titleLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
            m.leading.equalToSuperview().offset(24)
            m.trailing.equalToSuperview().offset(-24)
        }

        detailLabel.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(24)
            m.top.equalTo(titleLabel.snp.bottom).offset(12)
            m.bottom.equalToSuperview()
        }

        tokenIconView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().offset(-24)
            make.leading.equalTo(detailLabel.snp.trailing).offset(16)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
    }

    func set(title: String, detail: String, tokenInfo: TokenInfo) {
        titleLabel.text = title
        detailLabel.text = detail
        tokenIconView.tokenInfo = tokenInfo
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
