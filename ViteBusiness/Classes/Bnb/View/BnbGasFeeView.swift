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

public class BnbGasFeeView: UIView {
    lazy var totalGasFeeTitleLab = UILabel().then {(totalGasFeeTitleLab) in
        totalGasFeeTitleLab.textColor = UIColor(netHex: 0x3E4A59)
        totalGasFeeTitleLab.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        totalGasFeeTitleLab.text = R.string.localizable.bnbSendPageFeeViewTitleLabelTitle()
    }

    lazy var totalGasFeeLab = UILabel().then {(totalGasFeeLab) in
        totalGasFeeLab.textColor = UIColor(netHex: 0x3E4A59,alpha: 0.7)
        totalGasFeeLab.font = UIFont.systemFont(ofSize: 16, weight: .regular)
    }

    let separatorLine = UIView().then {
        $0.backgroundColor = Colors.lineGray
    }

    init() {
        super.init(frame: CGRect.zero)
        self.backgroundColor = .clear

        self.addSubview(totalGasFeeTitleLab)
        totalGasFeeTitleLab.snp.makeConstraints({ (m) in
            m.left.top.equalToSuperview()
            m.bottom.equalToSuperview().offset(-6)
            m.height.equalTo(60)
        })

        self.addSubview(totalGasFeeLab)
        totalGasFeeLab.snp.makeConstraints({ (m) in
            m.right.top.equalToSuperview()
            m.bottom.equalToSuperview().offset(-6)
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
