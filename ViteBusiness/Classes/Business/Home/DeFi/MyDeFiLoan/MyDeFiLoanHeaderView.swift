//
//  MyDeFiLoanHeaderView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/12/2.
//

import UIKit

class MyDeFiLoanHeaderView: UIView {

    let bgView = UIView()
    let bgImageView = UIImageView(image: R.image.my_defi_amount_bg())

    let accountTitleLabel = UILabel().then {
        $0.textColor = UIColor.white.withAlphaComponent(0.7)
        $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        $0.text = R.string.localizable.defiMyPageMyLoanAccountAmount()
    }

    let loanTitleLabel = UILabel().then {
        $0.textColor = UIColor.white.withAlphaComponent(0.7)
        $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        $0.text = R.string.localizable.defiMyPageMyLoanLoanAmount()
    }

    let accountLabel = UILabel().then {
        $0.textColor = UIColor.white
        $0.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        $0.text = "-- VITE"
    }

    let loanLabel = UILabel().then {
        $0.textColor = UIColor.white
        $0.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        $0.text = "-- VITE"
    }

    let accountButton = UIButton().then {
        $0.setImage(R.image.icon_my_defi_more(), for: .normal)
        $0.setImage(R.image.icon_my_defi_more()?.highlighted, for: .highlighted)
    }

    let loanButton = UIButton().then {
        $0.setImage(R.image.icon_my_defi_more(), for: .normal)
        $0.setImage(R.image.icon_my_defi_more()?.highlighted, for: .highlighted)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(bgView)
        bgView.addSubview(bgImageView)
        addSubview(accountTitleLabel)
        addSubview(accountLabel)
        addSubview(loanTitleLabel)
        addSubview(loanLabel)
        addSubview(accountButton)
        addSubview(loanButton)

        bgView.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }

        bgImageView.snp.makeConstraints { (m) in
            m.top.bottom.right.equalToSuperview()
        }

        accountTitleLabel.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(14)
            m.left.equalToSuperview().offset(16)
        }

        accountLabel.snp.makeConstraints { (m) in
            m.top.equalTo(accountTitleLabel.snp.bottom).offset(2)
            m.left.equalTo(accountTitleLabel)
        }

        loanTitleLabel.snp.makeConstraints { (m) in
            m.top.equalTo(accountLabel.snp.bottom).offset(14)
            m.left.equalTo(accountTitleLabel)
        }

        loanLabel.snp.makeConstraints { (m) in
            m.top.equalTo(loanTitleLabel.snp.bottom).offset(2)
            m.left.equalTo(accountTitleLabel)
        }

        accountButton.snp.makeConstraints { (m) in
            m.right.equalToSuperview()
            m.centerY.equalTo(accountTitleLabel)
            m.size.equalTo(CGSize(width: 36, height: 16))
        }

        loanButton.snp.makeConstraints { (m) in
            m.right.equalToSuperview()
            m.centerY.equalTo(loanTitleLabel)
            m.size.equalTo(CGSize(width: 36, height: 16))
        }

        self.bgView.backgroundColor = UIColor.gradientColor(style: .left2right,
                                                     frame: CGRect(origin: .zero, size: intrinsicContentSize),
                                                    colors: [UIColor(netHex: 0x2A7FFF),
                                                             UIColor(netHex: 0x54B6FF)])
        self.bgView.layer.masksToBounds = true
        self.bgView.layer.cornerRadius = 2
        self.setShadow(width: 0, height: 2, radius: 10)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: kScreenW - 24 * 2, height: 118)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
