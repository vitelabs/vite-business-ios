//
//  ConfirmViteDexPledgeForVipViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/13.
//

import UIKit

struct ConfirmViteDexPledgeForVipViewModel: ConfirmViewModelType {

    private let balanceString: String
    private let amountString: String

    init(balanceString: String, amountString: String) {
        self.balanceString = balanceString
        self.amountString = amountString
    }

    var confirmTitle: String {
        return R.string.localizable.confirmTransactionPageViteDexVipTitle()
    }
    var biometryConfirmButtonTitle: String {
        return R.string.localizable.confirmTransactionPageViteDexVipConfirmButton()
    }

    var bottomTipString: String? {
        return R.string.localizable.confirmTransactionPageViteDexVipTip()
    }

    func createInfoView() -> UIView {
        let stackView = UIStackView().then {
            $0.axis = .vertical
            $0.alignment = .fill
            $0.distribution = .fill
            $0.spacing = 0
        }

        let balanceView = ConfirmAmountView(type: .custom(title: R.string.localizable.confirmTransactionPageViteDexVipBalance(), hasBackgroundColor: true))
        let amountView = ConfirmAmountView(type: .custom(title: R.string.localizable.confirmTransactionPageViteDexVipAmount(), hasBackgroundColor: false))
        stackView.addArrangedSubview(balanceView)
        stackView.addArrangedSubview(amountView)
        balanceView.set(text: balanceString)
        amountView.set(text: amountString)

        return stackView
    }
}
