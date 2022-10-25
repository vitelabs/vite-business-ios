//
//  AddressListViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/8.
//

import UIKit
import RxSwift
import RxCocoa

class AddressListViewModel {
    let addressesDriver: Driver<[AddressViewModel]>
    let title: String
    let emptyTip: String

    init(driver: Driver<[AddressViewModel]>, title: String, emptyTip: String) {
        self.addressesDriver = driver
        self.title = title
        self.emptyTip = emptyTip
    }

    static func createMyAddressListViewModel(for coinType: CoinType) -> AddressListViewModel {
        switch coinType {
        case .vite:
            return AddressListViewModel(driver: HDWalletManager.instance.accountsDriver.map({ (accounts) -> [AddressViewModel] in
                var number: Int = 0
                return accounts.map({ (account) -> AddressViewModel in
                    let name = AddressManageService.instance.name(for: account.address)
                    number += 1
                    return AddressViewModel(name: name, number: number, nameImage: nil, type: coinType.name, typeTextColor:  coinType.mainColor, typeBgColor:  coinType.shadowColor, address: account.address)
                })
            }), title: R.string.localizable.sendPageMyAddressTitle(coinType.rawValue), emptyTip: "")
        case .eth:
            return AddressListViewModel(driver: ETHWalletManager.instance.accountsDriver.map({ (accounts) -> [AddressViewModel] in
                var number: Int = 0
                return accounts.map({ (account) -> AddressViewModel in
                    let name = AddressManageService.instance.name(for: account.address)
                    number += 1
                    return AddressViewModel(name: name, number: number, nameImage: nil, type: coinType.name, typeTextColor:  coinType.mainColor, typeBgColor:  coinType.shadowColor, address: account.address)
                })
            }), title: R.string.localizable.sendPageMyAddressTitle(coinType.rawValue), emptyTip: "")
        case .unsupport:
            fatalError()
        }
    }

    static func createAddressListViewModel(for coinType: CoinType) -> AddressListViewModel {
        return AddressListViewModel(driver: AddressManageService.instance.contactsDriver(for: coinType ).map({ (contacts) -> [AddressViewModel] in
            return contacts.map({ (contact) -> AddressViewModel in
                return AddressViewModel(name: contact.name, number: nil, nameImage: R.image.icon_contacts_contact_blue(), type: coinType.name, typeTextColor:  coinType.mainColor, typeBgColor:  coinType.shadowColor, address: contact.address)
            })
        }), title: R.string.localizable.addressListPageOtherTitle(coinType.name), emptyTip: R.string.localizable.addressListPageNoAddressTip(coinType.name))
    }
}
