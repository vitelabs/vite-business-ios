//
//  AddressManagerTableViewModel.swift
//  Vite
//
//  Created by Stone on 2018/9/13.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Vite_HDWalletKit

class AddressManagerTableViewModel: AddressManagerTableViewModelType {

    lazy var defaultAddressDriver: Driver<String> = HDWalletManager.instance.accountDriver.map { $0?.address.description ?? ""}
    lazy var addressesDriver: Driver<[AddressManageAddressViewModelType]> =
        Driver.combineLatest(HDWalletManager.instance.accountsDriver, HDWalletManager.instance.accountDriver)
            .map { (accounts, _) -> [AddressManageAddressViewModelType] in
                var number = 0
                return accounts.map { account -> AddressManageAddressViewModelType in
                    let isSelected = number == HDWalletManager.instance.selectBagIndex
                    number += 1
                    return AddressManageAddressViewModel(number: number, address: account.address.description, isSelected: isSelected)
                }
            }

    var canGenerateAddress: Bool { return HDWalletManager.instance.canGenerateNextAccount }

    func generateAddress() {
        _ = HDWalletManager.instance.generateNextAccount()
    }

    func setDefaultAddressIndex(_ index: Int) {
        _ = HDWalletManager.instance.selectAccount(index: index)
    }
}
