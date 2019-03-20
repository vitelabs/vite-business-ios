//
//  ConfirmVitePledgeViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/13.
//

import UIKit

struct ConfirmVitePledgeViewModel: ConfirmViewModelType {

    private let tokenInfo: TokenInfo
    private let beneficialAddressString: String
    private let amountString: String

    init(tokenInfo: TokenInfo, beneficialAddressString: String, amountString: String) {
        self.tokenInfo = tokenInfo
        self.beneficialAddressString = beneficialAddressString
        self.amountString = amountString
    }

    var confirmTitle: String {
        return R.string.localizable.confirmTransactionPagePledgeTitle()
    }
    var biometryConfirmButtonTitle: String {
        return R.string.localizable.confirmTransactionPageConfirmButton()
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

        infoView.set(title: R.string.localizable.quotaManagePageInputAddressTitle(), detail: beneficialAddressString, tokenInfo: tokenInfo)
        amountView.set(text: amountString)

        return stackView
    }
}
