//
//  AddressManageAddressViewModel.swift
//  Vite
//
//  Created by Stone on 2018/9/13.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit

class AddressManageAddressViewModel: AddressManageAddressViewModelType {

    let number: Int
    let name: String
    let address: String
    let isSelected: Bool

    init(number: Int, name: String, address: String, isSelected: Bool) {
        self.number = number
        self.name = name
        self.address = address
        self.isSelected = isSelected
    }

    func copy() {
        UIPasteboard.general.string = address
        Toast.show(R.string.localizable.walletHomeToastCopyAddress(), duration: 1.0)
    }
}
