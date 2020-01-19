//
//  MyDeFiLoanHeaderView.swift
//  ViteBusiness
//
//  Created by Stone on 2019/12/2.
//

import UIKit

class MyDeFiSubscribeHeaderView: UIView {

    let bgView = UIView()
    let bgImageView = UIImageView(image: R.image.my_defi_amount_bg())

    let issuedTitleLabel = UILabel().then {
        $0.textColor = UIColor.white.withAlphaComponent(0.7)
        $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        $0.text = R.string.localizable.defiMyPageMySubscribeIssuedEarnings()
    }

    let predictTitleLabel = UILabel().then {
        $0.textColor = UIColor.white.withAlphaComponent(0.7)
        $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        $0.text = R.string.localizable.defiMyPageMySubscribePredictAmount()
    }

    let subscribeTitleLabel = UILabel().then {
        $0.textColor = UIColor.white.withAlphaComponent(0.7)
        $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        $0.text = R.string.localizable.defiMyPageMySubscribeSubscribeAmount()
    }

    let rateTitleLabel = UILabel().then {
        $0.textColor = UIColor.white.withAlphaComponent(0.7)
        $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        $0.text = R.string.localizable.defiMyPageMySubscribeEarningsRate()
    }

    let issuedLabel = UILabel().then {
        $0.textColor = UIColor.white
        $0.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        $0.text = "-- VITE"
    }

    let predictLabel = UILabel().then {
        $0.textColor = UIColor.white
        $0.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        $0.text = "-- VITE"
    }

    let subscribeLabel = UILabel().then {
        $0.textColor = UIColor.white
        $0.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        $0.text = "-- VITE"
    }

    let rateLabel = UILabel().then {
        $0.textColor = UIColor.white
        $0.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        $0.text = "--%"
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(bgView)
        bgView.addSubview(bgImageView)
        addSubview(issuedTitleLabel)
        addSubview(predictTitleLabel)
        addSubview(subscribeTitleLabel)
        addSubview(rateTitleLabel)
        addSubview(issuedLabel)
        addSubview(predictLabel)
        addSubview(subscribeLabel)
        addSubview(rateLabel)

        let leftLayoutGuide = UILayoutGuide()
        let rightLayoutGuide = UILayoutGuide()
        addLayoutGuide(leftLayoutGuide)
        addLayoutGuide(rightLayoutGuide)

        bgView.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }

        bgImageView.snp.makeConstraints { (m) in
            m.top.bottom.right.equalToSuperview()
        }

        leftLayoutGuide.snp.makeConstraints { (m) in
            m.top.bottom.left.equalToSuperview()
        }

        rightLayoutGuide.snp.makeConstraints { (m) in
            m.top.bottom.right.equalToSuperview()
            m.left.equalTo(leftLayoutGuide.snp.right)
            m.width.equalTo(leftLayoutGuide)
        }

        issuedTitleLabel.snp.makeConstraints { (m) in
            m.top.equalTo(leftLayoutGuide).offset(14)
            m.left.equalTo(leftLayoutGuide).offset(16)
        }

        issuedLabel.snp.makeConstraints { (m) in
            m.top.equalTo(issuedTitleLabel.snp.bottom).offset(2)
            m.left.equalTo(issuedTitleLabel)
        }

        subscribeTitleLabel.snp.makeConstraints { (m) in
            m.top.equalTo(issuedLabel.snp.bottom).offset(14)
            m.left.equalTo(issuedTitleLabel)
        }

        subscribeLabel.snp.makeConstraints { (m) in
            m.top.equalTo(subscribeTitleLabel.snp.bottom).offset(2)
            m.left.equalTo(issuedTitleLabel)
        }

        predictTitleLabel.snp.makeConstraints { (m) in
            m.top.equalTo(rightLayoutGuide).offset(14)
            m.left.equalTo(rightLayoutGuide).offset(16)
        }

        predictLabel.snp.makeConstraints { (m) in
            m.top.equalTo(predictTitleLabel.snp.bottom).offset(2)
            m.left.equalTo(predictTitleLabel)
        }

        rateTitleLabel.snp.makeConstraints { (m) in
            m.top.equalTo(predictLabel.snp.bottom).offset(14)
            m.left.equalTo(predictTitleLabel)
        }

        rateLabel.snp.makeConstraints { (m) in
            m.top.equalTo(rateTitleLabel.snp.bottom).offset(2)
            m.left.equalTo(predictTitleLabel)
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
