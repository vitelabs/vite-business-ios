//
//  ETHUnconfirmedManager.swift
//  ViteBusiness
//
//  Created by Stone on 2020/8/5.
//

import Foundation
import ObjectMapper
import RxSwift
import RxCocoa

class ETHUnconfirmedManager {
    static let instance = ETHUnconfirmedManager()
    private init() {}
    fileprivate let disposeBag = DisposeBag()

    fileprivate var unconfirmedTransactions: [ETHTransaction] = []
    var accountAddress: String = ""

    func start() {
        ETHWalletManager.instance.accountDriver.drive(onNext: { [weak self] a in
            guard let `self` = self else { return }
            self.accountAddress = a?.ethereumAddress.address ?? ""

            if let storage: Storage = self.readMappable() {
                self.unconfirmedTransactions = storage.unconfirmedTransactions
            } else {
                self.unconfirmedTransactions = []
            }
        }).disposed(by: disposeBag)
    }

    func add(_ tx: ETHTransaction) {
        unconfirmedTransactions.append(tx)
        self.save(mappable: Storage(unconfirmedTransactions: unconfirmedTransactions))
        NotificationCenter.default.post(name: .EthChainSendSuccess, object: tx.contractAddress)
    }

    func remove(_ txs: [ETHTransaction]) {
        guard txs.isNotEmpty else { return }
        var new = [ETHTransaction]()
        let set = Set(txs.map { $0.hash })

        for tx in unconfirmedTransactions where set.contains(tx.hash) == false {
            new.append(tx)
        }
        unconfirmedTransactions = new
        self.save(mappable: Storage(unconfirmedTransactions: unconfirmedTransactions))
    }

    // contractAddress = "" is ETH
    func unconfirmedTransactions(for contractAddress: String) -> [ETHTransaction] {
        if contractAddress.isEmpty {
            return unconfirmedTransactions.reversed()
        } else {
            return unconfirmedTransactions.filter { $0.contractAddress == contractAddress }.reversed()
        }
    }
}

extension ETHUnconfirmedManager {

    class Storage: Mappable {
        var unconfirmedTransactions: [ETHTransaction] = []

        required init?(map: Map) {}

        init(unconfirmedTransactions: [ETHTransaction]) {
            self.unconfirmedTransactions = unconfirmedTransactions
        }

        func mapping(map: Map) {
            unconfirmedTransactions <- map["unconfirmedTransactions"]
        }
    }

}


extension ETHUnconfirmedManager: Storageable {
    func getStorageConfig() -> StorageConfig {
        return StorageConfig(name: "ETHUnconfirmedManager", path: .wallet ,appending: self.accountAddress)
    }
}
