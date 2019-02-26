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

    fileprivate var fileHelper = FileHelper(.library, appending: FileHelper.appPathComponent)
    fileprivate static let saveKey = "AddressManage"

    //MARK: save to disk
    private init() {
        if let data = fileHelper.contentsAtRelativePath(type(of: self).saveKey),
            let jsonString = String(data: data, encoding: .utf8),
            let manager = AddressManager(JSONString: jsonString) {
            myAddressNameMap = manager.myAddressNameMap
        }
    }

    private func pri_save() {
        let manager = AddressManager(myAddressNameMap: myAddressNameMap)
        if let data = manager.toJSONString()?.data(using: .utf8) {
            if let error = fileHelper.writeData(data, relativePath: type(of: self).saveKey) {
                assert(false, error.localizedDescription)
            }
        }
    }

    //MARK: my address name
    private var myAddressNameMap: [String: String] = [:]

    func name(for myAddress: Address) -> String {
        return myAddressNameMap[myAddress.description] ?? R.string.localizable.addressManageDefaultAddressName()
    }

    func updateName(for myAddress: Address, name: String) {
        myAddressNameMap[myAddress.description] = name
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

