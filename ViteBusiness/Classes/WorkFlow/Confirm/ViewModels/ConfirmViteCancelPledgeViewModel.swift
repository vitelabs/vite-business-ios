//
//  ConfirmViteCancelPledgeViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/13.
//

import UIKit

struct ConfirmViteCancelPledgeViewModel: ConfirmViewModelType {

    private let tokenInfo: TokenInfo
    private let beneficialAddressString: String
    private let amountString: String
    private let utString: String?

    init(tokenInfo: TokenInfo, beneficialAddressString: String, amountString: String, utString: String?) {
        self.tokenInfo = tokenInfo
        self.beneficialAddressString = beneficialAddressString
        self.amountString = amountString
        self.utString = utString
    }

    var confirmTitle: String {
        return R.string.localizable.confirmTransactionPageViteCancelPledgeTitle()
    }
    var biometryConfirmButtonTitle: String {
        return R.string.localizable.confirmTransactionPageVitePledgeConfirmButton()
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

        if let utString = utString {
            let quotaView = ConfirmAmountView(type: .quota)
            quotaView.set(text: utString)
            stackView.addArrangedSubview(quotaView)
        }
        
        return stackView
    }
}
