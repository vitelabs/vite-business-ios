//
//  WalletHomeAddressViewModel.swift
//  Vite
//
//  Created by Stone on 2018/9/9.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional

final class WalletHomeAddressViewModel: WalletHomeAddressViewModelType {

    let defaultAddressDriver: Driver<String> = HDWalletManager.instance.accountDriver.map({ $0?.address.description ?? "" })

    private var address: String?
    private let disposeBag = DisposeBag()

    init() {
        HDWalletManager.instance.accountDriver.drive(onNext: { [weak self] account in
            self?.address = account?.address.description ?? ""
        }).disposed(by: disposeBag)
    }

    func copy() {
        UIPasteboard.general.string = address
        Toast.show(R.string.localizable.walletHomeToastCopyAddress(), duration: 1.0)
    }
}
