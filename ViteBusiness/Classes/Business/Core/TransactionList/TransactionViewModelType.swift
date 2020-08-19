//
//  TransactionViewModelType.swift
//  ViteBusiness
//
//  Created by Stone on 2020/8/19.
//

import Foundation

import UIKit

protocol TransactionViewModelType {
    var typeImage: UIImage { get }
    var typeName: String { get }
    var address: String { get }
    var state: (text: String, color: UIColor) { get }
    var timeString: String { get }
    var balance: (text: String, color: UIColor) { get }
}
