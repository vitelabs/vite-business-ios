//
//  MarketPairFlagView.swift
//  ViteBusiness
//
//  Created by Stone on 2020/7/23.
//

import Foundation

class MarketPairFlagView: UIView {

    enum FeeType {
        case large
        case small
        case hide
    }
    let typeView = UIImageView()
    let numLabel = UILabel().then {
        $0.textColor = UIColor(netHex: 0x007AFF)
        $0.font = UIFont.systemFont(ofSize: 11, weight: .regular)
    }
    let feeView = UIImageView(image: R.image.icon_market_zero_fee())

    let feeType: FeeType
    init(feeType: FeeType) {

        self.feeType = feeType

        super.init(frame: .zero)

        addSubview(typeView)
        addSubview(numLabel)
        addSubview(feeView)

        typeView.isHidden = true
        numLabel.isHidden = true
        feeView.isHidden = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(_ marketInfo: MarketInfo?) {

        if let marketInfo = marketInfo {
            let showType = marketInfo.miningType != .none
            let showNum = (marketInfo.miningMultiples.isNotEmpty && (marketInfo.miningType == .order || marketInfo.miningType == .both))
            let showFee = (marketInfo.isZeroFee && feeType != .hide)

            switch marketInfo.miningType {
            case .none:
                break
            case .trade:
                typeView.image = R.image.market_mining_trade()
            case .order:
                typeView.image = showNum ? R.image.market_mining_order_num() : R.image.market_mining_order()
                numLabel.text = marketInfo.miningMultiples
            case .both:
                typeView.image = showNum ? R.image.market_mining_both_num() : R.image.market_mining_both()
                numLabel.text = marketInfo.miningMultiples
            }

            if showType {
                typeView.snp.remakeConstraints { (m) in
                    m.top.bottom.left.equalToSuperview()
                    if !showFee {
                        m.right.equalToSuperview()
                    }
                }
                typeView.isHidden = false
            } else {
                typeView.snp.removeConstraints()
                typeView.isHidden = true
            }

            if showNum {
                if marketInfo.miningMultiples.count > 1 {
                    numLabel.snp.remakeConstraints { (m) in
                        m.top.equalTo(typeView).offset(-1)
                        m.right.equalTo(typeView)
                    }
                } else {
                    numLabel.snp.remakeConstraints { (m) in
                        m.top.equalTo(typeView).offset(-1)
                        m.right.equalTo(typeView).offset(-5)
                    }
                }
                numLabel.isHidden = false
            } else {
                numLabel.snp.removeConstraints()
                numLabel.isHidden = true
            }

            if showFee {
                feeView.snp.remakeConstraints { (m) in
                    m.top.right.equalToSuperview()
                    m.bottom.equalToSuperview().offset(-6)
                    if showType {
                        m.left.equalTo(typeView.snp.right).offset(feeType == .large ? 4 : 2)
                    } else {
                        m.left.equalToSuperview()
                    }
                }
                feeView.isHidden = false
            } else {
                feeView.snp.removeConstraints()
                feeView.isHidden = true
            }
        } else {
            typeView.snp.removeConstraints()
            numLabel.snp.removeConstraints()
            feeView.snp.removeConstraints()
            typeView.isHidden = true
            numLabel.isHidden = true
            feeView.isHidden = true
        }
    }
}
