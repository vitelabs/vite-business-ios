//
//  ConfirmViteTransactionViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/13.
//

import UIKit

struct ConfirmViteTransactionViewModel: ConfirmViewModelType {

    private let tokenInfo: TokenInfo
    private let addressString: String
    private let amountString: String

    init(tokenInfo: TokenInfo, addressString: String, amountString: String) {
        self.tokenInfo = tokenInfo
        self.addressString = addressString
        self.amountString = amountString
    }

    var confirmTitle: String {
        return R.string.localizable.confirmTransactionPageViteTransferTitle()
    }
    var biometryConfirmButtonTitle: String {
        return R.string.localizable.confirmTransactionPageViteConfirmButton()
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

        stackView.addArrangedSubview(infoView)
        stackView.addPlaceholder(height: 15)
        stackView.addArrangedSubview(amountView)

        infoView.set(title: R.string.localizable.confirmTransactionAddressTitle(), detail: addressString, tokenInfo: tokenInfo)
        amountView.set(text: amountString)

        return stackView
    }
}
