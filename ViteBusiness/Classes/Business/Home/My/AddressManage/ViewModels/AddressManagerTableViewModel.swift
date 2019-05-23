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
import ViteWallet

class AddressManagerTableViewModel: AddressManagerTableViewModelType {

    lazy var defaultAddressDriver: Driver<String> = HDWalletManager.instance.accountDriver.map { $0?.address ?? ""}
    lazy var defaultAddressNameDriver: Driver<String> =
        Driver.combineLatest(
            self.defaultAddressDriver,
            AddressManageService.instance.myAddressNameMapDriver).map { (address, _) -> String in
                return AddressManageService.instance.name(for: address)
    }
    
    lazy var addressesDriver: Driver<[AddressManageAddressViewModelType]> =
        Driver.combineLatest(
            HDWalletManager.instance.accountsDriver,
            HDWalletManager.instance.accountDriver,
            AddressManageService.instance.myAddressNameMapDriver)
            .map { (accounts, _, _) -> [AddressManageAddressViewModelType] in
                var number = 0
                return accounts.map { account -> AddressManageAddressViewModelType in
                    let isSelected = number == HDWalletManager.instance.selectBagIndex
                    number += 1
                    let name = AddressManageService.instance.name(for: account.address)
                    return AddressManageAddressViewModel(number: number, name: name, address: account.address, isSelected: isSelected)
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
