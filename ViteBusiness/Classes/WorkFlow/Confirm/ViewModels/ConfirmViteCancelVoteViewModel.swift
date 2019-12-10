//
//  ConfirmViteCancelVoteViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/13.
//

import UIKit

struct ConfirmViteCancelVoteViewModel: ConfirmViewModelType {

    private let tokenInfo: TokenInfo
    private let name: String
    private let utString: String?
    
    init(tokenInfo: TokenInfo, name: String, utString: String?) {
        self.tokenInfo = tokenInfo
        self.name = name
        self.utString = utString
    }

    var confirmTitle: String {
        return R.string.localizable.confirmTransactionPageViteCancelVoteTransferTitle()
    }
    var biometryConfirmButtonTitle: String {
        return R.string.localizable.confirmTransactionPageViteCancelVoteConfirmButton()
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

        infoView.set(title: R.string.localizable.confirmTransactionPageViteVoteNodeName(), detail: name, tokenInfo: tokenInfo)

        if let utString = utString {
            let quotaView = ConfirmAmountView(type: .quota)
            quotaView.set(text: utString)
            stackView.addPlaceholder(height: 15)
            stackView.addArrangedSubview(quotaView)
        }
        
        return stackView
    }
}
