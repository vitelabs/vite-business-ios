//
//  ConfirmViewModelType.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/13.
//

import UIKit

public protocol ConfirmViewModelType {
    func createInfoView() -> UIView
    var confirmTitle: String { get }
    var biometryConfirmButtonTitle: String { get }
}
