//
//  ContactsListViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/8.
//

import UIKit
import RxSwift
import RxCocoa

class ContactsListViewModel {
    let contactsDriver: Driver<[Contact]>

    init(contactsDriver: Driver<[Contact]>) {
        self.contactsDriver = contactsDriver
    }
}
