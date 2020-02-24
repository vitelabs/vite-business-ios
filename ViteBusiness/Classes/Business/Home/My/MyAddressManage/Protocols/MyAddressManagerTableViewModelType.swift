//
//  MyViteAddressManagerTableViewModelType.swift
//  Vite
//
//  Created by Stone on 2018/9/13.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol MyAddressManagerTableViewModelType {
    var defaultAddressDriver: Driver <(String, String)> { get }
    var defaultAddressNameDriver: Driver<String> {get }
    var addressesDriver: Driver<[MyAddressManageAddressViewModelType]> { get }

    var coinType: CoinType { get }
    var canGenerateAddress: Bool { get }
    var showAddressesTips: Bool { get }

    func generateAddress()
    func setDefaultAddressIndex(_ index: Int)
    func addressDidChangeWhenViewDidDisappear()
}
