//
//  ConfirmViteCancelVoteViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/13.
//

import UIKit

struct ConfirmViteDexBuyViewModel: ConfirmViewModelType {

    private let tokenInfo: TokenInfo
    private let addressString: String
    private let priceString: String
    private let quantityString: String
    private let utString: String?
    
    init(tokenInfo: TokenInfo, addressString: String, priceString: String, quantityString: String, utString: String?) {
        self.tokenInfo = tokenInfo
        self.addressString = addressString
        self.priceString = priceString
        self.quantityString = quantityString
        self.utString = utString
    }

    var confirmTitle: String {
        return R.string.localizable.confirmTransactionPageViteDexBuyTitle(self.tokenInfo.toViteToken()!.uniqueSymbol)
    }
    var biometryConfirmButtonTitle: String {
        return R.string.localizable.confirmTransactionPageViteDexBuyConfirmButton()
    }

    func createInfoView() -> UIView {
        let stackView = UIStackView().then {
            $0.axis = .vertical
            $0.alignment = .fill
            $0.distribution = .fill
            $0.spacing = 0
        }

        let infoView = ConfirmDefaultInfoView()

        stackView.addArrangedSubview(infoView)
        stackView.addPlaceholder(height: 15)

        infoView.set(title: R.string.localizable.contractConfirmInfo(), detail: addressString, tokenInfo: tokenInfo)

        if let utString = utString {
            let quotaView = ConfirmAmountView(type: .quota)
            quotaView.set(text: utString)
            stackView.addPlaceholder(height: 15)
            stackView.addArrangedSubview(quotaView)
        }
        
        return stackView
    }
}
