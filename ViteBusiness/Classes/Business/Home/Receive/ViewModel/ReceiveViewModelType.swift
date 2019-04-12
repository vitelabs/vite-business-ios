//
//  ReceiveViewModelType.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/7.
//

import RxSwift
import RxCocoa
import NSObject_Rx
import ViteWallet

protocol ReceiveViewModelType {
    var walletName: String { get }
    var addressName: String? { get }
    var address: String { get }

    var tipStringDriver: Driver<String> { get }
    var uriStringDriver: Driver<String> { get }

    var amountStringBehaviorRelay: BehaviorRelay<String?> { get }
    var noteStringBehaviorRelay: BehaviorRelay<String?> { get }

    var isShowNoteView: Bool { get }
}

extension ReceiveViewModelType {
    var walletName: String {
        return HDWalletManager.instance.wallet?.name ?? ""
    }
}

extension TokenInfo {
    func createReceiveViewModel() -> ReceiveViewModelType {
        switch coinType {
        case .vite:
            return ReceiveViteViewModel(tokenInfo: self)
        case .eth:
            return ReceiveEthViewModel(tokenInfo: self)
        default:
            fatalError()
        }
    }
}
