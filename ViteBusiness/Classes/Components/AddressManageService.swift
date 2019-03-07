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
        } else {
            myAddressNameMap = BehaviorRelay(value: [:])
        }
    }

    private func pri_save() {
        let manager = AddressManager(myAddressNameMap: myAddressNameMap.value)
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
}

extension AddressManageService {
    struct AddressManager: Mappable {
        var myAddressNameMap: [String: String] = [:]

        init?(map: Map) {}

        mutating func mapping(map: Map) {
            myAddressNameMap <- map["myAddressNameMap"]
        }

        init(myAddressNameMap: [String: String]) {
            self.myAddressNameMap = myAddressNameMap
        }
    }
}

