//
//  ConfirmViteDexCancelVipViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/13.
//

import UIKit

struct ConfirmViteDexCancelVipViewModel: ConfirmViewModelType {


    var confirmTitle: String {
        return R.string.localizable.confirmTransactionPageViteDexCancelVipTitle()
    }
    var biometryConfirmButtonTitle: String {
        return R.string.localizable.confirmTransactionPageViteDexCancelVipConfirmButton()
    }

    func createInfoView() -> UIView {
        let stackView = UIStackView().then {
            $0.axis = .vertical
            $0.alignment = .fill
            $0.distribution = .fill
            $0.spacing = 0
        }

        return stackView
    }
}
