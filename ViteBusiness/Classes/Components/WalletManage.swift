//
//  WalletManage.swift
//  ViteBusiness
//
//  Created by Stone on 2019/11/12.
//

import Foundation
import RxSwift
import RxCocoa
import NSObject_Rx
import Alamofire
import ViteWallet
import ObjectMapper

extension WalletManager: Storageable {
    public func getStorageConfig() -> StorageConfig {
        return StorageConfig(name: "WalletManager", path: .wallet)
    }

    public struct Storager: Mappable {

        public fileprivate(set) var vitexInviteCode: String?

        public init(vitexInviteCode: String? = nil) {
            self.vitexInviteCode = vitexInviteCode
        }

        public init?(map: Map) {

        }

        public mutating func mapping(map: Map) {
            vitexInviteCode <- map["vitexInviteCode"]
        }
    }
}

public final class WalletManager: NSObject {
    public static let instance = WalletManager()
    public lazy var storagerDriver: Driver<Storager?> = self.storagerBehaviorRelay.asDriver()
    public var storager: Storager? { return storagerBehaviorRelay.value }
    private let storagerBehaviorRelay: BehaviorRelay<Storager?> = BehaviorRelay(value: nil)
    private override init() {}

    //MARK: Launch
    func start() {
        HDWalletManager.instance.walletDriver.drive(onNext: { [weak self] (w) in
            guard let `self` = self else { return }
            if let wallet = w {
                self.storagerBehaviorRelay.accept(self.readMappable() ?? Storager())
            } else {
                self.storagerBehaviorRelay.accept(nil)
            }
        }).disposed(by: rx.disposeBag)
    }

    func update(vitexInviteCode: String) {
        if var storager = storagerBehaviorRelay.value {
            storager.vitexInviteCode = vitexInviteCode
            storagerBehaviorRelay.accept(storager)
            save(mappable: storager)
        }
    }
}
