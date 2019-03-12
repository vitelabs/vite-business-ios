//
//  ContactsViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/12.
//

import UIKit

struct ContactsViewModel {
    let name: String
    let type: String
    let address: String
    let typeTextColor: UIColor
    let typeBgColor: UIColor
    let contact: Contact

    init(contact: Contact) {
        self.contact = contact
        self.name = contact.name
        self.type = contact.type.name
        self.address = contact.address
        self.typeTextColor = contact.type.mainColor
        self.typeBgColor = contact.type.shadowColor
    }
}
