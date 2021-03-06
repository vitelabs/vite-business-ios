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
                return accounts.map { account -> MyAddressManageAddressViewModelType in
                    let isSelected = account.index == HDWalletManager.instance.selectBagIndex
                    let name = AddressManageService.instance.name(for: account.address)
                    return MyAddressManageAddressViewModel(number: account.index + 1, name: name, address: account.address, isSelected: isSelected)
                }
            }

    var coinType: CoinType { .vite }
    var showAddressesTips: Bool { return true }

    func generateAddress(complete: @escaping (Bool) -> Void) {

        guard let wallet = HDWalletManager.instance.wallet else {
            complete(false)
            return
        }
        guard wallet.addressCount < 100 else {
            Toast.show(R.string.localizable.addressManageAddressGenerateButtonToast())
            complete(false)
            return
        }

        Alert.show(title: R.string.localizable.addressManageAlertTitle(), message: R.string.localizable.addressManageAlertTip(), actions: [
            (.cancel, { _ in complete(false) }),
            (.default(title: R.string.localizable.confirm()), { alert in
                guard let text = alert.textFields?.first?.text, let count = Int(text) else {
                    Toast.show(R.string.localizable.addressManageAddressGenerateButtonErrorToast())
                    complete(false)
                    return
                }
                guard count > wallet.addressCount else {
                    Toast.show(R.string.localizable.addressManageAddressGenerateButtonAlreadyToast())
                    complete(false)
                    return
                }
                guard count <= 100 else {
                    Toast.show(R.string.localizable.addressManageAddressGenerateButtonToast())
                    complete(false)
                    return
                }
                let ret = HDWalletManager.instance.generateAccount(count: count)
                complete(ret)
            }),
            ], config: { alert in
                alert.addTextField(configurationHandler: { (textField) in
                    textField.clearButtonMode = .always
                    textField.placeholder = R.string.localizable.addressManageAlertPlaceholder()
                })
        })
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
