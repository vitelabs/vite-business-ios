//
//  MyViteAddressManagerTableViewModel.swift
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

class MyViteAddressManagerTableViewModel: MyAddressManagerTableViewModelType {

    lazy var defaultAddressDriver: Driver<(String, String)> = HDWalletManager.instance.accountDriver.map {
        (String(HDWalletManager.instance.selectBagIndex + 1), $0?.address ?? "")
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
            HDWalletManager.instance.accountsDriver,
            HDWalletManager.instance.accountDriver,
            AddressManageService.instance.myAddressNameMapDriver)
            .map { (accounts, _, _) -> [MyAddressManageAddressViewModelType] in
                var number = 0
                return accounts.map { account -> MyAddressManageAddressViewModelType in
                    let isSelected = number == HDWalletManager.instance.selectBagIndex
                    number += 1
                    let name = AddressManageService.instance.name(for: account.address)
                    return MyAddressManageAddressViewModel(number: number, name: name, address: account.address, isSelected: isSelected)
                }
            }

    var coinType: CoinType { .vite }
    var canGenerateAddress: Bool { return HDWalletManager.instance.canGenerateNextAccount }
    var showAddressesTips: Bool { return true }

    func generateAddress() {
        _ = HDWalletManager.instance.generateNextAccount()
    }

    func setDefaultAddressIndex(_ index: Int) {

        if BifrostManager.instance.status != .disconnect {
            Alert.show(title: R.string.localizable.bifrostAlertTipTitle(),
                       message: R.string.localizable.bifrostAlertSwitchAddressMessage(),
                       actions: [
                        (.cancel, nil),
                        (.default(title: R.string.localizable.confirm()), { _ in
                            BifrostManager.instance.disConnectByUser()
                            _ = HDWalletManager.instance.selectAccount(index: index)
                        })
                ], config: { alert in
                    alert.preferredAction = alert.actions[0]
            })
        } else {
            _ = HDWalletManager.instance.selectAccount(index: index)
        }
    }

    func addressDidChangeWhenViewDidDisappear() {
        WalletManager.instance.bindInviteIfNeeded()
    }
}
