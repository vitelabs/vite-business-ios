//
//  AddressViewModel.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/12.
//

import UIKit

struct AddressViewModel {
    let name: String
    let nameImage: UIImage?
    let number: Int?
    let type: String
    let typeTextColor: UIColor
    let typeBgColor: UIColor
    let address: String

    init(name: String, number: Int?, nameImage: UIImage?, type: String, typeTextColor: UIColor, typeBgColor: UIColor, address: String) {
        self.name = name
        self.number = number
        self.nameImage = nameImage
        self.type = type
        self.typeTextColor = typeTextColor
        self.typeBgColor = typeBgColor
        self.address = address
    }
}
