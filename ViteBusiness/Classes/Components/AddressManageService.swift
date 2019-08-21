//
//  AddressManageService.swift
//  Action
//
//  Created by Stone on 2019/2/22.
//

import Foundation
import RxSwift
import RxCocoa
import ObjectMapper
import ViteWallet

public final class AddressManageService {
    public static let instance = AddressManageService()
    fileprivate let disposeBag = DisposeBag()

    //MARK: save to disk
    private init() { }

    private func pri_save() {
        let storage = Storage(myAddressNameMap: myAddressNameMap.value, contacts: contactsBehaviorRelay.value)
        save(mappable: storage)
    }

    //MARK: my address name
    public lazy var myAddressNameMapDriver: Driver<[String: String]> = self.myAddressNameMap.asDriver()
    private var myAddressNameMap: BehaviorRelay<[String: String]>  = BehaviorRelay(value: [:])

    public func start() {

        HDWalletManager.instance.walletDriver.map({ $0?.uuid }).distinctUntilChanged().drive(onNext: { [weak self] uuid in
            guard let `self` = self else { return }
            if let _ = uuid {
                if let storage: Storage = self.readMappable() {
                    self.myAddressNameMap.accept(storage.myAddressNameMap)
                    self.contactsBehaviorRelay.accept(storage.contacts)
                } else {
                    self.myAddressNameMap.accept([:])
                    self.contactsBehaviorRelay.accept([])
                }
            } else {
                self.myAddressNameMap.accept([:])
                self.contactsBehaviorRelay.accept([])
            }
        }).disposed(by: disposeBag)
    }

    func name(for myAddress: ViteAddress, placeholder: String = R.string.localizable.addressManageDefaultAddressName()) -> String {
        return myAddressNameMap.value[myAddress] ?? placeholder
    }

    func updateName(for myAddress: ViteAddress, name: String) {
        var map = myAddressNameMap.value
        if name.isEmpty {
            map[myAddress] = nil
        } else {
            map[myAddress] = name
        }
        myAddressNameMap.accept(map)
        pri_save()
    }

    //MARK: contacts
    public lazy var contactsDriver: Driver<[Contact]> = self.contactsBehaviorRelay.asDriver()
    private var contactsBehaviorRelay: BehaviorRelay<[Contact]> = BehaviorRelay(value: [])

    public func contactsDriver(for coinType: CoinType) -> Driver<[Contact]> {
        return contactsDriver.map({ $0.filter({ $0.type == coinType }) })
    }

    public func addContact(type: CoinType, name: String, address: String) {
        var array = contactsBehaviorRelay.value
        array.append(Contact(id: UUID().uuidString, type: type, name: name, address: address))
        contactsBehaviorRelay.accept(array)
        pri_save()
    }

    public func updateContact(_ contact: Contact) {
        var array = contactsBehaviorRelay.value
        for (index, c) in array.enumerated() where c.id == contact.id {
            array.remove(at: index)
            array.insert(contact, at: index)
        }
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

    func contactName(for address: ViteAddress) -> String? {
        for contact in contactsBehaviorRelay.value where contact.address == address {
            return contact.name
        }
        return nil
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

    struct Storage: Mappable {
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

extension AddressManageService: Storageable {
    public func getStorageConfig() -> StorageConfig {
        return StorageConfig(name: "AddressManage", path: .wallet)
    }
}
