//
//  AddressManageService.swift
//  Action
//
//  Created by Stone on 2019/2/22.
//

import Foundation
import RxSwift
import RxCocoa
import ViteUtils
import ObjectMapper
import ViteWallet

public final class AddressManageService {
    public static let instance = AddressManageService()

    fileprivate var fileHelper = FileHelper(.library, appending: FileHelper.walletPathComponent)
    fileprivate static let saveKey = "AddressManage"

    //MARK: save to disk
    private init() {
        if let data = fileHelper.contentsAtRelativePath(type(of: self).saveKey),
            let jsonString = String(data: data, encoding: .utf8),
            let manager = AddressManager(JSONString: jsonString) {
            myAddressNameMap = BehaviorRelay(value: manager.myAddressNameMap)
            contactsBehaviorRelay = BehaviorRelay(value: manager.contacts)
        } else {
            myAddressNameMap = BehaviorRelay(value: [:])
            contactsBehaviorRelay = BehaviorRelay(value: [])
        }
    }

    private func pri_save() {
        let manager = AddressManager(myAddressNameMap: myAddressNameMap.value, contacts: contactsBehaviorRelay.value)
        if let data = manager.toJSONString()?.data(using: .utf8) {
            if let error = fileHelper.writeData(data, relativePath: type(of: self).saveKey) {
                assert(false, error.localizedDescription)
            }
        }
    }

    //MARK: my address name
    public lazy var myAddressNameMapDriver: Driver<[String: String]> = self.myAddressNameMap.asDriver()
    private var myAddressNameMap: BehaviorRelay<[String: String]>

    func name(for myAddress: Address, placeholder: String = R.string.localizable.addressManageDefaultAddressName()) -> String {
        return myAddressNameMap.value[myAddress.description] ?? placeholder
    }

    func updateName(for myAddress: Address, name: String) {
        var map = myAddressNameMap.value
        if name.isEmpty {
            map[myAddress.description] = nil
        } else {
            map[myAddress.description] = name
        }
        myAddressNameMap.accept(map)
        pri_save()
    }

    //MARK: contacts
    public lazy var contactsDriver: Driver<[Contact]> = self.contactsBehaviorRelay.asDriver()
    private var contactsBehaviorRelay: BehaviorRelay<[Contact]>

    public func contactsDriver(for coinType: CoinType) -> Driver<[Contact]> {
        return contactsDriver.map({ $0.filter({ $0.type == coinType }) })
    }

    public func addContact(type: CoinType, name: String, address: String) {
        var array = contactsBehaviorRelay.value
        array.append(Contact(id: UUID().uuidString, type: type, name: name, address: address))
        contactsBehaviorRelay.accept(array)
        pri_save()
    }

    public func removeContact(forId id: String) {
        var array = contactsBehaviorRelay.value
        for (index, contact) in array.enumerated() where contact.id == id {
            array.remove(at: index)
        }
        contactsBehaviorRelay.accept(array)
        pri_save()
    }
}

public struct Contact: Mappable {
    var id: String = ""
    var type: CoinType = .vite
    var name: String = ""
    var address: String = ""

    public init?(map: Map) {}

    mutating public func mapping(map: Map) {
        id <- map["id"]
        type <- map["type"]
        name <- map["name"]
        address <- map["address"]
    }

    init(id: String, type: CoinType, name: String, address: String) {
        self.id = id
        self.type = type
        self.name = name
        self.address = address
    }
}

extension AddressManageService {

    struct AddressManager: Mappable {
        var myAddressNameMap: [String: String] = [:]
        var contacts: [Contact] = []

        init?(map: Map) {}

        mutating func mapping(map: Map) {
            myAddressNameMap <- map["myAddressNameMap"]
            contacts <- map["contacts"]
        }

        init(myAddressNameMap: [String: String], contacts: [Contact]) {
            self.myAddressNameMap = myAddressNameMap
            self.contacts = contacts
        }
    }
}

