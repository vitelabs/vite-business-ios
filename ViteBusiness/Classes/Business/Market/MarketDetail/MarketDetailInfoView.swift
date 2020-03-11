//
//  MarketDetailInfoView.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/11.
//

import UIKit

class MarketDetailInfoView: UIView {

    let priceLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x000000)
    }

    let plegalPriceLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x000000)
    }

    let percentLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x000000)
    }

    let highLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x000000)
    }

    let lowLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x000000)
    }

    let quantityLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        $0.textColor = UIColor(netHex: 0x000000)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(priceLabel)
        addSubview(plegalPriceLabel)
        addSubview(percentLabel)
        addSubview(highLabel)
        addSubview(lowLabel)
        addSubview(quantityLabel)


        backgroundColor = .red
        snp.makeConstraints { (m) in
            m.height.equalTo(100)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
