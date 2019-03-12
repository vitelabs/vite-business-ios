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

    static func createMyAddressListViewModel() -> AddressListViewModel {
        return AddressListViewModel(driver: HDWalletManager.instance.accountsDriver.map({ (accounts) -> [AddressViewModel] in
            return accounts.map({ (account) -> AddressViewModel in
                let name = AddressManageService.instance.name(for: account.address)
                return AddressViewModel(name: name, nameImage: R.image.icon_address_name_blue(), type: CoinType.vite.name, typeTextColor:  CoinType.vite.mainColor, typeBgColor:  CoinType.vite.shadowColor, address: account.address.description)
            })
        }), title: R.string.localizable.addressListPageMyTitle(), emptyTip: "")
    }

    static func createAddressListViewModel(for coinType: CoinType) -> AddressListViewModel {
        return AddressListViewModel(driver: AddressManageService.instance.contactsDriver(for: coinType ).map({ (contacts) -> [AddressViewModel] in
            return contacts.map({ (contact) -> AddressViewModel in
                return AddressViewModel(name: contact.name, nameImage: R.image.icon_contacts_contact_blue(), type: coinType.name, typeTextColor:  coinType.mainColor, typeBgColor:  coinType.shadowColor, address: contact.address)
            })
        }), title: R.string.localizable.addressListPageOtherTitle(coinType.name), emptyTip: R.string.localizable.addressListPageNoAddressTip(coinType.name))
    }
}
