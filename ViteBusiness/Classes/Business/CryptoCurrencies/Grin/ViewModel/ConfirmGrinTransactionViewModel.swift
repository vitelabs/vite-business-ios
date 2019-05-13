//
//  ConfirmGrinTransactionViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/13.
//

import UIKit

class ConfirmGrinTransactionViewModel: ConfirmViewModelType {

    private let feeString: String
    private let amountString: String

    init(amountString: String, feeString: String) {
        self.amountString = amountString
        self.feeString = feeString
    }

    var confirmTitle: String {
        return R.string.localizable.confirmTransactionPageGrinTransferTitle()
    }
    var biometryConfirmButtonTitle: String {
        return R.string.localizable.confirmTransactionPageGrinConfirmButton()
    }

    func createInfoView() -> UIView {
        let stackView = UIStackView().then {
            $0.axis = .vertical
            $0.alignment = .fill
            $0.distribution = .fill
            $0.spacing = 0
        }

        let amountView = ConfirmAmountView(type: .amount)
        let feeView = ConfirmAmountView(type: .fee)

        stackView.addPlaceholder(height: 8)
        stackView.addArrangedSubview(amountView)
        stackView.addArrangedSubview(feeView)

        amountView.set(text: amountString)
        feeView.set(text: feeString)

        return stackView
    }

}
