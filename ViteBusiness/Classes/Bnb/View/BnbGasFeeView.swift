//
//  BnbGasFeeView.swift
//  ViteBusiness
//
//  Created by Water on 2019/7/8.
//

import UIKit
import SnapKit
import BigInt
import web3swift
import ViteWallet
import ViteEthereum

public class BnbGasFeeView: UIView {
    lazy var totalGasFeeTitleLab = UILabel().then {(totalGasFeeTitleLab) in
        totalGasFeeTitleLab.textColor = UIColor(netHex: 0x3E4A59)
        totalGasFeeTitleLab.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        totalGasFeeTitleLab.text = "矿工费用"
    }

    lazy var totalGasFeeLab = UILabel().then {(totalGasFeeLab) in
        totalGasFeeLab.textColor = UIColor(netHex: 0x24272B)
        totalGasFeeLab.font = UIFont.systemFont(ofSize: 14, weight: .regular)
    }

    let separatorLine = UIView().then {
        $0.backgroundColor = Colors.lineGray
    }

    init() {
        super.init(frame: CGRect.zero)

        self.addSubview(totalGasFeeTitleLab)
        totalGasFeeTitleLab.snp.makeConstraints({ (m) in
            m.top.bottom.left.centerY.equalToSuperview()
            m.height.equalTo(60)
        })

        self.addSubview(totalGasFeeLab)
        totalGasFeeLab.snp.makeConstraints({ (m) in
            m.top.bottom.right.centerY.equalToSuperview()
            m.height.equalTo(60)
        })

        addSubview(separatorLine)
        separatorLine.snp.makeConstraints { (m) in
            m.height.equalTo(CGFloat.singleLineWidth)
            m.left.right.bottom.equalTo(self)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}