//
//  MyAddressManageAddressViewModelType.swift
//  Vite
//
//  Created by Stone on 2018/9/13.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation

protocol MyAddressManageAddressViewModelType {
    var number: Int { get }
    var name: String { get }
    var address: String { get }
    var isSelected: Bool { get }
    func copy()
}
