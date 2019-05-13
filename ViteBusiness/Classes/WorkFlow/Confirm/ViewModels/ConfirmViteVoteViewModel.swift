//
//  ConfirmViteVoteViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/13.
//

import UIKit

struct ConfirmViteVoteViewModel: ConfirmViewModelType {

    private let tokenInfo: TokenInfo
    private let name: String

    init(tokenInfo: TokenInfo, name: String) {
        self.tokenInfo = tokenInfo
        self.name = name
    }

    var confirmTitle: String {
        return R.string.localizable.confirmTransactionPageViteVoteTransferTitle()
    }
    var biometryConfirmButtonTitle: String {
        return R.string.localizable.confirmTransactionPageViteVoteConfirmButton()
    }

    func createInfoView() -> UIView {
        let infoView = ConfirmVotetInfoView()
        infoView.set(title: R.string.localizable.confirmTransactionPageViteVoteNodeName(), detail: name, tokenInfo: tokenInfo)
        return infoView
    }
}
