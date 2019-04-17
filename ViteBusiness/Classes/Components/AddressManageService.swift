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

    fileprivate var fileHelper: FileHelper!
    fileprivate static let saveKey = "AddressManage"
    fileprivate let disposeBag = DisposeBag()

    //MARK: save to disk
    private init() { }

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
    private var myAddressNameMap: BehaviorRelay<[String: String]>  = BehaviorRelay(value: [:])

    public func start() {

        HDWalletManager.instance.walletDriver.map({ $0?.uuid }).distinctUntilChanged().drive(onNext: { [weak self] uuid in
            guard let `self` = self else { return }
            if let _ = uuid {
                self.fileHelper = FileHelper.createForWallet()
                if let data = self.fileHelper.contentsAtRelativePath(type(of: self).saveKey),
                    let jsonString = String(data: data, encoding: .utf8),
                    let manager = AddressManager(JSONString: jsonString) {
                    self.myAddressNameMap.accept(manager.myAddressNameMap)
                    self.contactsBehaviorRelay.accept(manager.contacts)
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

