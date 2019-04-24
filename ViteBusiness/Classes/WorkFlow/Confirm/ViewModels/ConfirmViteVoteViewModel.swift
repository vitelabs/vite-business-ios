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
        return R.string.localizable.vote()
    }
    var biometryConfirmButtonTitle: String {
        return R.string.localizable.voteListConfirmButtonTitle()
    }

    func createInfoView() -> UIView {
        let infoView = ConfirmVotetInfoView()
        infoView.set(title: R.string.localizable.confirmTransactionPageNodeName(), detail: name, tokenInfo: tokenInfo)
        return infoView
    }
}
