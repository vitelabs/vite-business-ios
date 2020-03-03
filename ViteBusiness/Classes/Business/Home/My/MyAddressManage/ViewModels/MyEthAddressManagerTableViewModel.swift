//
//  MyEthAddressManagerTableViewModel.swift
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

class MyEthAddressManagerTableViewModel: MyAddressManagerTableViewModelType {

    lazy var defaultAddressDriver: Driver<(String, String)> = ETHWalletManager.instance.accountDriver.map {
        (String($0?.accountIndex ?? 0 + 1), $0?.address ?? "")
    }

    lazy var defaultAddressNameDriver: Driver<String> =
        Driver.combineLatest(
            self.defaultAddressDriver,
            AddressManageService.instance.myAddressNameMapDriver).map { (arg, _) -> String in
                let (_, address) = arg
                return AddressManageService.instance.name(for: address)
    }
    
    lazy var addressesDriver: Driver<[MyAddressManageAddressViewModelType]> =
        Driver.combineLatest(
            ETHWalletManager.instance.accountsDriver,
            ETHWalletManager.instance.accountDriver,
            AddressManageService.instance.myAddressNameMapDriver)
            .map { (accounts, _, _) -> [MyAddressManageAddressViewModelType] in
                var number = 0
                return accounts.map { account -> MyAddressManageAddressViewModelType in
                    let isSelected = (number == ETHWalletManager.instance.account?.accountIndex)
                    number += 1
                    let name = AddressManageService.instance.name(for: account.address)
                    return MyAddressManageAddressViewModel(number: number, name: name, address: account.address, isSelected: isSelected)
                }
            }
    var coinType: CoinType { .eth }
    var showAddressesTips: Bool { return false }

    func generateAddress(complete: @escaping (Bool) -> Void) {
        ETHWalletManager.instance.generateNextAccount()
        complete(true)
    }

    func setDefaultAddressIndex(_ index: Int) {
        _ = ETHWalletManager.instance.selectAccount(index: index)
    }

    func addressDidChangeWhenViewDidDisappear() {

    }
}
