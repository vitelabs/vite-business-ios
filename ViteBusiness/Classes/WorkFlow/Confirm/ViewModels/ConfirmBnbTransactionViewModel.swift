//
//  ConfirmBnbTransactionViewModel.swift
//  ViteBusiness
//
//  Created by Water on 2019/7/4.
//

import UIKit

struct ConfirmBnbTransactionViewModel: ConfirmViewModelType {

    private let tokenInfo: TokenInfo
    private let addressString: String
    private let feeString: String
    private let amountString: String

    init(tokenInfo: TokenInfo, addressString: String, amountString: String, feeString: String) {
        self.tokenInfo = tokenInfo
        self.addressString = addressString
        self.amountString = amountString
        self.feeString = feeString
    }

    var confirmTitle: String {
        return R.string.localizable.confirmTransactionPageEthTransferTitle()
    }
    var biometryConfirmButtonTitle: String {
        return R.string.localizable.confirmTransactionPageEthConfirmButton()
    }

    func createInfoView() -> UIView {
        let stackView = UIStackView().then {
            $0.axis = .vertical
            $0.alignment = .fill
            $0.distribution = .fill
            $0.spacing = 0
        }

        let infoView = ConfirmDefaultInfoView()
        let amountView = ConfirmAmountView(type: .amount)
        let feeView = ConfirmAmountView(type: .fee)

        stackView.addArrangedSubview(infoView)
        stackView.addPlaceholder(height: 15)
        stackView.addArrangedSubview(amountView)
        stackView.addArrangedSubview(feeView)

        infoView.set(title: R.string.localizable.confirmTransactionAddressTitle(), detail: addressString, tokenInfo: tokenInfo)
        amountView.set(text: amountString)
        feeView.set(text: feeString)

        return stackView
    }
}

