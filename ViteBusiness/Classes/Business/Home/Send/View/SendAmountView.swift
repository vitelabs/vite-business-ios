//
//  SendAmountView.swift
//  Vite
//
//  Created by Stone on 2018/9/25.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import BigInt
import ViteWallet

class SendAmountView: UIView {

    let titleLabel = UILabel().then {
        $0.textColor = Colors.titleGray
        $0.font = AppStyle.formHeader.font
    }

    let allButton = UIButton().then {
        $0.setTitle(R.string.localizable.ethViteExchangePageExchangeAllButtonTitle(), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x007AFF), for: .normal)
        $0.setTitleColor(UIColor(netHex: 0x007AFF).highlighted, for: .highlighted)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)

        let lineImageView = UIImageView(image: R.image.blue_dotted_line()?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .tile))

        $0.addSubview(lineImageView)
        let titleLabel = $0.titleLabel!
        lineImageView.snp.makeConstraints { (m) in
            m.left.right.equalToSuperview()
            m.bottom.equalTo(titleLabel).offset(2)
        }
    }

    let textField = UITextField().then {
        $0.font = AppStyle.descWord.font
    }

    let symbolLabel = UILabel().then {
        $0.textColor = UIColor(hex: "3E4A59", alpha: 0.7)
        $0.font = AppStyle.descWord.font
        $0.textAlignment = .right
    }

    let separatorLine = UIView().then {
        $0.backgroundColor = Colors.lineGray
    }

    let token: TokenInfo

    init(amount: String, token: TokenInfo) {
        let symbol = ""
        self.token = token
        super.init(frame: CGRect.zero)

        let canEdit = amount.isEmpty
        isUserInteractionEnabled = canEdit

        titleLabel.text = R.string.localizable.sendPageAmountTitle()
        textField.text = amount
        symbolLabel.text = symbol

        addSubview(titleLabel)
        addSubview(textField)
        addSubview(symbolLabel)
        addSubview(separatorLine)

        separatorLine.snp.makeConstraints { (m) in
            m.height.equalTo(CGFloat.singleLineWidth)
            m.left.equalTo(self)
            m.right.equalTo(self)
            m.bottom.equalTo(self)
        }

        if canEdit {

            titleLabel.snp.makeConstraints { (m) in
                m.top.equalTo(self).offset(20)
                m.left.equalTo(self)
                m.right.equalTo(self)
            }

            textField.textColor = Colors.cellTitleGray
            textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
            textField.snp.makeConstraints { (m) in
                m.left.equalTo(titleLabel)
                m.top.equalTo(titleLabel.snp.bottom).offset(10)
                m.bottom.equalTo(self).offset(-10)
            }

            symbolLabel.snp.makeConstraints { (m) in
                m.left.equalTo(textField.snp.right).offset(10)
                m.right.equalTo(titleLabel)
                m.centerY.equalTo(textField)
            }

            addSubview(allButton)
            allButton.snp.makeConstraints { (m) in
                m.centerY.equalTo(titleLabel)
                m.right.equalTo(self)
            }


        } else {

            titleLabel.snp.makeConstraints { (m) in
                m.top.equalTo(self).offset(20)
                m.left.equalTo(self)
                m.bottom.equalTo(self).offset(-20)
            }

            textField.textColor = Colors.titleGray
            textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            textField.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            textField.snp.makeConstraints { (m) in
                m.left.equalTo(titleLabel.snp.right).offset(10)
                m.centerY.equalTo(titleLabel)
            }

            symbolLabel.snp.makeConstraints { (m) in
                m.left.equalTo(textField.snp.right).offset(10)
                m.right.equalTo(self)
                m.centerY.equalTo(titleLabel)
            }
        }

        textField.rx.text.bind { [weak self] text in
            self?.calcPrice()
        }
        .disposed(by: rx.disposeBag)


    }

    func calcPrice() {
        let rateMap = ExchangeRateManager.instance.rateMap
        if let amount = textField.text?.toAmount(decimals: self.token.decimals) {
            self.symbolLabel.text = "≈" + rateMap.priceString(for: self.token, balance: amount)
        } else {
            self.symbolLabel.text = "≈ 0.0"
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
