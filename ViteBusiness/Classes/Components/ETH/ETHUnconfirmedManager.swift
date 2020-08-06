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

    fileprivate var unconfirmedTransactions: [ETHUnconfirmedTransaction] = []
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

    func add(_ tx: ETHUnconfirmedTransaction) {
        unconfirmedTransactions.append(tx)
        self.save(mappable: Storage(unconfirmedTransactions: unconfirmedTransactions))
        NotificationCenter.default.post(name: .EthChainSendSuccess, object: tx)
    }

    func remove(_ txs: [ETHUnconfirmedTransaction]) {
        guard txs.isNotEmpty else { return }
        var new = [ETHUnconfirmedTransaction]()
        let set = Set(txs.map { $0.hash })

        for tx in unconfirmedTransactions where set.contains(tx.hash) == false {
            new.append(tx)
        }
        unconfirmedTransactions = new
        self.save(mappable: Storage(unconfirmedTransactions: unconfirmedTransactions))
    }

    func ethUnconfirmedTransactions() -> [ETHUnconfirmedTransaction] {
        return unconfirmedTransactions.reversed()
    }

    func erc20UnconfirmedTransactions(for contractAddress: String) -> [ETHUnconfirmedTransaction] {
        return unconfirmedTransactions.filter { $0.erc20ContractAddress == contractAddress }.reversed()
    }
}

extension ETHUnconfirmedManager {

    class Storage: Mappable {
        var unconfirmedTransactions: [ETHUnconfirmedTransaction] = []

        required init?(map: Map) {}

        init(unconfirmedTransactions: [ETHUnconfirmedTransaction]) {
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
