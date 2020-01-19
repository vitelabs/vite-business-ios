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
import PromiseKit

extension WalletManager: Storageable {
    public func getStorageConfig() -> StorageConfig {
        return StorageConfig(name: "WalletManager", path: .wallet)
    }

    public struct Storager: Mappable {

        public fileprivate(set) var vitexInviteCode: String?
        fileprivate var invitedAddresses: [ViteAddress] = []

        public init(vitexInviteCode: String? = nil, invitedAddresses: [ViteAddress] = []) {
            self.vitexInviteCode = vitexInviteCode
            self.invitedAddresses = invitedAddresses
        }

        public init?(map: Map) {

        }

        public mutating func mapping(map: Map) {
            vitexInviteCode <- map["vitexInviteCode"]
            invitedAddresses <- map["invitedAddresses"]
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


}

// MARK: vitex invite
extension WalletManager {

    public func update(vitexInviteCode: String?) {
        if var storager = storagerBehaviorRelay.value {
            storager.vitexInviteCode = vitexInviteCode
            storagerBehaviorRelay.accept(storager)
            save(mappable: storager)
        }
    }

    public func checkVitexInviteCodeAndUpdate(vitexInviteCode: String) {
        checkVitexInviteCode(vitexInviteCode: vitexInviteCode).done { [weak self] (ret) in
            if ret {
                self?.update(vitexInviteCode: vitexInviteCode)
            }
        }.catch {[weak self] _ in
            self?.checkVitexInviteCodeAndUpdate(vitexInviteCode: vitexInviteCode)
        }
    }

    public func checkVitexInviteCode(vitexInviteCode: String) -> Promise<Bool> {
        guard let code = Int64(vitexInviteCode) else { return Promise.value(false) }
        return ViteNode.dex.info.checkDexInviteCode(inviteCode: code)
    }


    func bindInviteIfNeeded() {

        func append(invitedAddress: ViteAddress) {
            if var storager = storagerBehaviorRelay.value {
                storager.invitedAddresses.append(invitedAddress)
                storagerBehaviorRelay.accept(storager)
                save(mappable: storager)
            }
        }

        func tryBind(account: Wallet.Account) {
            guard HDWalletManager.instance.account?.address == account.address else { return }
            guard let code = storager?.vitexInviteCode else { return }

            ViteNode.dex.info.getDexInviteCodeBinding(address: account.address).then { (c) -> Promise<Void> in
                if let _ = c {
                    return Promise.value(Void())
                } else {
                    return ViteNode.rawTx.send.block(account: account, toAddress: ABI.BuildIn.dexBindInviteCode.toAddress, tokenId: ViteWalletConst.viteToken.id, amount: Amount(0), fee: nil, data: ABI.BuildIn.getDexBindInviterData(code: code)).asVoid()
                }
            }.done {
                append(invitedAddress: account.address)
            }.catch { (error) in
                GCD.delay(2) { tryBind(account: account) }
            }
        }

        func checkAccountBlock(account: Wallet.Account) {
            guard HDWalletManager.instance.account?.address == account.address else { return }

            ViteNode.ledger.getLatestAccountBlock(address: account.address).done { (accountBlock) in
                if let _ = accountBlock {
                    tryBind(account: account)
                } else {
                    GCD.delay(2) { checkAccountBlock(account: account) }
                }
            }.catch { (_) in
                GCD.delay(2) { checkAccountBlock(account: account) }
            }
        }

        func accountInit(account: Wallet.Account) {
            guard HDWalletManager.instance.account?.address == account.address else { return }

            UnifyProvider.accountInit(address: account.address).done { (_)  in
                GCD.delay(2) { checkAccountBlock(account: account) }
            }.catch { (_) in
                GCD.delay(2) { accountInit(account: account) }
            }
        }

        func checkInviteCode(account: Wallet.Account) {
            guard HDWalletManager.instance.account?.address == account.address else { return }
            guard let code = storager?.vitexInviteCode else { return }

            checkVitexInviteCode(vitexInviteCode: code).done {[weak self] (ret) in
                if ret {
                    accountInit(account: account)
                } else {
                    self?.update(vitexInviteCode: nil)
                }
            }.catch { (_) in
                GCD.delay(2) { checkInviteCode(account: account) }
            }
        }

        guard let account = HDWalletManager.instance.account else { return }
        guard let s = storager else { return }
        guard let _ = s.vitexInviteCode else { return }
        guard !s.invitedAddresses.contains(account.address) else { return }
        checkInviteCode(account: account)
    }
}
